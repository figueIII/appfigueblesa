// Textos e iconos de la evaluación por competencias (castellano / catalán, ver core/i18n.dart).
// La escala E / C / N / U es la única cara visible: ningún texto de esta pantalla muestra
// puntuaciones ni valores internos.

import 'package:flutter/material.dart';

import '../../core/design_system/tokens.dart';
import '../../core/i18n.dart';
import '../../domain/report.dart';
import '../../domain/rubric.dart';

/// Orden en pantalla: el del CARC (E, C, N, U).
const List<BandCode> kBandsInDisplayOrder = [BandCode.excellent, BandCode.competent, BandCode.notYet, BandCode.urgent];

IconData bandIcon(BandCode b) => switch (b) {
      BandCode.excellent => Icons.star_rounded,
      BandCode.competent => Icons.check_circle_outline_rounded,
      BandCode.notYet => Icons.trending_up_rounded,
      BandCode.urgent => Icons.priority_high_rounded,
    };

/// Texto corto para los botones del selector.
String bandShort(BandCode b) => switch (b) {
      BandCode.excellent => tr('Excelente', 'Excel·lent'),
      BandCode.competent => tr('Competente', 'Competent'),
      BandCode.notYet => tr('Aún no', 'Encara no'),
      BandCode.urgent => tr('Urgente', 'Urgent'),
    };

/// (fondo, texto) de una banda. Siempre va con letra, icono y texto (nunca solo color).
(Color, Color) bandColors(BandCode b, RefColors c) => switch (b) {
      BandCode.excellent => (c.positive, c.onPositive),
      BandCode.competent => (c.onSurface, c.background),
      BandCode.notYet => (c.review, c.onReview),
      BandCode.urgent => (c.negative, c.onNegative),
    };

String reviewStatusLabel(ActionPointReviewStatus s) => switch (s) {
      ActionPointReviewStatus.achieved => tr('Lograda', 'Assolida'),
      ActionPointReviewStatus.partial => tr('Parcial', 'Parcial'),
      ActionPointReviewStatus.notAchieved => tr('No lograda', 'No assolida'),
      ActionPointReviewStatus.notObserved => tr('No observada', 'No observada'),
    };

/// Recomendación de nivel del CARC: (símbolo, texto).
(String, String) levelRecommendationLabel(LevelRecommendation r) => switch (r) {
      LevelRecommendation.up => ('↑', tr('Probar partidos de más exigencia', 'Provar partits de més exigència')),
      LevelRecommendation.same => ('=', tr('Mantener en partidos similares', 'Mantenir en partits similars')),
      LevelRecommendation.down => ('↓', tr('Reducir la exigencia de los partidos', "Reduir l'exigència dels partits")),
    };

/// Dificultad del partido (estimada o real).
String difficultyText(String code) => switch (code) {
      'LOW' => tr('Baja', 'Baixa'),
      'MEDIUM' => tr('Media', 'Mitjana'),
      'HIGH' => tr('Alta', 'Alta'),
      'VERY_HIGH' => tr('Muy alta', 'Molt alta'),
      _ => code,
    };

/// "B2 · Identifica la falta…" (o el código si la competencia no es de esta rúbrica).
String criterionTitle(AssessmentRubric rubric, String code) {
  final c = rubric.criterionOrNull(code);
  return c == null ? code : '${c.code.substring(0, 2)} · ${c.label}';
}

String closeIssueText(CloseIssue i, AssessmentRubric rubric) => switch (i.code) {
      CloseIssueCode.criterionBandMissing => tr('${criterionTitle(rubric, i.criterionCode!)}: sin valorar',
          '${criterionTitle(rubric, i.criterionCode!)}: sense valorar'),
      CloseIssueCode.previousActionPointNotReviewed =>
        tr('Hay recomendaciones del informe anterior sin revisar', "Hi ha recomanacions de l'informe anterior sense revisar"),
      CloseIssueCode.incidentVerdictPending => tr('Quedan marcas sin valorar', 'Queden marques sense valorar'),
    };

bool isIncidentIssue(CloseIssue i) => i.incidentId != null;
