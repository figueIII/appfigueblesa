// Migración v4 → v5 (rúbrica CARC): los informes cerrados no se tocan (ni su banda ni su huella)
// y se siguen abriendo con la rúbrica v2; los partidos sin cerrar pasan a las competencias CARC.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/data/db/app_database.dart';
import 'package:ref_assess/data/drift_evaluation_repository.dart';
import 'package:ref_assess/data/settings_repository.dart';
import 'package:ref_assess/core/i18n.dart';
import 'package:ref_assess/domain/rubric.dart';
import 'package:ref_assess/domain/rubric_default.dart';
import 'package:ref_assess/domain/rubric_legacy.dart';
import 'package:ref_assess/domain/rubrics.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

void main() {
  test('v4 → v5: cerrados intactos con la rúbrica v2; abiertos pasan al CARC; escala E/C/N/U y preferencias', () async {
    final dir = Directory.systemTemp.createTempSync('refassess_carc_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/v4.sqlite');
    final v4 = raw.sqlite3.open(file.path);
    v4.execute(File('test/data/fixtures/schema_v4.sql').readAsStringSync());
    v4.execute("INSERT INTO official VALUES ('ref', 'Árbitro', NULL, NULL, NULL, 'x', 'x')");
    v4.execute("INSERT INTO assessor_profile VALUES ('ev', 'Evaluador', NULL, NULL)");
    v4.execute("INSERT INTO rubric VALUES ('$kLegacyRubricV2Id', 'RUGBY-XV-BASE', '2.0.0', 'PUBLISHED', '{}')");
    const cat = '{"code":"M18","name":"M18","format":"XV","periodLengthMin":35,"sinBinMin":5}';
    for (final aid in const ['closed', 'open']) {
      v4.execute(
        "INSERT INTO assessment (id, status, rubric_id, assessor_id, referee_id, competition, kickoff_local, kickoff_tz, venue, "
        "home_team, away_team, observation_mode, difficulty, category_code, category_json, created_at, updated_at) VALUES "
        "('$aid', 'POST_MATCH', '$kLegacyRubricV2Id', 'ev', 'ref', 'Liga', '2026-10-10T17:00', 'Europe/Madrid', 'Campo', 'Local', "
        "'Visitante', 'LIVE', 'HIGH', 'M18', '$cat', 'x', 'x')",
      );
      v4.execute(
        "INSERT INTO incident (id, assessment_id, seq, t_session_ms, wall_utc, period, phase_label, period_elapsed_ms, match_clock_ms, "
        "time_integrity, category, criterion_code, polarity, verdict, impact, impact_confirmed, source, status, updated_at) VALUES "
        "('inc-$aid', '$aid', 1, 1000, '2026-10-10T15:01:00Z', 'H1', 'IN_PLAY', 60000, 60000, 'OK', 'SCRUM', 'A1_SCRUM', 'REVIEW', "
        "'CORRECT', 'MEDIUM', 0, 'ONE_TAP', 'QUICK', 'x')",
      );
      v4.execute(
        "INSERT INTO report (assessment_id, version, referee_id, rubric_id, status, summary) VALUES ('$aid', 1, 'ref', '$kLegacyRubricV2Id', 'DRAFT', 'Resumen')",
      );
      v4.execute("INSERT INTO criterion_score (assessment_id, version, criterion_code, final_band, justification) VALUES ('$aid', 1, 'A1_SCRUM', 'ABOVE', 'Bien')");
      v4.execute("INSERT INTO finding (id, assessment_id, version, kind, criterion_code, text, position) VALUES ('f-$aid', '$aid', 1, 'STRENGTH', 'B4_ADVANTAGE', 'Ventaja', 1)");
      v4.execute(
        "INSERT INTO action_point (id, referee_id, origin_assessment_id, origin_version, criterion_code, text, success_indicator, status, created_at) "
        "VALUES ('ap-$aid', 'ref', '$aid', 1, 'C1_LAW_ACCURACY', 'Repasar la ley 12', 'Sin errores', 'DRAFT', 'x')",
      );
    }
    // El informe 'closed' se cierra con la rúbrica v2 (banda AT, huella del JSON firmado).
    const signed = '{"band":"AT","version":1}';
    final hash = sha256.convert(utf8.encode(signed)).toString();
    v4.execute(
      "UPDATE report SET status = 'FINALIZED', band = 'AT', finalized_at = '2026-10-11T10:00:00Z', canonical_json = ?, content_hash = ? WHERE assessment_id = 'closed'",
      [signed, hash],
    );
    v4.execute("UPDATE action_point SET status = 'OPEN' WHERE id = 'ap-closed'");
    v4.execute("UPDATE assessment SET status = 'FINALIZED' WHERE id = 'closed'");
    expect(v4.userVersion, 4);
    v4.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    expect((await db.customSelect('PRAGMA user_version').getSingle()).data.values.single, 5);

    // Cerrado: intacto (banda v2, huella, incidencias) y se abre con la rúbrica v2.
    final closedReport = await (db.select(db.report)..where((t) => t.assessmentId.equals('closed'))).getSingle();
    expect((closedReport.status, closedReport.band, closedReport.contentHash), ('FINALIZED', 'AT', hash));
    final closedAssessment = await (db.select(db.assessment)..where((t) => t.id.equals('closed'))).getSingle();
    expect(rubricById(closedAssessment.rubricId), same(kLegacyRubricV2));
    final closedIncident = await (db.select(db.incident)..where((t) => t.id.equals('inc-closed'))).getSingle();
    expect(closedIncident.criterionCode, 'A1_SCRUM');
    final closedSnap = await DriftEvaluationRepository(db).loadEvaluation('closed');
    expect(closedSnap.finalized!.band, BandCode.competent, reason: 'AT se lee como C');
    expect(closedSnap.evaluations['A1_SCRUM']!.finalBand, BandCode.excellent, reason: 'ABOVE se lee como E');
    // El trigger de inmutabilidad sobrevive a la reconstrucción de la tabla.
    await expectLater(
      db.customStatement("UPDATE report SET summary = 'x' WHERE assessment_id = 'closed'"),
      throwsA(predicate((e) => '$e'.contains('REPORT_LOCKED'))),
    );

    // Abierto: pasa al CARC.
    final open = await (db.select(db.assessment)..where((t) => t.id.equals('open'))).getSingle();
    expect(open.rubricId, kDefaultRubric.id);
    expect((await (db.select(db.incident)..where((t) => t.id.equals('inc-open'))).getSingle()).criterionCode, 'D2_SCRUM_SEQUENCE_SAFETY');
    expect(await (db.select(db.criterionScore)..where((t) => t.assessmentId.equals('open'))).get(), isEmpty,
        reason: 'las bandas eran de otros criterios: se valoran de nuevo');
    expect((await (db.select(db.finding)..where((t) => t.id.equals('f-open'))).getSingle()).criterionCode, 'C3_ADVANTAGE_CONSISTENCY');
    final aps = {for (final a in await db.select(db.actionPoint).get()) a.id: a.criterionCode};
    expect(aps, {'ap-closed': 'C2_MATERIAL_EFFECT', 'ap-open': 'C2_MATERIAL_EFFECT'});
    final openSnap = await DriftEvaluationRepository(db).loadEvaluation('open');
    expect((openSnap.summary, openSnap.estimatedDifficulty, openSnap.actualDifficulty), ('Resumen', 'HIGH', null));

    // La escala nueva, la dificultad real y la recomendación caben en las tablas reconstruidas.
    await db.customStatement(
      "INSERT INTO criterion_score (assessment_id, version, criterion_code, suggested_band, final_band, cap_band) VALUES ('open', 1, 'F3_MATCH_CONTROL', 'U', 'E', 'N')",
    );
    await db.customStatement("UPDATE report SET band = 'C', actual_difficulty = 'LOW', level_recommendation = 'UP' WHERE assessment_id = 'open'");
    await expectLater(db.customStatement("UPDATE report SET band = 'X' WHERE assessment_id = 'open'"), throwsA(isA<Exception>()));

    // Preferencias: el idioma se guarda y se recupera.
    final settings = DriftSettingsRepository(db);
    expect(await settings.loadLanguage(), AppLanguage.es);
    await settings.saveLanguage(AppLanguage.ca);
    expect(await settings.loadLanguage(), AppLanguage.ca);
  });
}
