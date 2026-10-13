// Textos e iconos de la evaluación por criterios (es-ES). Las bandas son la única cara visible:
// ningún texto de esta pantalla muestra puntuaciones ni valores internos.

import 'package:flutter/material.dart';

import '../../core/design_system/tokens.dart';
import '../../domain/report.dart';
import '../../domain/rubric.dart';

IconData bandIcon(BandCode b) => switch (b) {
  BandCode.below => Icons.trending_down_rounded,
  BandCode.at => Icons.trending_flat_rounded,
  BandCode.above => Icons.trending_up_rounded,
};

/// Texto corto para botones: "Por debajo" / "En el nivel" / "Por encima".
String bandShort(BandCode b) => switch (b) {
  BandCode.below => 'Por debajo',
  BandCode.at => 'En el nivel',
  BandCode.above => 'Por encima',
};

/// (fondo, texto) de una banda. "Por debajo" NO usa el rojo de error: es una valoración, no un
/// fallo de la app. Siempre va con icono y texto.
(Color, Color) bandColors(BandCode b, RefColors c) => switch (b) {
  BandCode.below => (c.review, c.onReview),
  BandCode.at => (c.onSurface, c.background),
  BandCode.above => (c.positive, c.onPositive),
};

String reviewStatusLabel(ActionPointReviewStatus s) => switch (s) {
  ActionPointReviewStatus.achieved => 'Lograda',
  ActionPointReviewStatus.partial => 'Parcial',
  ActionPointReviewStatus.notAchieved => 'No lograda',
  ActionPointReviewStatus.notObserved => 'No observada',
};

String closeIssueText(CloseIssue i, AssessmentRubric rubric) {
  String crit() {
    final c = rubric.criteria.firstWhere((x) => x.code == i.criterionCode);
    return '${c.code.substring(0, 2)} · ${c.name}';
  }

  return switch (i.code) {
    CloseIssueCode.criterionBandMissing => '${crit()}: falta elegir la banda',
    CloseIssueCode.criterionJustificationRequired => '${crit()}: falta la justificación',
    CloseIssueCode.deviationJustificationTooShort => '${crit()}: justifica por qué no sigues la sugerencia',
    CloseIssueCode.capOverrideJustificationTooShort => '${crit()}: justifica por qué superas el tope',
    CloseIssueCode.summaryRequired => 'Falta el resumen del partido',
    CloseIssueCode.strengthsCount => 'Añade entre una y tres fortalezas',
    CloseIssueCode.developmentCount => 'Añade entre una y tres áreas de mejora',
    CloseIssueCode.actionPointsCount => 'Añade entre una y tres recomendaciones',
    CloseIssueCode.findingTextRequired => 'Hay una fortaleza o área de mejora sin texto',
    CloseIssueCode.actionPointTextRequired => 'Hay una recomendación sin texto',
    CloseIssueCode.actionPointIndicatorRequired => 'Hay una recomendación sin indicador de logro',
    CloseIssueCode.previousActionPointNotReviewed => 'Revisa las recomendaciones del informe anterior',
    CloseIssueCode.incidentVerdictPending ||
    CloseIssueCode.keyIncidentNotesRequired ||
    CloseIssueCode.incidentExpectedDecisionRequired ||
    CloseIssueCode.incidentImpactNotConfirmed => 'Quedan marcas por revisar',
  };
}

bool isIncidentIssue(CloseIssue i) => i.incidentId != null;
