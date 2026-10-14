import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/core/platform_ports.dart';
import 'package:ref_assess/data/db/app_database.dart';
import 'package:ref_assess/data/drift_live_session_repository.dart';
import 'package:ref_assess/data/live_session_repository.dart';
import 'package:ref_assess/data/session_time.dart';
import 'package:ref_assess/domain/category_presets.dart';
import 'package:ref_assess/domain/clock.dart' as d;
import 'package:ref_assess/domain/model.dart' as d;

class SeqIds implements IdGenerator {
  int n = 0;
  @override
  String next() => 'id-${++n}';
}

final wall0 = DateTime.utc(2026, 10, 17, 15);
TimeSample at(int t) => TimeSample(sessionMs: t, monoMs: 1000 + t, bootId: 'boot-A', wallUtc: wall0.add(Duration(milliseconds: t)));

d.Incident incident(String assessmentId, int seq, int t, d.IncidentCategory c) => d.Incident(
      id: 'inc-$seq',
      assessmentId: assessmentId,
      seq: seq,
      sessionMs: t,
      wallUtc: wall0.add(Duration(milliseconds: t)),
      matchTime: d.MatchTimeStamp(
        period: d.PeriodId.h1,
        phase: d.MatchPhaseLabel.inPlay,
        periodElapsedMs: t,
        matchClockMs: t,
        overtimeMs: 0,
        integrity: d.TimeIntegrity.ok,
      ),
      category: c,
      criterionCode: d.kCategoryToCriterion[c]!,
      polarity: d.QuickPolarity.review,
      verdict: d.Verdict.pending,
      impact: d.ImpactLevel.medium,
      impactConfirmed: false,
      status: d.IncidentStatus.quick,
    );

void main() {
  late Directory tmp;
  late File file;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('refassess_');
    file = File('${tmp.path}/refassess.sqlite');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  AppDatabase open() => AppDatabase(NativeDatabase(file));

  Future<String> seed(AppDatabase db) => AssessmentSetup(db, SeqIds()).createLiveAssessment(
        category: categoryPreset('M16'),
        competition: 'Liga M16',
        venue: 'Campo Municipal',
        homeTeam: 'Local',
        awayTeam: 'Visitante',
        refereeName: 'Árbitro',
        assessorName: 'Evaluador',
        kickoffLocal: DateTime(2026, 10, 17, 17),
      );

  test('al abrir: foreign_keys=ON, WAL y synchronous=FULL (durabilidad ante apagado)', () async {
    final db = open();
    await seed(db);
    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    final sync = await db.customSelect('PRAGMA synchronous').getSingle();
    final journal = await db.customSelect('PRAGMA journal_mode').getSingle();
    expect(fk.data.values.single, 1);
    expect(sync.data.values.single, 2, reason: '2 = FULL');
    expect(journal.data.values.single, 'wal');
    await db.close();
  });

  test('ida y vuelta completa tras cerrar y reabrir el archivo (cierre de la app)', () async {
    var db = open();
    final id = await seed(db);
    var repo = DriftLiveSessionRepository(db);
    final cat = categoryPreset('M16');

    var log = d.appendClockEvent(const [], const d.PeriodStart(d.PeriodId.h1), 0, cat);
    await repo.appendClockEvent(id, log.last, at(0), AssessmentPhase.live);
    log = d.appendClockEvent(log, const d.TimeOff(), 600000, cat);
    await repo.appendClockEvent(id, log.last, at(600000), AssessmentPhase.live);
    log = d.appendClockEvent(log, const d.Adjust(-5000), 610000, cat);
    await repo.appendClockEvent(id, log.last, at(610000), AssessmentPhase.live);

    final i1 = incident(id, 1, 120000, d.IncidentCategory.knockOnForwardPass);
    final i2 = incident(id, 2, 300000, d.IncidentCategory.captainMgmt);
    await repo.insertIncident(i1);
    await repo.insertIncident(i2);
    await repo.updateIncident(i1.copyWith(polarity: d.QuickPolarity.positive, verdict: d.Verdict.correct, impact: d.ImpactLevel.low));
    await repo.updateIncident(i2.copyWith(status: d.IncidentStatus.voided));
    await db.close();

    db = open();
    repo = DriftLiveSessionRepository(db);
    final snap = await repo.load(id);
    expect(snap.category.code, 'M16');
    expect(snap.category.periodLengthMin, 35);
    expect(snap.category.sinBinMin, 5);
    expect((snap.homeTeam, snap.awayTeam), ('Local', 'Visitante'));
    expect(snap.clockLog.map((e) => (e.seq, e.t, e.body.runtimeType)).toList(), [
      (1, 0, d.PeriodStart),
      (2, 600000, d.TimeOff),
      (3, 610000, d.Adjust),
    ]);
    expect((snap.clockLog[2].body as d.Adjust).deltaMs, -5000);
    final state = d.foldClock(snap.clockLog, snap.category);
    expect(state.status, d.ClockStatus.stopped);
    expect(state.accumulatedMs, 595000);

    expect(snap.incidents.map((i) => (i.id, i.category, i.polarity, i.verdict, i.status)).toList(), [
      ('inc-1', d.IncidentCategory.knockOnForwardPass, d.QuickPolarity.positive, d.Verdict.correct, d.IncidentStatus.quick),
      ('inc-2', d.IncidentCategory.captainMgmt, d.QuickPolarity.review, d.Verdict.pending, d.IncidentStatus.voided),
    ]);
    expect(snap.incidents.first.wallUtc, wall0.add(const Duration(milliseconds: 120000)));

    final revisions = await db.select(db.incidentRevision).get();
    expect(revisions.length, 2, reason: 'el trigger incident_audit guarda la versión anterior en cada edición');
    final ev = await db.select(db.clockEvent).get();
    expect((ev.first.bootId, ev.first.monoMs), ('boot-A', 1000), reason: 'origen crudo del instante, para auditoría');
    await db.close();
  });

  test('el estado de la evaluación sigue al reloj en la misma transacción', () async {
    final db = open();
    final id = await seed(db);
    final repo = DriftLiveSessionRepository(db);
    final cat = categoryPreset('M16');
    Future<String> status() async => (await (db.select(db.assessment)..where((t) => t.id.equals(id))).getSingle()).status;

    expect(await status(), 'READY');
    var log = d.appendClockEvent(const [], const d.PeriodStart(d.PeriodId.h1), 0, cat);
    await repo.appendClockEvent(id, log.last, at(0), AssessmentPhase.live);
    expect(await status(), 'LIVE');
    log = d.appendClockEvent(log, const d.PeriodEnd(d.PeriodEndNext.interval), 2100000, cat);
    log = d.appendClockEvent(log, const d.PeriodStart(d.PeriodId.h2), 2700000, cat);
    log = d.appendClockEvent(log, const d.PeriodEnd(d.PeriodEndNext.fullTime), 4900000, cat);
    await repo.appendClockEvent(id, log.last, at(4900000), AssessmentPhase.postMatch);
    expect(await status(), 'POST_MATCH');
    expect(await AssessmentSetup(db, SeqIds()).latestOpenAssessment(), id, reason: 'POST_MATCH sigue abierta: falta revisar y evaluar');
    await db.customStatement("UPDATE assessment SET status = 'FINALIZED' WHERE id = '$id'");
    expect(await AssessmentSetup(db, SeqIds()).latestOpenAssessment(), isNull);
    await db.close();
  });

  test('la base de datos impone las reglas: log de reloj append-only, FK y enumerados', () async {
    final db = open();
    final id = await seed(db);
    final repo = DriftLiveSessionRepository(db);
    final log = d.appendClockEvent(const [], const d.PeriodStart(d.PeriodId.h1), 0, categoryPreset('M16'));
    await repo.appendClockEvent(id, log.last, at(0), AssessmentPhase.live);

    await expectLater(db.customStatement('UPDATE clock_event SET t_session_ms = 5'), throwsA(predicate((e) => '$e'.contains('CLOCK_LOG_APPEND_ONLY'))));
    await expectLater(db.customStatement('DELETE FROM clock_event'), throwsA(predicate((e) => '$e'.contains('CLOCK_LOG_APPEND_ONLY'))));
    await expectLater(repo.insertIncident(incident('no-existe', 1, 0, d.IncidentCategory.ruck)), throwsA(anything));
    await expectLater(
      db.into(db.incident).insert(IncidentCompanion.insert(
            id: 'x', assessmentId: id, seq: 9, tSessionMs: 0, wallUtc: 't', phaseLabel: 'IN_PLAY', periodElapsedMs: 0,
            matchClockMs: 0, timeIntegrity: 'OK', category: 'RUCK', criterionCode: 'A3_TACKLE_RUCK', polarity: 'MAYBE',
            verdict: 'PENDING', impact: 'MEDIUM', impactConfirmed: 0, source: 'ONE_TAP', status: 'QUICK', updatedAt: 't',
            period: const Value('H1'),
          )),
      throwsA(predicate((e) => '$e'.contains('CHECK constraint failed'))),
    );
    await expectLater(repo.updateIncident(incident(id, 7, 0, d.IncidentCategory.ruck)), throwsStateError);
    await db.close();
  });

  test('anclas y último instante guardado', () async {
    final db = open();
    final id = await seed(db);
    final repo = DriftLiveSessionRepository(db);
    expect(await repo.lastTimePoint(id), isNull);
    await repo.insertAnchor(id, SessionAnchor(bootId: 'A', monoAtAnchor: 10, sessionAtAnchor: 0, wallUtcAtAnchor: wall0, estimated: false));
    final log = d.appendClockEvent(const [], const d.PeriodStart(d.PeriodId.h1), 1000, categoryPreset('M16'));
    await repo.appendClockEvent(id, log.last, at(1000), AssessmentPhase.live);
    await repo.insertIncident(incident(id, 1, 7000, d.IncidentCategory.ruck));
    final p = await repo.lastTimePoint(id);
    expect((p!.sessionMs, p.wallUtc), (7000, wall0.add(const Duration(seconds: 7))));
    final anchors = await repo.loadAnchors(id);
    expect((anchors.single.bootId, anchors.single.monoAtAnchor, anchors.single.estimated), ('A', 10, false));
    await db.close();
  });

  test('revisión: el enriquecimiento completo sobrevive a cerrar y reabrir; anular guarda el motivo', () async {
    var db = open();
    final id = await seed(db);
    var repo = DriftLiveSessionRepository(db);
    final base = incident(id, 1, 120000, d.IncidentCategory.scrum);
    await repo.insertIncident(base);
    await repo.insertIncident(incident(id, 2, 130000, d.IncidentCategory.ruck));
    final enriched = base.copyWith(
      verdict: d.Verdict.incorrect,
      polarity: d.QuickPolarity.negative,
      impact: d.ImpactLevel.matchDefining,
      impactConfirmed: true,
      criterionCode: 'D2_POSITIONING',
      gamePhase: d.GamePhase.setPiece,
      fieldZone: d.FieldZone.opp22,
      decisionTaken: const d.Decision(outcomes: [d.DecisionOutcome.playOn]),
      decisionExpected: const d.Decision(
        outcomes: [d.DecisionOutcome.penalty, d.DecisionOutcome.yellowCard],
        againstTeam: d.TeamSide.away,
        lawRef: '19.10',
      ),
      notes: '  Colapso intencionado en 5 m.  ',
      status: d.IncidentStatus.enriched,
    );
    await repo.saveEnrichment(enriched);
    final second = (await repo.loadReview(id)).incidents[1];
    await repo.voidIncident(second, 'REVIEW');
    await db.close();

    db = open();
    repo = DriftLiveSessionRepository(db);
    final r = await repo.loadReview(id);
    final got = r.incidents.first;
    expect(got.sameContentAs(enriched.copyWith(notes: 'Colapso intencionado en 5 m.')), isTrue, reason: 'notas recortadas, resto idéntico');
    expect(got.decisionExpected!.outcomes, [d.DecisionOutcome.penalty, d.DecisionOutcome.yellowCard]);
    expect(r.incidents[1].status, d.IncidentStatus.voided);
    final row = await (db.select(db.incident)..where((t) => t.seq.equals(2))).getSingle();
    expect(row.voidReason, 'REVIEW');
    final json = (await (db.select(db.incident)..where((t) => t.seq.equals(1))).getSingle()).decisionExpectedJson;
    expect(json, '{"outcomes":["PENALTY","YELLOW_CARD"],"againstTeam":"AWAY","lawRef":"19.10"}', reason: 'mismo formato que Decision en model.ts');
    await db.close();
  });

  test('schema.drift es copia literal de persistence/schema.sql (salvo PRAGMAs y nombres Dart)', () {
    List<String> statements(String sql) => sql
        .split('\n')
        .where((l) => !l.startsWith('PRAGMA'))
        .map((l) => l.replaceAll(RegExp(r'--.*$'), '').replaceAll(' AS bodyText,', ',').trimRight())
        .join('\n')
        .split(';')
        .map((s) => s.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final sql = statements(File('../persistence/schema.sql').readAsStringSync());
    final drift = statements(File('lib/data/db/schema.drift').readAsStringSync());
    expect(drift, sql);
  });
}
