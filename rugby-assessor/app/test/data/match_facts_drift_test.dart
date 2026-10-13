import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/data/db/app_database.dart' hide ScoreEvent, SanctionEvent;
import 'package:ref_assess/data/drift_live_session_repository.dart';
import 'package:ref_assess/domain/category_presets.dart';
import 'package:ref_assess/domain/laws.dart';
import 'package:ref_assess/domain/match_facts.dart';
import 'package:ref_assess/domain/model.dart' as d;
import 'package:sqlite3/sqlite3.dart' as raw;

import 'drift_repository_test.dart' show SeqIds, incident;

ScoreEvent score(String a, int seq, d.TeamSide team, ScoreKind kind) => ScoreEvent(
      id: '$a-s$seq',
      assessmentId: a,
      seq: seq,
      team: team,
      kind: kind,
      sessionMs: seq * 1000,
      wallUtc: DateTime.utc(2026, 10, 17, 15, seq),
      period: d.PeriodId.h1,
      matchClockMs: seq * 60000,
    );

SanctionEvent sanction(String a, int seq, d.TeamSide team, SanctionKind kind, [InfractionRef? why]) => SanctionEvent(
      id: '$a-k$seq',
      assessmentId: a,
      seq: seq,
      team: team,
      kind: kind,
      sessionMs: seq * 1000,
      wallUtc: DateTime.utc(2026, 10, 17, 15, seq),
      period: d.PeriodId.h2,
      matchClockMs: seq * 60000,
      infraction: why,
    );

void main() {
  late AppDatabase db;
  late DriftLiveSessionRepository repo;
  late String id;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftLiveSessionRepository(db);
    id = await AssessmentSetup(db, SeqIds()).createLiveAssessment(
      category: categoryPreset('M18'),
      competition: 'Liga',
      venue: 'Campo',
      homeTeam: 'Local',
      awayTeam: 'Visitante',
      refereeName: 'Árbitro',
      assessorName: 'Evaluador',
      kickoffLocal: DateTime(2026, 10, 17, 17),
    );
  });
  tearDown(() => db.close());

  Future<(int?, int?)> stored() async {
    final a = await (db.select(db.assessment)..where((t) => t.id.equals(id))).getSingle();
    return (a.finalScoreHome, a.finalScoreAway);
  }

  test('cada tanto (y cada anulación) actualiza el resultado del partido en la misma transacción', () async {
    expect(await stored(), (null, null), reason: 'sin tantos todavía');
    final t = score(id, 1, d.TeamSide.home, ScoreKind.tryScored);
    await repo.insertScoreEvent(t);
    expect(await stored(), (5, 0));
    await repo.insertScoreEvent(score(id, 2, d.TeamSide.home, ScoreKind.conversion));
    await repo.insertScoreEvent(score(id, 3, d.TeamSide.away, ScoreKind.penaltyGoal));
    expect(await stored(), (7, 3));
    await repo.voidScoreEvent(t);
    expect(await stored(), (2, 3), reason: 'el ensayo anulado deja de sumar');

    final snap = await repo.load(id);
    expect(snap.scores.map((e) => e.kind), [ScoreKind.tryScored, ScoreKind.conversion, ScoreKind.penaltyGoal]);
    expect(snap.scores.first.voided, isTrue);
    expect(snap.scores[2].team, d.TeamSide.away);
    expect(scorelineOf(snap.scores), const Scoreline(2, 3));
  });

  test('sanciones: ida y vuelta con motivo de catálogo, personalizado y sin especificar; completar y anular', () async {
    await repo.insertSanction(sanction(id, 1, d.TeamSide.home, SanctionKind.penalty, InfractionRef.catalog('SIDE_ENTRY')));
    await repo.insertSanction(sanction(id, 2, d.TeamSide.away, SanctionKind.freeKick, InfractionRef.custom('Avance intencionado', lawRef: 'Ley 11')));
    final open = sanction(id, 3, d.TeamSide.away, SanctionKind.yellowCard);
    await repo.insertSanction(open);
    await repo.updateSanction(open.copyWith(infraction: InfractionRef.catalog('HIGH_TACKLE')));
    final last = sanction(id, 4, d.TeamSide.home, SanctionKind.redCard);
    await repo.insertSanction(last);
    await repo.updateSanction(last.copyWith(voided: true));

    final s = (await repo.load(id)).sanctions;
    expect(s.map((e) => e.kind), [SanctionKind.penalty, SanctionKind.freeKick, SanctionKind.yellowCard, SanctionKind.redCard]);
    expect(s[0].infraction, InfractionRef.catalog('SIDE_ENTRY'));
    expect(s[1].infraction!.label, 'Avance intencionado');
    expect(s[1].infraction!.lawRef, 'Ley 11');
    expect(s[2].infraction!.label, 'Placaje alto / contacto con la cabeza');
    expect(s[2].period, d.PeriodId.h2);
    expect(s[3].voided, isTrue);
    expect(s[3].infraction, isNull);
  });

  test('infracción de una incidencia: se guarda desde el directo y desde la revisión', () async {
    final i = incident(id, 1, 1000, d.IncidentCategory.ruck);
    await repo.insertIncident(i.copyWith(infraction: InfractionRef.catalog('HANDS_IN_RUCK')));
    expect((await repo.load(id)).incidents.single.infraction, InfractionRef.catalog('HANDS_IN_RUCK'));
    await repo.updateIncident(i.copyWith(infraction: InfractionRef.catalog('NOT_RELEASING')));
    expect((await repo.load(id)).incidents.single.infraction!.code, 'NOT_RELEASING');
    await repo.saveEnrichment(i.copyWith(verdict: d.Verdict.correct, infraction: InfractionRef.custom('Juego peligroso en el suelo')));
    final saved = (await repo.load(id)).incidents.single;
    expect(saved.infraction!.isCustom, isTrue);
    expect(saved.infraction!.label, 'Juego peligroso en el suelo');
    final audit = await db.customSelect("SELECT previous_json FROM incident_revision WHERE incident_id = '${i.id}'").get();
    expect(audit.last.read<String>('previous_json'), contains('NOT_RELEASING'), reason: 'la auditoría guarda la infracción anterior');
  });

  test('la base de datos impone solo inserción: ni borrar, ni cambiar el tanto, ni reactivar lo anulado', () async {
    final t = score(id, 1, d.TeamSide.home, ScoreKind.tryScored);
    await repo.insertScoreEvent(t);
    await expectLater(db.customStatement("DELETE FROM score_event WHERE id = '${t.id}'"), throwsA(isA<Exception>()));
    await expectLater(db.customStatement("UPDATE score_event SET kind = 'DROP_GOAL', points = 3 WHERE id = '${t.id}'"), throwsA(isA<Exception>()));
    await repo.voidScoreEvent(t);
    await expectLater(db.customStatement("UPDATE score_event SET status = 'ACTIVE' WHERE id = '${t.id}'"), throwsA(isA<Exception>()));
    await expectLater(
      db.customStatement(
        "INSERT INTO score_event VALUES ('x', '$id', 9, 'HOME', 'TRY', 7, 0, '2026-10-17T15:00:00Z', 'H1', 0, 'ACTIVE')",
      ),
      throwsA(isA<Exception>()),
      reason: 'un ensayo vale 5',
    );
    final k = sanction(id, 1, d.TeamSide.away, SanctionKind.penalty);
    await repo.insertSanction(k);
    await expectLater(db.customStatement("UPDATE sanction_event SET team = 'HOME' WHERE id = '${k.id}'"), throwsA(isA<Exception>()));
    await expectLater(db.customStatement("DELETE FROM sanction_event WHERE id = '${k.id}'"), throwsA(isA<Exception>()));
  });

  test('con la evaluación finalizada, marcador y sanciones quedan congelados', () async {
    await repo.insertScoreEvent(score(id, 1, d.TeamSide.home, ScoreKind.tryScored));
    await db.customStatement("UPDATE assessment SET status = 'FINALIZED' WHERE id = '$id'");
    await expectLater(repo.insertScoreEvent(score(id, 2, d.TeamSide.away, ScoreKind.dropGoal)), throwsA(isA<Exception>()));
    await expectLater(repo.voidScoreEvent(score(id, 1, d.TeamSide.home, ScoreKind.tryScored)), throwsA(isA<Exception>()));
    await expectLater(repo.insertSanction(sanction(id, 1, d.TeamSide.home, SanctionKind.penalty)), throwsA(isA<Exception>()));
    expect(await stored(), (5, 0));
  });

  test('migración v2 → v3: los partidos ya guardados en el móvil se conservan y ganan marcador y sanciones', () async {
    final dir = Directory.systemTemp.createTempSync('refassess_migr_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/v2.sqlite');
    // Base de datos v2 tal y como la dejó la versión 1.0.0 de la app.
    final v2 = raw.sqlite3.open(file.path);
    v2.execute(File('test/data/fixtures/schema_v2.sql').readAsStringSync());
    v2.execute("INSERT INTO official VALUES ('ref', 'Árbitro', NULL, NULL, NULL, 'x', 'x')");
    v2.execute("INSERT INTO assessor_profile VALUES ('ev', 'Evaluador', NULL, NULL)");
    v2.execute("INSERT INTO rubric VALUES ('rb', 'RUGBY-XV-BASE', '2.0.0', 'PUBLISHED', '{}')");
    v2.execute(
      "INSERT INTO assessment (id, status, rubric_id, assessor_id, referee_id, competition, kickoff_local, kickoff_tz, venue, "
      "home_team, away_team, observation_mode, category_code, category_json, created_at, updated_at) VALUES "
      "('old', 'LIVE', 'rb', 'ev', 'ref', 'Liga', '2026-10-10T17:00', 'Europe/Madrid', 'Campo', 'Local', 'Visitante', 'LIVE', "
      "'M18', '{\"code\":\"M18\",\"name\":\"M18\",\"format\":\"XV\",\"periodLengthMin\":35,\"sinBinMin\":5}', 'x', 'x')",
    );
    v2.execute(
      "INSERT INTO incident (id, assessment_id, seq, t_session_ms, wall_utc, period, phase_label, period_elapsed_ms, match_clock_ms, "
      "time_integrity, category, criterion_code, polarity, verdict, impact, impact_confirmed, source, status, updated_at) VALUES "
      "('inc', 'old', 1, 1000, '2026-10-10T15:01:00Z', 'H1', 'IN_PLAY', 60000, 60000, 'OK', 'SCRUM', 'A1_SCRUM', 'REVIEW', 'PENDING', 'MEDIUM', 0, 'ONE_TAP', 'QUICK', 'x')",
    );
    expect(v2.userVersion, 2);
    v2.close();

    final migrated = AppDatabase(NativeDatabase(file));
    addTearDown(migrated.close);
    final r = DriftLiveSessionRepository(migrated);
    final snap = await r.load('old');
    expect(snap.incidents.single.category, d.IncidentCategory.scrum, reason: 'la marca de antes sigue ahí');
    expect(snap.incidents.single.infraction, isNull);
    expect(snap.scores, isEmpty);

    await r.insertScoreEvent(score('old', 1, d.TeamSide.away, ScoreKind.tryScored));
    await r.insertSanction(sanction('old', 1, d.TeamSide.home, SanctionKind.penalty, InfractionRef.catalog('SCRUM_COLLAPSING')));
    await r.updateIncident(snap.incidents.single.copyWith(infraction: InfractionRef.catalog('SCRUM_COLLAPSING')));
    final after = await r.load('old');
    expect(scorelineOf(after.scores), const Scoreline(0, 5));
    expect(after.sanctions.single.infraction!.code, 'SCRUM_COLLAPSING');
    expect(after.incidents.single.infraction!.code, 'SCRUM_COLLAPSING');
    final version = await migrated.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 3);
    // Los triggers nuevos también existen tras migrar.
    await expectLater(migrated.customStatement("DELETE FROM score_event WHERE assessment_id = 'old'"), throwsA(isA<Exception>()));
  });
}
