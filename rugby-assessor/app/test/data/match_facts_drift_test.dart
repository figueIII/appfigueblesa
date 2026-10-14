import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/data/db/app_database.dart' hide ScoreEvent;
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

/// Una sanción es una incidencia con la decisión tomada contra el equipo infractor.
d.Incident sanctionMark(String a, int seq, d.TeamSide team, SanctionKind kind, [InfractionRef? why]) =>
    incident(a, seq, seq * 1000, categoryForSanction(kind, why)).copyWith(
      decisionTaken: d.Decision(outcomes: [outcomeFor(kind)], againstTeam: team),
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

  test('una sanción es una incidencia con su decisión tomada: ida y vuelta, motivo y anulación', () async {
    await repo.insertIncident(sanctionMark(id, 1, d.TeamSide.home, SanctionKind.penalty, InfractionRef.catalog('SIDE_ENTRY')));
    await repo.insertIncident(sanctionMark(id, 2, d.TeamSide.away, SanctionKind.freeKick, InfractionRef.custom('Avance intencionado', lawRef: 'Ley 11')));
    final open = sanctionMark(id, 3, d.TeamSide.away, SanctionKind.yellowCard);
    await repo.insertIncident(open);
    await repo.updateIncident(open.copyWith(infraction: InfractionRef.catalog('HIGH_TACKLE')));
    final last = sanctionMark(id, 4, d.TeamSide.home, SanctionKind.redCard);
    await repo.insertIncident(last);
    await repo.updateIncident(last.copyWith(status: d.IncidentStatus.voided));

    final snap = await repo.load(id);
    expect(snap.incidents.length, 4, reason: 'cada sanción es una marca');
    expect(snap.incidents.first.category, d.IncidentCategory.ruck);
    expect(snap.incidents[2].category, d.IncidentCategory.card);
    final s = sanctionsOf(snap.incidents);
    expect(s.map((e) => e.kind), [SanctionKind.penalty, SanctionKind.freeKick, SanctionKind.yellowCard, SanctionKind.redCard]);
    expect(s[0].infraction, InfractionRef.catalog('SIDE_ENTRY'));
    expect(s[1].infraction!.lawRef, 'Ley 11');
    expect(s[2].infraction!.label, 'Placaje alto / contacto con la cabeza');
    expect(s[3].voided, isTrue);

    // Corregir la decisión en la revisión corrige el contador: ahora es un golpe franco.
    await repo.saveEnrichment(snap.incidents.first.copyWith(
      verdict: d.Verdict.incorrect,
      decisionTaken: const d.Decision(outcomes: [d.DecisionOutcome.freeKick], againstTeam: d.TeamSide.home),
    ));
    final tally = SanctionTally(sanctionsOf((await repo.load(id)).incidents));
    expect(tally.count(d.TeamSide.home, SanctionKind.penalty), 0);
    expect(tally.count(d.TeamSide.home, SanctionKind.freeKick), 1);
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
  });

  test('con la evaluación finalizada, el marcador queda congelado', () async {
    await repo.insertScoreEvent(score(id, 1, d.TeamSide.home, ScoreKind.tryScored));
    await db.customStatement("UPDATE assessment SET status = 'FINALIZED' WHERE id = '$id'");
    await expectLater(repo.insertScoreEvent(score(id, 2, d.TeamSide.away, ScoreKind.dropGoal)), throwsA(isA<Exception>()));
    await expectLater(repo.voidScoreEvent(score(id, 1, d.TeamSide.home, ScoreKind.tryScored)), throwsA(isA<Exception>()));
    expect(await stored(), (5, 0));
  });

  test('migración v2 → v4: los partidos ya guardados en el móvil se conservan y ganan marcador y sanciones', () async {
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
    await r.insertIncident(sanctionMark('old', 2, d.TeamSide.home, SanctionKind.penalty, InfractionRef.catalog('SCRUM_COLLAPSING')));
    await r.updateIncident(snap.incidents.single.copyWith(infraction: InfractionRef.catalog('SCRUM_COLLAPSING')));
    final after = await r.load('old');
    expect(scorelineOf(after.scores), const Scoreline(0, 5));
    expect(sanctionsOf(after.incidents).single.infraction!.code, 'SCRUM_COLLAPSING');
    expect(after.incidents.first.infraction!.code, 'SCRUM_COLLAPSING');
    final version = await migrated.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 4);
    // Los triggers nuevos también existen tras migrar.
    await expectLater(migrated.customStatement("DELETE FROM score_event WHERE assessment_id = 'old'"), throwsA(isA<Exception>()));
  });

  test('migración v3 → v4: cada sanción guardada pasa a ser una marca valorable (y un partido cerrado no se reabre)', () async {
    final dir = Directory.systemTemp.createTempSync('refassess_migr3_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/v3.sqlite');
    // Base de datos v3 tal y como la dejó la versión 1.1.0 (sanciones en sanction_event).
    final v3 = raw.sqlite3.open(file.path);
    v3.execute(File('test/data/fixtures/schema_v3.sql').readAsStringSync());
    v3.execute("INSERT INTO official VALUES ('ref', 'Árbitro', NULL, NULL, NULL, 'x', 'x')");
    v3.execute("INSERT INTO assessor_profile VALUES ('ev', 'Evaluador', NULL, NULL)");
    v3.execute("INSERT INTO rubric VALUES ('rb', 'RUGBY-XV-BASE', '2.0.0', 'PUBLISHED', '{}')");
    const cat = '{"code":"M18","name":"M18","format":"XV","periodLengthMin":35,"sinBinMin":5}';
    for (final (aid, status) in const [('live', 'LIVE'), ('closed', 'POST_MATCH')]) {
      v3.execute(
        "INSERT INTO assessment (id, status, rubric_id, assessor_id, referee_id, competition, kickoff_local, kickoff_tz, venue, "
        "home_team, away_team, observation_mode, category_code, category_json, created_at, updated_at) VALUES "
        "('$aid', '$status', 'rb', 'ev', 'ref', 'Liga', '2026-10-10T17:00', 'Europe/Madrid', 'Campo', 'Local', 'Visitante', 'LIVE', "
        "'M18', '$cat', 'x', 'x')",
      );
    }
    v3.execute(
      "INSERT INTO incident (id, assessment_id, seq, t_session_ms, wall_utc, period, phase_label, period_elapsed_ms, match_clock_ms, "
      "time_integrity, category, criterion_code, polarity, verdict, impact, impact_confirmed, source, status, updated_at) VALUES "
      "('inc', 'live', 1, 1000, '2026-10-10T15:01:00Z', 'H1', 'IN_PLAY', 60000, 60000, 'OK', 'SCRUM', 'A1_SCRUM', 'REVIEW', 'PENDING', 'MEDIUM', 0, 'ONE_TAP', 'QUICK', 'x')",
    );
    void sanctionRow(String sid, String aid, int seq, String team, String kind, int t, String status, [String? code, String? custom, String? lawRef]) => v3.execute(
          'INSERT INTO sanction_event (id, assessment_id, seq, team, kind, infraction_code, infraction_custom, infraction_law_ref, '
          't_session_ms, wall_utc, period, match_clock_ms, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [sid, aid, seq, team, kind, code, custom, lawRef, t, '2026-10-10T15:00:00Z', 'H1', t, status],
        );
    sanctionRow('k1', 'live', 1, 'HOME', 'PENALTY', 120000, 'ACTIVE', 'SIDE_ENTRY');
    sanctionRow('k2', 'live', 2, 'AWAY', 'YELLOW_CARD', 180000, 'ACTIVE', 'CUSTOM', 'Avance intencionado', 'Ley 11');
    sanctionRow('k3', 'live', 3, 'HOME', 'FREE_KICK', 240000, 'VOID');
    sanctionRow('k9', 'closed', 1, 'AWAY', 'PENALTY', 60000, 'ACTIVE', 'HANDS_IN_RUCK');
    v3.execute("UPDATE assessment SET status = 'FINALIZED' WHERE id = 'closed'"); // cerrado después
    expect(v3.userVersion, 3);
    v3.close();

    final migrated = AppDatabase(NativeDatabase(file));
    addTearDown(migrated.close);
    final r = DriftLiveSessionRepository(migrated);
    final live = (await r.load('live')).incidents;
    expect(live.map((i) => i.seq), [1, 2, 3, 4], reason: 'las sanciones se añaden detrás de las marcas existentes');
    final k1 = live[1], k2 = live[2], k3 = live[3];
    expect(k1.id, 'k1');
    expect(k1.category, d.IncidentCategory.ruck);
    expect(k1.decisionTaken, const d.Decision(outcomes: [d.DecisionOutcome.penalty], againstTeam: d.TeamSide.home));
    expect(k1.infraction, InfractionRef.catalog('SIDE_ENTRY'));
    expect(k1.verdict, d.Verdict.pending, reason: 'queda por valorar: ¿estuvo bien pitado?');
    expect(k1.matchTime.matchClockMs, 120000);
    expect(k2.category, d.IncidentCategory.card);
    expect(k2.infraction!.label, 'Avance intencionado');
    expect(k2.infraction!.lawRef, 'Ley 11');
    expect(k3.isVoid, isTrue);
    final tally = SanctionTally(sanctionsOf(live));
    expect(tally.count(d.TeamSide.home, SanctionKind.penalty), 1);
    expect(tally.count(d.TeamSide.away, SanctionKind.yellowCard), 1);
    expect(tally.count(d.TeamSide.home, SanctionKind.freeKick), 0);

    final closed = (await r.load('closed')).incidents.single;
    expect(closed.verdict, d.Verdict.notAssessable, reason: 'un informe cerrado no se reabre');

    final gone = await migrated.customSelect("SELECT name FROM sqlite_master WHERE name LIKE 'sanction_event%'").get();
    expect(gone, isEmpty, reason: 'la tabla y sus triggers desaparecen');
    expect((await migrated.customSelect('PRAGMA user_version').getSingle()).data.values.single, 4);
  });
}
