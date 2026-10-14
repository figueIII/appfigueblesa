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
        c.code: switch (m[c.code] ?? BandCode.competent) {
          'NO' => const CriterionChoice(notObserved: true),
          'NONE' => const CriterionChoice(),
          final BandCode b => CriterionChoice(finalBand: b),
          _ => throw ArgumentError(),
        },
    };

void main() {
  test('rúbrica v3 (CARC): 6 áreas, 25 competencias con nivel, pesos iguales, escala E/C/N/U', () {
    expect([for (final a in r.areas) (a.code, a.criteria.length)], [
      ('POSITIONING', 6),
      ('COMMUNICATION', 3),
      ('CONTINUITY', 3),
      ('SET_PIECE', 4),
      ('DYNAMIC_PHASES', 6),
      ('DISCIPLINE', 3),
    ]);
    expect(r.criteria.length, 25);
    expect(r.criteria.map((c) => c.code).toSet().length, 25);
    for (final a in r.areas) {
      expect(a.weight, 1, reason: a.code);
      expect(a.nameCa, isNotNull, reason: a.code);
      for (final c in a.criteria) {
        expect((c.weight, c.level != null, c.nameCa != null), (1.0, true, true), reason: c.code);
      }
    }
    expect([for (final a in r.areas) a.letter], ['A', 'B', 'C', 'D', 'E', 'F']);
    expect(r.areas.last.nameCa, 'Disciplina');
    expect(r.areas[4].nameCa, 'Fases dinàmiques');
    expect(r.bands.map((b) => b.code), [BandCode.excellent, BandCode.competent, BandCode.notYet, BandCode.urgent]);
    expect(r.bands.map((b) => b.letter), ['E', 'C', 'N', 'U']);
    expect(r.bands.map((b) => b.labelCa), ['Excel·lent', 'Competent', 'No competent encara', 'Urgent revisar']);
    expect(r.scoring.capRules.map((c) => (c.minImpact, c.minCount, c.capBand)), [
      (ImpactLevel.matchDefining, 1, BandCode.notYet),
      (ImpactLevel.high, 2, BandCode.notYet),
    ]);
    // Cada categoría del tap rápido alimenta una competencia que existe.
    for (final code in kCategoryToCriterion.values) {
      expect(r.criterionOrNull(code), isNotNull, reason: code);
    }
  });

  test('la rúbrica Dart es la generada desde rubric-default.ts (mismo id, versión y competencias)', () {
    final ts = File('../domain/rubric-default.ts').readAsStringSync();
    expect(ts, contains("id: '${r.id}'"));
    expect(ts, contains("version: '${r.version}'"));
    for (final c in r.criteria) {
      expect(ts, contains("c('${c.code}', ${c.level},"), reason: c.code);
    }
  });

  test('códigos de banda: E/C/N/U y lectura de los informes v2', () {
    expect(BandCode.values.map(bandWireCode), ['U', 'N', 'C', 'E']);
    for (final b in BandCode.values) {
      expect(decodeBand(bandWireCode(b)), b);
    }
    expect((decodeBand('ABOVE'), decodeBand('AT'), decodeBand('BELOW'), decodeBand(null)),
        (BandCode.excellent, BandCode.competent, BandCode.notYet, null));
  });

  test('límites de banda: los empates exactos caen en la banda conservadora', () {
    expect(toBand(8.0, r), BandCode.competent);
    expect(toBand(8.0 + 1e-12, r), BandCode.competent);
    expect(toBand(8.01, r), BandCode.excellent);
    expect(toBand(6.0, r), BandCode.competent);
    expect(toBand(6.0 - 1e-12, r), BandCode.competent);
    expect(toBand(5.99, r), BandCode.notYet);
    expect(toBand(4.0, r), BandCode.notYet);
    expect(toBand(3.99, r), BandCode.urgent);
    expect(toBand(1, r), BandCode.urgent);
  });

  test('ejemplo resuelto §2.3.3: placaje con un error HIGH ⇒ sugerencia N', () {
    const t = 'E2_TACKLER_TACKLED';
    final list = [
      inc(t, Verdict.correct, ImpactLevel.medium),
      inc(t, Verdict.correct, ImpactLevel.low),
      inc(t, Verdict.incorrect, ImpactLevel.high),
      inc(t, Verdict.debatable, ImpactLevel.medium),
      inc(t, Verdict.correct, ImpactLevel.medium),
      inc(t, Verdict.pending, ImpactLevel.high),
      inc(t, Verdict.incorrect, ImpactLevel.high, status: IncidentStatus.voided),
    ];
    final s = suggestCriterionScore(t, list, r);
    expect(s.evidenceWeight, 11);
    expect(s.accuracy, near(6 / 11));
    expect(s.raw, near(50.5 / 8.5));
    expect(s.suggestedBand, BandCode.notYet);
    expect(s.capBand, isNull);
    expect(s.evidenceIncidentIds.length, 5);
  });

  test('tope R4: un error MATCH_DEFINING limita SOLO su competencia a N', () {
    const scrumCode = 'D2_SCRUM_SEQUENCE_SAFETY', ruckCode = 'E3_GATES_ENTRIES';
    final list = [
      ...times(10, () => inc(scrumCode, Verdict.correct, ImpactLevel.high)),
      inc(scrumCode, Verdict.missed, ImpactLevel.matchDefining),
      ...times(6, () => inc(ruckCode, Verdict.correct, ImpactLevel.high)),
    ];
    final scrum = suggestCriterionScore(scrumCode, list, r);
    expect(scrum.raw, near(205 / 27));
    expect(scrum.capBand, BandCode.notYet);
    expect(scrum.suggested, 5);
    expect(scrum.suggestedBand, BandCode.notYet);
    final ruck = suggestCriterionScore(ruckCode, list, r);
    expect(ruck.capBand, isNull);
    expect(ruck.suggested, near(129 / 15));
    expect(ruck.suggestedBand, BandCode.excellent);
  });

  test('dos errores HIGH en la misma competencia también la limitan a N', () {
    const code = 'C2_MATERIAL_EFFECT';
    final s = suggestCriterionScore(code, [
      ...times(8, () => inc(code, Verdict.correct, ImpactLevel.high)),
      ...times(2, () => inc(code, Verdict.incorrect, ImpactLevel.high)),
    ], r);
    expect(s.raw!, greaterThan(6));
    expect(s.suggestedBand, BandCode.notYet);
  });

  test('muchos errores ⇒ U; poca evidencia ⇒ C', () {
    final bad = suggestCriterionScore('F1_DANGEROUS_PLAY', times(6, () => inc('F1_DANGEROUS_PLAY', Verdict.incorrect, ImpactLevel.medium)), r);
    expect(bad.raw, near(3));
    expect(bad.suggestedBand, BandCode.urgent);
    final s = suggestCriterionScore('C3_ADVANTAGE_CONSISTENCY', [inc('C3_ADVANTAGE_CONSISTENCY', Verdict.correct, ImpactLevel.low)], r);
    expect(s.raw, near(25.5 / 3.5));
    expect(s.suggestedBand, BandCode.competent);
    expect(suggestCriterionScore('A5_REACHES_CONTACT', const [], r).suggestedBand, isNull);
  });

  test('agregación E/C/N/U con pesos iguales; "no observado" y "sin valorar" no cuentan', () {
    final a = aggregate(r, choices({
      'A1_STATIC_START': BandCode.excellent,
      'A2_NO_INTERFERENCE': BandCode.notYet,
      'B1_PRIMARY_SIGNAL_WHISTLE': BandCode.urgent,
      'B2_SECONDARY_SIGNAL': 'NO',
      'D1_ORDERED_SET_PIECE': BandCode.excellent,
      'D2_SCRUM_SEQUENCE_SAFETY': BandCode.excellent,
      'D3_DANGER_DETECTION': BandCode.excellent,
      'D4_FAIR_CONTEST': BandCode.excellent,
      'F1_DANGEROUS_PLAY': BandCode.urgent,
      'F2_FOUL_PLAY': BandCode.urgent,
      'F3_MATCH_CONTROL': BandCode.notYet,
      'E6_JACKLER': 'NONE',
    }));
    expect(a.areas.map((x) => x.band), [
      BandCode.competent,
      BandCode.notYet,
      BandCode.competent,
      BandCode.excellent,
      BandCode.competent,
      BandCode.urgent,
    ]);
    expect(a.areas[5].score, near(11 / 3));
    expect(a.overallScore, near((7 + 5 + 7 + 9 + 7 + 11 / 3) / 6));
    expect(a.band, BandCode.competent);
    // Un área entera sin valorar sale de la media global.
    final only = aggregate(r, {for (final c in r.criteria) c.code: CriterionChoice(finalBand: c.code.startsWith('F') ? BandCode.urgent : null)});
    expect((only.overallScore, only.band, only.areas.first.band), (3.0, BandCode.urgent, null));
  });

  test('precisión en decisiones clave', () {
    final k = keyDecisionAccuracy([
      inc('D1_ORDERED_SET_PIECE', Verdict.correct, ImpactLevel.high),
      inc('D1_ORDERED_SET_PIECE', Verdict.incorrect, ImpactLevel.matchDefining),
      inc('D1_ORDERED_SET_PIECE', Verdict.correct, ImpactLevel.low),
    ]);
    expect((k.correct, k.total, k.ratio), (1, 2, 0.5));
  });

  group('avisos de cierre (nada es obligatorio)', () {
    const sugC = SuggestedScore(
      criterionCode: 'X', suggestedBand: BandCode.competent, suggested: 7, raw: 7, accuracy: 1,
      evidenceWeight: 2, capBand: null, evidenceIncidentIds: [],
    );

    test('valorada = banda o "no observado"; la justificación nunca falta', () {
      expect(isRated(null), isFalse);
      expect(isRated(const CriterionEvaluation(criterionCode: 'X')), isFalse);
      expect(isRated(const CriterionEvaluation(criterionCode: 'X', finalBand: BandCode.competent)), isTrue);
      expect(isRated(const CriterionEvaluation(criterionCode: 'X', notObserved: true)), isTrue);
      // Conviene justificar si no sigue la sugerencia (solo un consejo).
      expect(needsLongJustification(const CriterionEvaluation(criterionCode: 'X', finalBand: BandCode.excellent), sugC), isTrue);
      expect(needsLongJustification(const CriterionEvaluation(criterionCode: 'X', finalBand: BandCode.competent), sugC), isFalse);
    });

    test('solo avisa de marcas sin veredicto, competencias sin valorar y recomendaciones previas sin revisar', () {
      final issues = closeWarnings(
        rubric: r,
        incidents: [inc('D1_ORDERED_SET_PIECE', Verdict.pending, ImpactLevel.medium)],
        evaluations: {
          for (final c in r.criteria.skip(1)) c.code: CriterionEvaluation(criterionCode: c.code, finalBand: BandCode.competent),
        },
        openPrevious: const [PreviousActionPoint(id: 'prev', criterionCode: 'A1_STATIC_START', text: 'x', successIndicator: '')],
        previousReviews: const {},
      );
      expect(issues.map((i) => (i.code, i.criterionCode)), [
        (CloseIssueCode.incidentVerdictPending, null),
        (CloseIssueCode.criterionBandMissing, 'A1_STATIC_START'),
        (CloseIssueCode.previousActionPointNotReviewed, null),
      ]);
      // Sin resumen, sin fortalezas, sin recomendaciones y sin justificaciones: ningún aviso.
      expect(
        closeWarnings(
          rubric: r,
          incidents: const [],
          evaluations: {for (final c in r.criteria) c.code: CriterionEvaluation(criterionCode: c.code, notObserved: true)},
          openPrevious: const [],
          previousReviews: const {},
        ),
        isEmpty,
      );
    });

    test('el informe firmado descarta los textos vacíos y guarda dificultad real y recomendación', () {
      final sug = {for (final c in r.criteria) c.code: suggestCriterionScore(c.code, const [], r)};
      final signed = buildSignedReport(
        version: 1,
        finalizedAt: DateTime.utc(2026, 10, 18),
        rubric: r,
        suggestions: sug,
        evaluations: const {},
        aggregate: aggregate(r, const {}),
        keyDecisions: keyDecisionAccuracy(const []),
        summary: '',
        findings: const [
          Finding(id: 'f1', kind: FindingKind.strength, criterionCode: 'A1_STATIC_START', text: ' '),
          Finding(id: 'f2', kind: FindingKind.development, criterionCode: 'F3_MATCH_CONTROL', text: 'Control'),
        ],
        actionPoints: const [
          ActionPoint(id: 'ap1', criterionCode: 'F3_MATCH_CONTROL', text: '', successIndicator: ''),
          ActionPoint(id: 'ap2', criterionCode: 'F3_MATCH_CONTROL', text: 'Hablar con capitanes', successIndicator: ''),
        ],
        openPrevious: const [],
        previousReviews: const {},
        actualDifficulty: 'VERY_HIGH',
        levelRecommendation: LevelRecommendation.up,
      );
      expect((signed['strengths'] as List), isEmpty);
      expect((signed['developmentAreas'] as List).length, 1);
      expect([for (final a in signed['actionPoints'] as List) (a as Map)['id']], ['ap2']);
      expect((signed['actualDifficulty'], signed['levelRecommendation'], signed['band']), ('VERY_HIGH', 'UP', null));
      expect((signed['criterionScores'] as List).first, containsPair('finalBand', null));
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
