// Pantalla 3 sobre Drift con archivo real: borrador que sobrevive a cerrar la app, cierre en una
// transacción, inmutabilidad por trigger y seguimiento de recomendaciones entre partidos.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/core/platform_ports.dart';
import 'package:ref_assess/data/db/app_database.dart' hide Incident, Finding, ActionPoint, ActionPointReview;
import 'package:ref_assess/data/drift_evaluation_repository.dart';
import 'package:ref_assess/data/drift_live_session_repository.dart';
import 'package:ref_assess/domain/category_presets.dart';
import 'package:ref_assess/domain/model.dart';
import 'package:ref_assess/domain/report.dart';
import 'package:ref_assess/domain/rubric.dart';
import 'package:ref_assess/domain/rubric_default.dart';
import 'package:ref_assess/features/evaluation/evaluation_controller.dart';

class SeqIds implements IdGenerator {
  SeqIds(this.p);
  final String p;
  int n = 0;
  @override
  String next() => '$p-${++n}';
}

Incident incident(String assessmentId, int seq, IncidentCategory c, Verdict v, ImpactLevel impact) => Incident(
      id: '$assessmentId-inc-$seq',
      assessmentId: assessmentId,
      seq: seq,
      sessionMs: seq * 60000,
      wallUtc: DateTime.utc(2026, 10, 17, 15, seq),
      matchTime: MatchTimeStamp(period: PeriodId.h1, phase: MatchPhaseLabel.inPlay, periodElapsedMs: seq * 60000, matchClockMs: seq * 60000, overtimeMs: 0, integrity: TimeIntegrity.ok),
      category: c,
      criterionCode: kCategoryToCriterion[c]!,
      polarity: QuickPolarity.review,
      verdict: v,
      impact: impact,
      impactConfirmed: true,
      status: IncidentStatus.enriched,
      notes: 'nota',
      decisionExpected: const Decision(outcomes: [DecisionOutcome.penalty]),
    );

void main() {
  late Directory tmp;
  late File file;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('refassess_eval_');
    file = File('${tmp.path}/refassess.sqlite');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  Future<String> seedMatch(AppDatabase db, [String prefix = 'm']) async {
    final id = await AssessmentSetup(db, SeqIds(prefix)).createLiveAssessment(
      category: categoryPreset('SM_DHCAT_1_2_3'), competition: 'DHCAT', venue: 'Campo', homeTeam: 'Local', awayTeam: 'Visitante',
      refereeName: 'Árbitro', assessorName: 'Evaluador', kickoffLocal: DateTime(2026, 10, 17, 17),
    );
    final live = DriftLiveSessionRepository(db);
    await live.insertIncident(incident(id, 1, IncidentCategory.scrum, Verdict.missed, ImpactLevel.matchDefining));
    await live.insertIncident(incident(id, 2, IncidentCategory.tackle, Verdict.correct, ImpactLevel.medium));
    await db.customStatement("UPDATE assessment SET status = 'POST_MATCH' WHERE id = '$id'");
    return id;
  }

  EvaluationController controllerFor(AppDatabase db, String id) => EvaluationController(
        assessmentId: id,
        repository: DriftEvaluationRepository(db),
        rubric: kDefaultRubric,
        ids: SeqIds(id),
        now: () => DateTime.utc(2026, 10, 18, 9, 12),
        textDebounce: Duration.zero,
      );

  void completeAll(EvaluationController c) {
    for (final crit in kDefaultRubric.criteria) {
      c.setBand(crit.code, c.suggestions[crit.code]!.suggestedBand ?? BandCode.competent);
      c.setJustification(crit.code, 'Acorde a lo observado.');
    }
    c.setSummary('Resumen del partido.');
    c.updateFinding(c.addFinding(FindingKind.strength)!.id, text: 'Breakdown.');
    c.updateFinding(c.addFinding(FindingKind.development)!.id, text: 'Scrum.');
    final ap = c.addActionPoint()!;
    c.updateActionPoint(ap.id, text: 'Mejorar la lectura del scrum.', successIndicator: 'Sin colapsos sin sancionar.');
  }

  test('el borrador sobrevive a cerrar y reabrir la app', () async {
    var db = AppDatabase(NativeDatabase(file));
    final id = await seedMatch(db);
    var c = controllerFor(db, id);
    await c.load();
    c.setBand('D2_SCRUM_SEQUENCE_SAFETY', BandCode.excellent);
    c.setJustification('D2_SCRUM_SEQUENCE_SAFETY', 'Visto en vídeo: el colapso lo provocó el pilar local.');
    c.setNotObserved('D4_FAIR_CONTEST', true);
    c.setSummary('Borrador');
    c.updateFinding(c.addFinding(FindingKind.strength)!.id, text: 'Ventaja');
    await c.flush();
    c.dispose();
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    c = controllerFor(db, id);
    await c.load();
    expect(c.evaluationOf('D2_SCRUM_SEQUENCE_SAFETY')!.finalBand, BandCode.excellent);
    expect(c.evaluationOf('D2_SCRUM_SEQUENCE_SAFETY')!.justification, startsWith('Visto en vídeo'));
    expect(c.evaluationOf('D4_FAIR_CONTEST')!.notObserved, isTrue);
    expect(c.summary, 'Borrador');
    expect(c.findingsOf(FindingKind.strength).single.text, 'Ventaja');
    expect(c.suggestions['D2_SCRUM_SEQUENCE_SAFETY']!.capBand, BandCode.notYet, reason: 'la sugerencia se recalcula de las incidencias guardadas');
    final row = await (db.select(db.criterionScore)..where((t) => t.criterionCode.equals('D2_SCRUM_SEQUENCE_SAFETY'))).getSingle();
    expect((row.suggestedBand, row.finalBand, row.capBand), ('U', 'E', 'N')); // 25/7 = 3,57 ⇒ U (por debajo del tope)
    await db.close();
  });

  test('cierre: una transacción, hash verificable, inmutable y recomendaciones abiertas para el siguiente', () async {
    final db = AppDatabase(NativeDatabase(file));
    final id = await seedMatch(db);
    final c = controllerFor(db, id);
    await c.load();
    completeAll(c);
    c.setActualDifficulty('VERY_HIGH');
    c.setLevelRecommendation(LevelRecommendation.same);
    await c.finalize();

    final report = await (db.select(db.report)..where((t) => t.assessmentId.equals(id))).getSingle();
    expect(report.status, 'FINALIZED');
    expect(report.contentHash, sha256.convert(utf8.encode(report.canonicalJson!)).toString(), reason: 'el hash corresponde al JSON guardado');
    expect(report.contentHash, c.finalized!.contentHash);
    final signed = jsonDecode(report.canonicalJson!) as Map<String, dynamic>;
    expect(signed['band'], report.band);
    expect((signed['criterionScores'] as List).firstWhere((s) => s['criterionCode'] == 'D2_SCRUM_SEQUENCE_SAFETY')['capBand'], 'N');
    expect((signed['actualDifficulty'], signed['levelRecommendation']), ('VERY_HIGH', 'SAME'));
    expect((report.actualDifficulty, report.levelRecommendation), ('VERY_HIGH', 'SAME'));
    expect(await db.select(db.criterionScore).get(), hasLength(25));

    final aps = await db.select(db.actionPoint).get();
    expect(aps.single.status, 'OPEN');
    expect((await (db.select(db.assessment)..where((t) => t.id.equals(id))).getSingle()).status, 'FINALIZED');
    expect((await db.select(db.outbox).get()).single.kind, 'REPORT_FINALIZED');

    await expectLater(db.customStatement("UPDATE report SET summary = 'cambio'"), throwsA(predicate((e) => '$e'.contains('REPORT_LOCKED'))));
    await expectLater(db.customStatement("UPDATE incident SET notes = 'cambio'"), throwsA(predicate((e) => '$e'.contains('ASSESSMENT_LOCKED'))));
    await c.finalize(); // cerrar dos veces no hace nada
    expect((await (db.select(db.report)..where((t) => t.assessmentId.equals(id))).getSingle()).contentHash, report.contentHash);

    // Siguiente partido del MISMO árbitro: la recomendación aparece pendiente de revisar.
    final next = await seedMatch(db, 'n');
    await db.customStatement("UPDATE assessment SET referee_id = (SELECT referee_id FROM assessment WHERE id = '$id') WHERE id = '$next'");
    final c2 = controllerFor(db, next);
    await c2.load();
    expect(c2.openPrevious.single.text, 'Mejorar la lectura del scrum.');
    completeAll(c2);
    expect(c2.closeWarningsList.single.code, CloseIssueCode.previousActionPointNotReviewed);
    c2.setPreviousReview(c2.openPrevious.single.id, status: ActionPointReviewStatus.achieved);
    c2.setPreviousReview(c2.openPrevious.single.id, comment: 'Corregido.');
    await c2.finalize();
    final closed = await (db.select(db.actionPoint)..where((t) => t.id.equals(aps.single.id))).getSingle();
    expect((closed.status, closed.closedByAssessmentId), ('CLOSED', next));
    final review = await db.select(db.actionPointReview).getSingle();
    expect((review.status, review.comment), ('ACHIEVED', 'Corregido.'));
    await db.close();
  });

  test('se puede cerrar sin valorar nada: sin justificaciones, sin resumen, sin fortalezas ni recomendaciones', () async {
    final db = AppDatabase(NativeDatabase(file));
    final id = await seedMatch(db);
    final c = controllerFor(db, id);
    await c.load();
    c.setBand('E2_TACKLER_TACKLED', BandCode.competent); // una sola competencia, sin justificar
    c.addFinding(FindingKind.strength); // hueco vacío: se descarta al cerrar
    c.addActionPoint();
    await c.finalize();
    expect(c.isFinalized, isTrue);
    final report = await (db.select(db.report)..where((t) => t.assessmentId.equals(id))).getSingle();
    final signed = jsonDecode(report.canonicalJson!) as Map<String, dynamic>;
    expect((report.status, report.band, signed['summary']), ('FINALIZED', 'C', ''));
    expect(signed['strengths'] as List, isEmpty);
    expect(signed['actionPoints'] as List, isEmpty);
    expect(await db.select(db.finding).get(), isEmpty);
    expect(await db.select(db.actionPoint).get(), isEmpty);
    expect((signed['actualDifficulty'], signed['levelRecommendation']), (null, null));
    await db.close();
  });
}
