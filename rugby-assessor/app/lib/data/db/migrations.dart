// Migraciones de datos que no se pueden expresar solo con el esquema.

import 'package:drift/drift.dart';

import '../../domain/laws.dart';
import '../../domain/match_facts.dart';
import '../../domain/model.dart';
import '../../domain/rubric_default.dart';
import '../codecs.dart';
import 'app_database.dart';

/// v3 → v4. En v3 las sanciones (GC, GF, tarjetas) eran filas de `sanction_event`; desde v4 son
/// incidencias con la decisión tomada contra el equipo infractor. Cada fila pasa a ser una
/// incidencia con su minuto, su motivo y su anulación. Queda pendiente de valorar ("Por revisar");
/// en un partido ya cerrado queda como "No valorable" (un informe cerrado no se reabre).
///
/// Idempotente: si la tabla ya no existe (la base de datos ya era v4 pero una versión antigua de
/// la app rebajó su número de versión al abrirla), no hace nada.
Future<void> migrateSanctionsToIncidents(AppDatabase db) async {
  if (!await sqliteObjectExists(db, 'table', 'sanction_event')) return;
  final rows = await db.customSelect(
    'SELECT s.*, a.status AS assessment_status FROM sanction_event s JOIN assessment a ON a.id = s.assessment_id '
    'ORDER BY s.assessment_id, s.t_session_ms, s.seq',
  ).get();
  final nextSeq = <String, int>{};
  for (final r in rows) {
    final assessmentId = r.read<String>('assessment_id');
    final seq = nextSeq[assessmentId] ??= (await db
                .customSelect('SELECT COALESCE(MAX(seq), 0) AS m FROM incident WHERE assessment_id = ?', variables: [Variable.withString(assessmentId)])
                .getSingle())
            .read<int>('m') +
        1;
    nextSeq[assessmentId] = seq + 1;
    final kind = decodeSanctionKind(r.read<String>('kind'));
    final why = InfractionRef.decode(
      r.readNullable<String>('infraction_code'),
      r.readNullable<String>('infraction_custom'),
      r.readNullable<String>('infraction_law_ref'),
    );
    final category = categoryForSanction(kind, why);
    final closed = const {'FINALIZED', 'ARCHIVED'}.contains(r.read<String>('assessment_status'));
    final clockMs = r.read<int>('match_clock_ms');
    final decision = Decision(outcomes: [outcomeFor(kind)], againstTeam: decodeTeam(r.read<String>('team')));
    await db.customStatement(
      'INSERT INTO incident (id, assessment_id, seq, t_session_ms, wall_utc, period, phase_label, period_elapsed_ms, '
      'match_clock_ms, overtime_ms, time_integrity, category, criterion_code, polarity, decision_taken_json, verdict, '
      'impact, impact_confirmed, source, status, void_reason, updated_at, infraction_code, infraction_custom, infraction_law_ref) '
      "VALUES (?, ?, ?, ?, ?, ?, 'IN_PLAY', ?, ?, 0, 'OK', ?, ?, 'REVIEW', ?, ?, 'MEDIUM', 0, 'MANUAL', ?, ?, ?, ?, ?, ?)",
      [
        r.read<String>('id'),
        assessmentId,
        seq,
        r.read<int>('t_session_ms'),
        r.read<String>('wall_utc'),
        r.readNullable<String>('period'),
        clockMs,
        clockMs,
        encodeCategory(category),
        kCategoryToCriterion[category]!,
        encodeDecision(decision),
        closed ? 'NOT_ASSESSABLE' : 'PENDING',
        r.read<String>('status') == 'VOID' ? 'VOID' : 'QUICK',
        r.read<String>('status') == 'VOID' ? 'UNDO' : null,
        r.read<String>('wall_utc'),
        why?.code,
        why?.customText,
        why?.customLawRef,
      ],
    );
  }
  for (final t in const [
    'sanction_event_void_or_reason',
    'sanction_event_no_delete',
    'sanction_event_locked_insert',
    'sanction_event_locked_update',
  ]) {
    await db.customStatement('DROP TRIGGER IF EXISTS $t');
  }
  await db.customStatement('DROP TABLE IF EXISTS sanction_event');
}

/// Competencia del CARC que sustituye a cada criterio de la rúbrica v2 (para las fortalezas, áreas
/// de mejora y recomendaciones que pasan de una rúbrica a otra).
const Map<String, String> kLegacyCriterionToCarc = {
  'A1_SCRUM': 'D2_SCRUM_SEQUENCE_SAFETY',
  'A2_LINEOUT_MAUL': 'D4_FAIR_CONTEST',
  'A3_TACKLE_RUCK': 'E2_TACKLER_TACKLED',
  'A4_OFFSIDE_SPACE': 'E4_OFFSIDE_LINES',
  'B1_VERBAL_CONTROL': 'B3_PLAYER_COMMUNICATION',
  'B2_TONE_PRESENCE': 'B1_PRIMARY_SIGNAL_WHISTLE',
  'B3_CAPTAINS_PLAYERS': 'F3_MATCH_CONTROL',
  'B4_ADVANTAGE': 'C3_ADVANTAGE_CONSISTENCY',
  'C1_LAW_ACCURACY': 'C2_MATERIAL_EFFECT',
  'C2_FOUL_PLAY': 'F1_DANGEROUS_PLAY',
  'C3_SANCTION_CONSISTENCY': 'F2_FOUL_PLAY',
  'D1_FITNESS': 'A5_REACHES_CONTACT',
  'D2_POSITIONING': 'A3_SEES_PLAY',
  'D3_RUNNING_LINES': 'A4_OPEN_PLAY_LINES',
};

/// Registra la rúbrica CARC en la tabla `rubric` (referencia de assessment.rubric_id).
Future<void> ensureCarcRubricRow(AppDatabase db) => db.customStatement(
      'INSERT OR IGNORE INTO rubric (id, code, version, status, definition_json) VALUES (?, ?, ?, ?, ?)',
      [
        kDefaultRubric.id,
        kDefaultRubric.code,
        kDefaultRubric.version,
        'PUBLISHED',
        '{"code":"${kDefaultRubric.code}","version":"${kDefaultRubric.version}"}',
      ],
    );

/// v4 → v5. Idempotente (puede repetirse si una versión antigua rebajó el número de versión):
/// 1. `report` y `criterion_score` se reconstruyen para admitir la escala E/C/N/U (las restricciones
///    CHECK no se pueden cambiar de otra forma en SQLite) y `report` gana la dificultad real y la
///    recomendación de nivel. Los datos se copian tal cual: los informes cerrados conservan
///    BELOW/AT/ABOVE y su hash.
/// 2. `app_setting` (preferencias: idioma).
/// 3. Los partidos SIN CERRAR pasan a la rúbrica CARC: cada marca se asigna a la competencia de su
///    categoría, las bandas ya elegidas se descartan (eran de otros criterios) y las fortalezas,
///    áreas de mejora y recomendaciones pasan a la competencia equivalente. Los cerrados siguen con
///    la rúbrica v2, con la que se abren y exportan.
Future<void> migrateToCarcRubric(AppDatabase db, Migrator m) async {
  final reportSql = (await db.customSelect("SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'report'").getSingle())
      .read<String>('sql');
  final newReportColumns = [
    for (final col in [db.report.actualDifficulty, db.report.levelRecommendation])
      if (!await sqliteColumnExists(db, 'report', col.name)) col,
  ];
  if (newReportColumns.isNotEmpty || !reportSql.contains("'E'")) {
    await m.alterTable(TableMigration(db.report, newColumns: newReportColumns));
  }
  final scoreSql = (await db.customSelect("SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'criterion_score'").getSingle())
      .read<String>('sql');
  if (!scoreSql.contains("'E'")) await m.alterTable(TableMigration(db.criterionScore));
  if (!await sqliteObjectExists(db, 'table', 'app_setting')) await m.createTable(db.appSetting);

  await db.transaction(() async {
    await ensureCarcRubricRow(db);
    final open = await db.customSelect(
      "SELECT id FROM assessment WHERE rubric_id <> ? AND status NOT IN ('FINALIZED','ARCHIVED')",
      variables: [Variable.withString(kDefaultRubric.id)],
    ).get();
    for (final row in open) {
      final id = row.read<String>('id');
      await db.customStatement('UPDATE assessment SET rubric_id = ? WHERE id = ?', [kDefaultRubric.id, id]);
      await db.customStatement("UPDATE report SET rubric_id = ? WHERE assessment_id = ? AND status = 'DRAFT'", [kDefaultRubric.id, id]);
      await db.customStatement(
        "DELETE FROM criterion_score WHERE assessment_id = ? AND version IN (SELECT version FROM report WHERE assessment_id = ? AND status = 'DRAFT')",
        [id, id],
      );
      for (final e in kCategoryToCriterion.entries) {
        await db.customStatement(
          'UPDATE incident SET criterion_code = ? WHERE assessment_id = ? AND category = ? AND criterion_code <> ?',
          [e.value, id, encodeCategory(e.key), e.value],
        );
      }
      for (final e in kLegacyCriterionToCarc.entries) {
        await db.customStatement('UPDATE finding SET criterion_code = ? WHERE assessment_id = ? AND criterion_code = ?', [e.value, id, e.key]);
      }
    }
    // Las recomendaciones viven por árbitro y se revisan en el SIGUIENTE informe (con el CARC).
    for (final e in kLegacyCriterionToCarc.entries) {
      await db.customStatement('UPDATE action_point SET criterion_code = ? WHERE criterion_code = ?', [e.value, e.key]);
    }
  });
}

/// ¿Existe en la base de datos la tabla, índice o trigger [name]?
Future<bool> sqliteObjectExists(AppDatabase db, String type, String name) async =>
    (await db.customSelect(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ?',
      variables: [Variable.withString(type), Variable.withString(name)],
    ).get())
        .isNotEmpty;

/// ¿Tiene la tabla [table] la columna [column]?
Future<bool> sqliteColumnExists(AppDatabase db, String table, String column) async =>
    (await db.customSelect('SELECT 1 FROM pragma_table_info(?) WHERE name = ?',
            variables: [Variable.withString(table), Variable.withString(column)])
        .get())
        .isNotEmpty;
