// Port a Dart puro de domain/scoring.ts. Misma fórmula, mismos topes, misma tolerancia.
// Escala del CARC: U (0) < N (1) < C (2) < E (3); el índice de BandCode es el rango.
// Calcula en una escala INTERNA (1–10) y expone solo BANDAS (resolución R2).
// test/domain/scoring_test.dart replica, número a número, los casos de test/scoring.test.ts.

import 'model.dart';
import 'rubric.dart';

/// Tolerancia para que el ruido de coma flotante no cruce un límite de banda.
const double _eps = 1e-9;

const Set<Verdict> _assessed = {Verdict.correct, Verdict.incorrect, Verdict.missed, Verdict.debatable};
const Set<Verdict> _errors = {Verdict.incorrect, Verdict.missed};

bool _atLeast(ImpactLevel i, ImpactLevel min) => i.index >= min.index;

int bandRank(BandCode b) => b.index; // U 0 · N 1 · C 2 · E 3
BandCode minBand(BandCode a, BandCode b) => bandRank(a) <= bandRank(b) ? a : b;

/// Valor interno → banda. Los empates exactos en el límite estricto de E caen en C.
BandCode toBand(double value, AssessmentRubric rubric) {
  for (final b in rubric.bands) {
    if (b.lowerInclusive ? value >= b.lower - _eps : value > b.lower + _eps) return b.code;
  }
  return rubric.bands.last.code;
}

double bandRepresentative(BandCode code, AssessmentRubric rubric) => rubric.band(code).representative;

class SuggestedScore {
  const SuggestedScore({
    required this.criterionCode,
    required this.suggestedBand,
    required this.suggested,
    required this.raw,
    required this.accuracy,
    required this.evidenceWeight,
    required this.capBand,
    required this.evidenceIncidentIds,
  });

  final String criterionCode;

  /// Visible. null = sin incidencias evaluadas en este criterio.
  final BandCode? suggestedBand;

  /// Internos (trazabilidad y tests).
  final double? suggested;
  final double? raw;
  final double? accuracy;
  final double evidenceWeight;

  /// Banda máxima impuesta por un tope (R4: solo afecta a este criterio).
  final BandCode? capBand;
  final List<String> evidenceIncidentIds;
}

/// Sugerencia de un criterio (escala interna):
///   p   = Σ wᵢ·créditoᵢ / Σ wᵢ                 precisión ponderada por impacto
///   s_p = atZero + (atOne − atZero)·p           1 + 8p
///   n   = W / w_MEDIUM                          evidencia en "incidencias medias equivalentes"
///   s   = (k·baseline + n·s_p) / (k + n)        contracción hacia "Competente"
/// Tope: si se cumple una CapRule, la sugerencia de ESTE criterio no supera su banda tope.
SuggestedScore suggestCriterionScore(String criterion, Iterable<Incident> incidents, AssessmentRubric rubric) {
  final p = rubric.scoring;
  final relevant = [
    for (final i in incidents)
      if (!i.isVoid && i.criterionCode == criterion && _assessed.contains(i.verdict)) i,
  ];
  if (relevant.isEmpty) {
    return SuggestedScore(
      criterionCode: criterion,
      suggestedBand: null,
      suggested: null,
      raw: null,
      accuracy: null,
      evidenceWeight: 0,
      capBand: null,
      evidenceIncidentIds: const [],
    );
  }
  var w = 0.0, c = 0.0;
  for (final i in relevant) {
    final wi = p.impactWeights[i.impact]!;
    w += wi;
    c += wi * p.verdictCredit[i.verdict]!;
  }
  final accuracy = c / w;
  final sp = p.accuracyAtZero + (p.accuracyAtOne - p.accuracyAtZero) * accuracy;
  final n = w / p.impactWeights[ImpactLevel.medium]!;
  final raw = (p.priorStrength * p.baseline + n * sp) / (p.priorStrength + n);

  BandCode? cap;
  for (final rule in p.capRules) {
    final count = relevant.where((i) => _errors.contains(i.verdict) && _atLeast(i.impact, rule.minImpact)).length;
    if (count >= rule.minCount) cap = cap == null ? rule.capBand : minBand(cap, rule.capBand);
  }
  var suggested = raw.clamp(rubric.scaleMin, rubric.scaleMax).toDouble();
  if (cap != null && suggested > bandRepresentative(cap, rubric)) suggested = bandRepresentative(cap, rubric);
  var band = toBand(suggested, rubric);
  if (cap != null) band = minBand(band, cap);
  return SuggestedScore(
    criterionCode: criterion,
    suggestedBand: band,
    suggested: suggested,
    raw: raw,
    accuracy: accuracy,
    evidenceWeight: w,
    capBand: cap,
    evidenceIncidentIds: [for (final i in relevant) i.id],
  );
}

/// Banda elegida por el evaluador para un criterio (o "no observado").
class CriterionChoice {
  const CriterionChoice({this.finalBand, this.notObserved = false});
  final BandCode? finalBand;
  final bool notObserved;
}

class AreaResult {
  const AreaResult({required this.areaCode, required this.score, required this.band});
  final String areaCode;
  final double? score; // interno
  final BandCode? band; // visible
}

class AggregateResult {
  const AggregateResult({required this.areas, required this.overallScore, required this.band});
  final List<AreaResult> areas;
  final double? overallScore; // interno, sin redondear
  final BandCode? band; // visible
}

/// Cada banda elegida vale su representativo; media ponderada por criterios y por áreas.
/// Los "no observados" salen y su peso se redistribuye. La banda sale del valor sin redondear.
AggregateResult aggregate(AssessmentRubric rubric, Map<String, CriterionChoice> choices) {
  double? valueOf(CriterionChoice? ch) =>
      ch == null || ch.notObserved || ch.finalBand == null ? null : bandRepresentative(ch.finalBand!, rubric);

  final areas = [
    for (final area in rubric.areas)
      () {
        var wsum = 0.0, acc = 0.0;
        for (final c in area.criteria) {
          final v = valueOf(choices[c.code]);
          if (v == null) continue;
          wsum += c.weight;
          acc += c.weight * v;
        }
        final score = wsum == 0 ? null : acc / wsum;
        return AreaResult(areaCode: area.code, score: score, band: score == null ? null : toBand(score, rubric));
      }(),
  ];
  var wsum = 0.0, acc = 0.0;
  for (final (idx, area) in rubric.areas.indexed) {
    final sc = areas[idx].score;
    if (sc == null) continue;
    wsum += area.weight;
    acc += area.weight * sc;
  }
  final overall = wsum == 0 ? null : acc / wsum;
  return AggregateResult(areas: areas, overallScore: overall, band: overall == null ? null : toBand(overall, rubric));
}

class KeyDecisionAccuracy {
  const KeyDecisionAccuracy({required this.correct, required this.total});
  final int correct;
  final int total;
  double? get ratio => total == 0 ? null : correct / total;
}

/// Decisiones clave (impacto ≥ HIGH) evaluadas y acertadas.
KeyDecisionAccuracy keyDecisionAccuracy(Iterable<Incident> incidents) {
  final key = [
    for (final i in incidents)
      if (!i.isVoid && _atLeast(i.impact, ImpactLevel.high) && _assessed.contains(i.verdict)) i,
  ];
  return KeyDecisionAccuracy(correct: key.where((i) => i.verdict == Verdict.correct).length, total: key.length);
}
