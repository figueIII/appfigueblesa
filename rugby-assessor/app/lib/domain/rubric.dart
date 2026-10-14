// Tipos de la rúbrica (port de AssessmentRubric en domain/model.ts). Los valores por defecto
// están en rubric_default.dart, generado desde rubric-default.ts.

import 'model.dart';

/// Escala de valoración del CARC: la ÚNICA cara visible de la evaluación (resolución R2).
/// Ordenada de peor a mejor (el índice es el rango): U – Revisión urgente, N – No competente
/// todavía, C – Competente, E – Excelente. Los informes cerrados con la rúbrica v2 guardan
/// BELOW / AT / ABOVE, que se leen como N / C / E (ver [decodeBand]).
enum BandCode { urgent, notYet, competent, excellent }

/// Código de la banda en la base de datos y en la exportación: 'E', 'C', 'N', 'U'.
String bandWireCode(BandCode b) => switch (b) {
      BandCode.excellent => 'E',
      BandCode.competent => 'C',
      BandCode.notYet => 'N',
      BandCode.urgent => 'U',
    };

/// Lee una banda guardada. Acepta los códigos de la rúbrica v2 de los informes antiguos.
BandCode? decodeBand(String? s) => switch (s) {
      'E' || 'ABOVE' => BandCode.excellent,
      'C' || 'AT' => BandCode.competent,
      'N' || 'BELOW' => BandCode.notYet,
      'U' => BandCode.urgent,
      _ => null,
    };

class PerformanceBand {
  const PerformanceBand({
    required this.code,
    required this.label,
    required this.description,
    required this.representative,
    required this.lower,
    required this.lowerInclusive,
    this.labelCa,
    this.descriptionCa,
  });
  final BandCode code;
  final String label;
  final String description;

  /// Textos en catalán (originales del CARC).
  final String? labelCa;
  final String? descriptionCa;

  /// Letra de la escala: E, C, N o U.
  String get letter => bandWireCode(code);

  /// Valor interno cuando el evaluador elige esta banda (9 / 7 / 5 / 3). Nunca se muestra.
  final double representative;
  final double lower;
  final bool lowerInclusive;
}

class Criterion {
  const Criterion({
    required this.code,
    required this.name,
    required this.weight,
    required this.description,
    this.nameCa,
    this.level,
  });
  final String code;

  /// Texto de la competencia en castellano; [nameCa], el original en catalán.
  final String name;
  final String? nameCa;
  final double weight;
  final String description;

  /// Nivel de la competencia en el CARC (1, 2 o 3). null en la rúbrica v2.
  final int? level;
}

class RubricArea {
  const RubricArea({required this.code, required this.name, required this.weight, required this.criteria, this.nameCa});
  final String code;
  final String name;
  final String? nameCa;
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

  /// Ordenadas de mayor a menor (E, C, N, U).
  final List<PerformanceBand> bands;
  final List<RubricArea> areas;
  final ScoringParams scoring;

  Iterable<Criterion> get criteria => areas.expand((a) => a.criteria);

  /// Competencia por código, o null si no es de esta rúbrica (p. ej. una recomendación de un
  /// informe anterior cerrado con otra rúbrica).
  Criterion? criterionOrNull(String code) {
    for (final c in criteria) {
      if (c.code == code) return c;
    }
    return null;
  }

  PerformanceBand band(BandCode code) => bands.firstWhere((b) => b.code == code);
  RubricArea areaOf(String criterionCode) => areas.firstWhere((a) => a.criteria.any((c) => c.code == criterionCode));
}
