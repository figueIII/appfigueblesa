// Textos e iconos de la revisión post-partido (es-ES).

import 'package:flutter/material.dart';

import '../../core/design_system/tokens.dart';
import '../../domain/model.dart';
import '../../domain/review.dart';

String verdictLabel(Verdict v) => switch (v) {
  Verdict.pending => 'Sin veredicto',
  Verdict.correct => 'Correcta',
  Verdict.incorrect => 'Incorrecta',
  Verdict.missed => 'No pitada',
  Verdict.debatable => 'Discutible',
  Verdict.notAssessable => 'No evaluable',
};

String verdictHint(Verdict v) => switch (v) {
  Verdict.pending => '',
  Verdict.correct => 'Decisión acertada',
  Verdict.incorrect => 'Pitó, pero mal',
  Verdict.missed => 'Debía pitar y no lo hizo',
  Verdict.debatable => 'Decisión 50/50',
  Verdict.notAssessable => 'No se vio bien',
};

IconData verdictIcon(Verdict v) => switch (v) {
  Verdict.pending => Icons.flag_rounded,
  Verdict.correct => Icons.check_circle_rounded,
  Verdict.incorrect => Icons.cancel_rounded,
  Verdict.missed => Icons.do_not_disturb_on_rounded,
  Verdict.debatable => Icons.balance_rounded,
  Verdict.notAssessable => Icons.visibility_off_rounded,
};

/// Icono en la rejilla de elección. Nunca un check relleno: ese icono queda reservado para
/// "opción seleccionada", y un "Correcta" con check parecería ya marcado.
IconData verdictChoiceIcon(Verdict v) => switch (v) {
      Verdict.correct => Icons.thumb_up_alt_outlined,
      Verdict.incorrect => Icons.thumb_down_alt_outlined,
      _ => verdictIcon(v),
    };

/// (fondo, texto) del veredicto seleccionado. Neutro para los que no son ni acierto ni error.
(Color, Color) verdictColors(Verdict v, RefColors c) => switch (v) {
  Verdict.correct => (c.positive, c.onPositive),
  Verdict.incorrect || Verdict.missed => (c.negative, c.onNegative),
  Verdict.pending => (c.review, c.onReview),
  Verdict.debatable || Verdict.notAssessable => (c.onSurface, c.background),
};

String impactLabel(ImpactLevel i) => switch (i) {
  ImpactLevel.low => 'Bajo',
  ImpactLevel.medium => 'Medio',
  ImpactLevel.high => 'Alto',
  ImpactLevel.matchDefining => 'Decisivo',
};

String impactHint(ImpactLevel i) => switch (i) {
  ImpactLevel.low => 'Sin consecuencias',
  ImpactLevel.medium => 'Afecta a la fase',
  ImpactLevel.high => 'Cambia la posesión o el territorio',
  ImpactLevel.matchDefining => 'Puntos, tarjeta o resultado',
};

String outcomeLabel(DecisionOutcome o) => switch (o) {
  DecisionOutcome.playOn => 'Juego sigue',
  DecisionOutcome.advantage => 'Ventaja',
  DecisionOutcome.penalty => 'Golpe de castigo',
  DecisionOutcome.freeKick => 'Golpe franco',
  DecisionOutcome.scrum => 'Scrum',
  DecisionOutcome.lineout => 'Touch',
  DecisionOutcome.tryAwarded => 'Ensayo',
  DecisionOutcome.noTry => 'No ensayo',
  DecisionOutcome.penaltyTry => 'Ensayo de castigo',
  DecisionOutcome.yellowCard => 'Amarilla',
  DecisionOutcome.redCard20 => 'Roja 20′',
  DecisionOutcome.redCard => 'Roja',
  DecisionOutcome.warning => 'Aviso',
  DecisionOutcome.tmoReferral => 'Consulta TMO',
  DecisionOutcome.noDecision => 'Sin decisión',
};

String gamePhaseLabel(GamePhase p) => switch (p) {
  GamePhase.setPiece => 'Fase estática',
  GamePhase.breakdown => 'Breakdown',
  GamePhase.openPlay => 'Juego abierto',
  GamePhase.kicking => 'Juego al pie',
  GamePhase.restart => 'Reinicio',
  GamePhase.stoppage => 'Parada',
  GamePhase.offField => 'Fuera del juego',
};

String fieldZoneLabel(FieldZone z) => switch (z) {
  FieldZone.own22 => '22 propia',
  FieldZone.own22ToHalf => '22 propia – mitad',
  FieldZone.halfToOpp22 => 'Mitad – 22 rival',
  FieldZone.opp22 => '22 rival',
  FieldZone.inGoal => 'Zona de ensayo',
};

/// Lo recomendado, en tono de sugerencia (no es un error).
String recommendationLabel(ReviewIssue i) => switch (i) {
  ReviewIssue.verdictPending => 'Falta el veredicto',
  ReviewIssue.keyIncidentNotesMissing => 'Recomendado: notas (impacto alto)',
  ReviewIssue.expectedDecisionMissing => 'Recomendado: decisión esperada',
  ReviewIssue.impactNotConfirmed => 'Recomendado: confirmar el impacto',
};

String issueLabel(ReviewIssue i) => switch (i) {
  ReviewIssue.verdictPending => 'Falta el veredicto',
  ReviewIssue.keyIncidentNotesMissing => 'Faltan notas (impacto alto)',
  ReviewIssue.expectedDecisionMissing => 'Falta la decisión esperada',
  ReviewIssue.impactNotConfirmed => 'Confirma el impacto',
};

/// Criterios de la rúbrica v2.0.0 (rubric-default.ts), agrupados por área.
const List<(String area, List<(String code, String label)> criteria)> kRubricCriteria = [
  (
    'A · Fases de juego',
    [
      ('A1_SCRUM', 'Scrum'),
      ('A2_LINEOUT_MAUL', 'Touch y maul'),
      ('A3_TACKLE_RUCK', 'Placaje y ruck'),
      ('A4_OFFSIDE_SPACE', 'Espacio y fuera de juego'),
    ],
  ),
  (
    'B · Comunicación y gestión',
    [
      ('B1_VERBAL_CONTROL', 'Control verbal y preventivo'),
      ('B2_TONE_PRESENCE', 'Tono, señalización y presencia'),
      ('B3_CAPTAINS_PLAYERS', 'Capitanes y jugadores'),
      ('B4_ADVANTAGE', 'Ventaja'),
    ],
  ),
  (
    'C · Leyes y disciplina',
    [
      ('C1_LAW_ACCURACY', 'Exactitud en la aplicación de las leyes'),
      ('C2_FOUL_PLAY', 'Juego desleal'),
      ('C3_SANCTION_CONSISTENCY', 'Consistencia disciplinaria'),
    ],
  ),
  (
    'D · Físico y posicionamiento',
    [('D1_FITNESS', 'Condición física'), ('D2_POSITIONING', 'Posicionamiento'), ('D3_RUNNING_LINES', 'Líneas de carrera')],
  ),
];

String criterionLabel(String code) {
  for (final (_, list) in kRubricCriteria) {
    for (final (c, label) in list) {
      if (c == code) return label;
    }
  }
  return code;
}
