// Paridad con test/scoring.test.ts: mismos casos, mismos números.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/domain/model.dart';
import 'package:ref_assess/domain/report.dart';
import 'package:ref_assess/domain/rubric.dart';
import 'package:ref_assess/domain/rubric_default.dart';
import 'package:ref_assess/domain/scoring.dart';

final r = kDefaultRubric;
var _n = 0;

Incident inc(String criterion, Verdict verdict, ImpactLevel impact, {IncidentStatus status = IncidentStatus.enriched}) {
  _n++;
  return Incident(
    id: 'i$_n',
    assessmentId: 'a1',
    seq: _n,
    sessionMs: _n * 1000,
    wallUtc: DateTime.utc(2026, 10, 17, 15),
    matchTime: const MatchTimeStamp(period: PeriodId.h1, phase: MatchPhaseLabel.inPlay, periodElapsedMs: 0, matchClockMs: 0, overtimeMs: 0, integrity: TimeIntegrity.ok),
    category: IncidentCategory.ruck,
    criterionCode: criterion,
    polarity: QuickPolarity.review,
    verdict: verdict,
    impact: impact,
    impactConfirmed: true,
    status: status,
  );
}

List<Incident> times(int k, Incident Function() f) => List.generate(k, (_) => f());
Matcher near(double v) => closeTo(v, 1e-12);

Map<String, CriterionChoice> choices(Map<String, Object> m) => {
      for (final c in r.criteria)
        c.code: switch (m[c.code] ?? BandCode.at) {
          'NO' => const CriterionChoice(notObserved: true),
          final BandCode b => CriterionChoice(finalBand: b),
          _ => throw ArgumentError(),
        },
    };

void main() {
  test('rúbrica v2: pesos de áreas y criterios (R1)', () {
    expect({for (final a in r.areas) a.code: a.weight}, {'PHASES': 35, 'MANAGEMENT': 20, 'LAW_DISCIPLINE': 30, 'FITNESS_POSITIONING': 15});
    final c = r.areas.firstWhere((a) => a.code == 'LAW_DISCIPLINE').criteria.map((x) => (x.code, x.weight)).toList();
    expect(c, [('C1_LAW_ACCURACY', 50.0), ('C2_FOUL_PLAY', 30.0), ('C3_SANCTION_CONSISTENCY', 20.0)]);
    expect(r.areas.fold<double>(0, (s, a) => s + a.weight), 100);
    for (final a in r.areas) {
      expect(a.criteria.fold<double>(0, (s, x) => s + x.weight), 100, reason: a.code);
    }
    expect(r.bands.map((b) => b.code), [BandCode.above, BandCode.at, BandCode.below]);
    expect(r.scoring.capRules.map((c) => (c.minImpact, c.minCount, c.capBand)), [
      (ImpactLevel.matchDefining, 1, BandCode.below),
      (ImpactLevel.high, 2, BandCode.below),
    ]);
    expect(r.scoring.minJustificationChars, 40);
  });

  test('límites de banda: los empates exactos caen en "En el nivel"', () {
    expect(toBand(8.0, r), BandCode.at);
    expect(toBand(8.0 + 1e-12, r), BandCode.at);
    expect(toBand(8.01, r), BandCode.above);
    expect(toBand(6.0, r), BandCode.at);
    expect(toBand(6.0 - 1e-12, r), BandCode.at);
    expect(toBand(5.99, r), BandCode.below);
    expect(toBand(1, r), BandCode.below);
  });

  test('ejemplo resuelto §2.3.3: placaje/ruck con un error HIGH ⇒ sugerencia "Por debajo"', () {
    final list = [
      inc('A3_TACKLE_RUCK', Verdict.correct, ImpactLevel.medium),
      inc('A3_TACKLE_RUCK', Verdict.correct, ImpactLevel.low),
      inc('A3_TACKLE_RUCK', Verdict.incorrect, ImpactLevel.high),
      inc('A3_TACKLE_RUCK', Verdict.debatable, ImpactLevel.medium),
      inc('A3_TACKLE_RUCK', Verdict.correct, ImpactLevel.medium),
      inc('A3_TACKLE_RUCK', Verdict.pending, ImpactLevel.high),
      inc('A3_TACKLE_RUCK', Verdict.incorrect, ImpactLevel.high, status: IncidentStatus.voided),
    ];
    final s = suggestCriterionScore('A3_TACKLE_RUCK', list, r);
    expect(s.evidenceWeight, 11);
    expect(s.accuracy, near(6 / 11));
    expect(s.raw, near(50.5 / 8.5));
    expect(s.suggestedBand, BandCode.below);
    expect(s.capBand, isNull);
    expect(s.evidenceIncidentIds.length, 5);
  });

  test('tope R4: un error MATCH_DEFINING limita SOLO su criterio a "Por debajo"', () {
    final list = [
      ...times(10, () => inc('A1_SCRUM', Verdict.correct, ImpactLevel.high)),
      inc('A1_SCRUM', Verdict.missed, ImpactLevel.matchDefining),
      ...times(6, () => inc('A3_TACKLE_RUCK', Verdict.correct, ImpactLevel.high)),
    ];
    final scrum = suggestCriterionScore('A1_SCRUM', list, r);
    expect(scrum.raw, near(205 / 27));
    expect(scrum.capBand, BandCode.below);
    expect(scrum.suggested, 5);
    expect(scrum.suggestedBand, BandCode.below);
    final ruck = suggestCriterionScore('A3_TACKLE_RUCK', list, r);
    expect(ruck.capBand, isNull);
    expect(ruck.suggested, near(129 / 15));
    expect(ruck.suggestedBand, BandCode.above);
  });

  test('dos errores HIGH en el mismo criterio también lo limitan a "Por debajo"', () {
    final s = suggestCriterionScore('C1_LAW_ACCURACY', [
      ...times(8, () => inc('C1_LAW_ACCURACY', Verdict.correct, ImpactLevel.high)),
      ...times(2, () => inc('C1_LAW_ACCURACY', Verdict.incorrect, ImpactLevel.high)),
    ], r);
    expect(s.raw!, greaterThan(6));
    expect(s.suggestedBand, BandCode.below);
  });

  test('poca evidencia ⇒ la sugerencia se queda "En el nivel"', () {
    final s = suggestCriterionScore('B4_ADVANTAGE', [inc('B4_ADVANTAGE', Verdict.correct, ImpactLevel.low)], r);
    expect(s.raw, near(25.5 / 3.5));
    expect(s.suggestedBand, BandCode.at);
    expect(suggestCriterionScore('D1_FITNESS', const [], r).suggestedBand, isNull);
  });

  test('agregación por bandas con los pesos v2 y redistribución de "no observado"', () {
    final a = aggregate(r, choices({
      'A1_SCRUM': BandCode.below,
      'B4_ADVANTAGE': BandCode.above,
      'C1_LAW_ACCURACY': BandCode.below,
      'C2_FOUL_PLAY': 'NO',
      'D2_POSITIONING': BandCode.above,
    }));
    expect(a.areas.map((x) => x.band), [BandCode.at, BandCode.at, BandCode.below, BandCode.at]);
    expect(a.areas[2].score, near(39 / 7));
    expect(a.overallScore, near((35 * 6.5 + 20 * 7.6 + 30 * 39 / 7 + 15 * 7.8) / 100));
    expect(a.band, BandCode.at);
  });

  test('el reglamento pesa: C1 y C3 por debajo hunden el área C y la global', () {
    final r1 = aggregate(r, choices({'C1_LAW_ACCURACY': BandCode.below, 'C3_SANCTION_CONSISTENCY': BandCode.below}));
    expect(r1.areas[2].band, BandCode.below);
    expect(r1.band, BandCode.at);
    final r2 = aggregate(r, choices({
      'C1_LAW_ACCURACY': BandCode.below,
      'C3_SANCTION_CONSISTENCY': BandCode.below,
      'A1_SCRUM': BandCode.below,
      'A2_LINEOUT_MAUL': BandCode.below,
      'A3_TACKLE_RUCK': BandCode.below,
      'B4_ADVANTAGE': BandCode.below,
    }));
    expect(r2.overallScore, near(5.9));
    expect(r2.band, BandCode.below);
  });

  test('precisión en decisiones clave', () {
    final k = keyDecisionAccuracy([
      inc('A1_SCRUM', Verdict.correct, ImpactLevel.high),
      inc('A1_SCRUM', Verdict.incorrect, ImpactLevel.matchDefining),
      inc('A1_SCRUM', Verdict.correct, ImpactLevel.low),
    ]);
    expect((k.correct, k.total, k.ratio), (1, 2, 0.5));
  });

  group('reglas de cierre (validateForFinalization)', () {
    final sugBelowCapped = SuggestedScore(
      criterionCode: 'A1_SCRUM', suggestedBand: BandCode.below, suggested: 5, raw: 7.6, accuracy: .9,
      evidenceWeight: 48, capBand: BandCode.below, evidenceIncidentIds: const [],
    );
    const sugAt = SuggestedScore(
      criterionCode: 'X', suggestedBand: BandCode.at, suggested: 7, raw: 7, accuracy: 1,
      evidenceWeight: 2, capBand: null, evidenceIncidentIds: [],
    );
    CloseIssueCode? one(CriterionEvaluation? e, SuggestedScore s) {
      final l = criterionIssues(e, s, 40, 'X');
      return l.isEmpty ? null : l.single.code;
    }

    test('por criterio', () {
      expect(one(null, sugAt), CloseIssueCode.criterionBandMissing);
      expect(one(const CriterionEvaluation(criterionCode: 'X', finalBand: BandCode.at), sugAt), CloseIssueCode.criterionJustificationRequired);
      expect(one(const CriterionEvaluation(criterionCode: 'X', finalBand: BandCode.at, justification: 'corta'), sugAt), isNull);
      expect(one(const CriterionEvaluation(criterionCode: 'X', finalBand: BandCode.above, justification: 'corta'), sugAt),
          CloseIssueCode.deviationJustificationTooShort);
      expect(one(CriterionEvaluation(criterionCode: 'X', finalBand: BandCode.above, justification: 'x' * 40), sugAt), isNull);
      expect(one(const CriterionEvaluation(criterionCode: 'X', finalBand: BandCode.at, justification: 'Visto en vídeo'), sugBelowCapped),
          CloseIssueCode.capOverrideJustificationTooShort);
      expect(one(const CriterionEvaluation(criterionCode: 'X', notObserved: true, justification: 'Sin scrums'), sugAt), isNull);
      expect(one(const CriterionEvaluation(criterionCode: 'X', notObserved: true), sugAt), CloseIssueCode.criterionJustificationRequired);
      expect(one(CriterionEvaluation(criterionCode: 'X', finalBand: BandCode.above, justification: '${' ' * 30}corto${' ' * 30}'), sugAt),
          CloseIssueCode.deviationJustificationTooShort, reason: 'los espacios no cuentan');
    });

    test('informe completo: incidencias, recuentos, recomendaciones previas y resumen', () {
      final sug = {for (final c in r.criteria) c.code: suggestCriterionScore(c.code, const [], r)};
      final issues = validateForClose(
        rubric: r,
        incidents: [inc('A1_SCRUM', Verdict.pending, ImpactLevel.medium)],
        suggestions: sug,
        evaluations: {for (final c in r.criteria) c.code: CriterionEvaluation(criterionCode: c.code, finalBand: BandCode.at, justification: 'ok')},
        summary: '',
        findings: const [Finding(id: 'f1', kind: FindingKind.strength, criterionCode: 'B4_ADVANTAGE', text: ' ')],
        actionPoints: const [ActionPoint(id: 'ap', criterionCode: 'A1_SCRUM', text: 'Mejorar', successIndicator: '')],
        openPrevious: const [PreviousActionPoint(id: 'prev', criterionCode: 'A1_SCRUM', text: 'x', successIndicator: 'y')],
        previousReviews: const {},
      );
      expect(issues.map((i) => i.code).toList()..sort((a, b) => a.index.compareTo(b.index)), [
        CloseIssueCode.incidentVerdictPending,
        CloseIssueCode.summaryRequired,
        CloseIssueCode.developmentCount,
        CloseIssueCode.findingTextRequired,
        CloseIssueCode.actionPointIndicatorRequired,
        CloseIssueCode.previousActionPointNotReviewed,
      ]);
    });
  });

  group('integridad: paridad con canonicalJson + SHA-256 de TypeScript', () {
    test('mismo JSON canónico que usecases.ts', () {
      expect(canonicalJson({'b': 1, 'a': [{'d': 2, 'e': null}]}), '{"a":[{"d":2,"e":null}],"b":1}');
      expect(canonicalJson({'x': 7.0, 'y': 6.82, 'z': 'ñ"\n'}), '{"x":7,"y":6.82,"z":"ñ\\"\\n"}');
    });

    test('el hash de export/example-export.json (calculado en TS) se reproduce en Dart', () {
      final doc = jsonDecode(File('../export/example-export.json').readAsStringSync()) as Map<String, dynamic>;
      final report = Map<String, Object?>.from(doc['report'] as Map)..remove('status');
      expect(contentHash(report), (doc['integrity'] as Map)['contentHash']);
    });
  });
}
