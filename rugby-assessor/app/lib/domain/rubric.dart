// Tipos de la rúbrica (port de AssessmentRubric en domain/model.ts). Los valores por defecto
// están en rubric_default.dart, generado desde rubric-default.ts.

import 'model.dart';

/// Bandas cualitativas: la ÚNICA cara visible de la evaluación (resolución R2).
enum BandCode { below, at, above }

class PerformanceBand {
  const PerformanceBand({
    required this.code,
    required this.label,
    required this.description,
    required this.representative,
    required this.lower,
    required this.lowerInclusive,
  });
  final BandCode code;
  final String label;
  final String description;

  /// Valor interno cuando el evaluador elige esta banda (5 / 7 / 9). Nunca se muestra.
  final double representative;
  final double lower;
  final bool lowerInclusive;
}

class Criterion {
  const Criterion({required this.code, required this.name, required this.weight, required this.description});
  final String code;
  final String name;
  final double weight;
  final String description;
}

class RubricArea {
  const RubricArea({required this.code, required this.name, required this.weight, required this.criteria});
  final String code;
  final String name;
  final double weight;
  final List<Criterion> criteria;

  /// Letra del área a partir de sus criterios ("A1_SCRUM" → "A").
  String get letter => criteria.first.code.substring(0, 1);
}

class CapRule {
  const CapRule({required this.minImpact, required this.minCount, required this.capBand});
  final ImpactLevel minImpact;
  final int minCount;
  final BandCode capBand;
}

class ScoringParams {
  const ScoringParams({
    required this.impactWeights,
    required this.verdictCredit,
    required this.accuracyAtZero,
    required this.accuracyAtOne,
    required this.baseline,
    required this.priorStrength,
    required this.capRules,
    required this.minJustificationChars,
  });
  final Map<ImpactLevel, double> impactWeights;
  final Map<Verdict, double> verdictCredit;
  final double accuracyAtZero;
  final double accuracyAtOne;
  final double baseline;
  final double priorStrength;
  final List<CapRule> capRules;
  final int minJustificationChars;
}

class AssessmentRubric {
  const AssessmentRubric({
    required this.id,
    required this.code,
    required this.version,
    required this.name,
    required this.scaleMin,
    required this.scaleMax,
    required this.bands,
    required this.areas,
    required this.scoring,
  });
  final String id;
  final String code;
  final String version;
  final String name;
  final double scaleMin;
  final double scaleMax;

  /// Ordenadas de mayor a menor (ABOVE, AT, BELOW).
  final List<PerformanceBand> bands;
  final List<RubricArea> areas;
  final ScoringParams scoring;

  Iterable<Criterion> get criteria => areas.expand((a) => a.criteria);
  PerformanceBand band(BandCode code) => bands.firstWhere((b) => b.code == code);
  RubricArea areaOf(String criterionCode) => areas.firstWhere((a) => a.criteria.any((c) => c.code == criterionCode));
}
