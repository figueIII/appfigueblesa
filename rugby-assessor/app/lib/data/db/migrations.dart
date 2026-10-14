// Migraciones de datos que no se pueden expresar solo con el esquema.

import 'package:drift/drift.dart';

import '../../domain/laws.dart';
import '../../domain/match_facts.dart';
import '../../domain/model.dart';
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
