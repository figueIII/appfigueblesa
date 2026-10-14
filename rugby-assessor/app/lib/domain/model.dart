// Subconjunto del modelo de dominio (domain/model.ts) que necesita la captura en directo.

import 'laws.dart' show InfractionRef;

enum GameFormat { xv, sevens, tens }

enum PeriodId { h1, h2, et1, et2, sd }

enum TimeIntegrity { ok, degraded }

enum MatchPhaseLabel { preMatch, inPlay, timeOff, interval, fullTime }

enum QuickPolarity { positive, negative, review }

enum Verdict { pending, correct, incorrect, missed, debatable, notAssessable }

enum ImpactLevel { low, medium, high, matchDefining }

enum IncidentStatus { quick, enriched, voided }

enum IncidentCategory {
  scrum,
  lineout,
  maul,
  tackle,
  ruck,
  offside,
  advantage,
  communication,
  captainMgmt,
  tryGrounding,
  knockOnForwardPass,
  otherLaw,
  foulPlay,
  card,
  tmoProcess,
  positioning,
  fitness,
  runningLine,
}

/// Mapa categoría → competencia de la rúbrica CARC v3.0.0 (rubric-default.ts, categoryToCriterion).
const Map<IncidentCategory, String> kCategoryToCriterion = {
  IncidentCategory.scrum: 'D2_SCRUM_SEQUENCE_SAFETY',
  IncidentCategory.lineout: 'D4_FAIR_CONTEST',
  IncidentCategory.maul: 'E3_GATES_ENTRIES',
  IncidentCategory.tackle: 'E2_TACKLER_TACKLED',
  IncidentCategory.ruck: 'E3_GATES_ENTRIES',
  IncidentCategory.offside: 'E4_OFFSIDE_LINES',
  IncidentCategory.communication: 'B3_PLAYER_COMMUNICATION',
  IncidentCategory.captainMgmt: 'F3_MATCH_CONTROL',
  IncidentCategory.advantage: 'C3_ADVANTAGE_CONSISTENCY',
  IncidentCategory.tryGrounding: 'A3_SEES_PLAY',
  IncidentCategory.knockOnForwardPass: 'C2_MATERIAL_EFFECT',
  IncidentCategory.otherLaw: 'C2_MATERIAL_EFFECT',
  IncidentCategory.foulPlay: 'F1_DANGEROUS_PLAY',
  IncidentCategory.tmoProcess: 'F2_FOUL_PLAY',
  IncidentCategory.card: 'F2_FOUL_PLAY',
  IncidentCategory.fitness: 'A5_REACHES_CONTACT',
  IncidentCategory.positioning: 'A3_SEES_PLAY',
  IncidentCategory.runningLine: 'A4_OPEN_PLAY_LINES',
};

class ExtraTimeConfig {
  const ExtraTimeConfig({required this.periodLengthMin, required this.suddenDeath});
  final int periodLengthMin;
  final bool suddenDeath;
}

class CategoryConfig {
  const CategoryConfig({
    required this.code,
    required this.name,
    required this.format,
    required this.periodLengthMin,
    required this.sinBinMin,
    this.extraTime,
  });
  final String code;
  final String name;
  final GameFormat format;
  final int periodLengthMin;
  final int sinBinMin;
  final ExtraTimeConfig? extraTime;
}

class MatchTimeStamp {
  const MatchTimeStamp({
    required this.period,
    required this.phase,
    required this.periodElapsedMs,
    required this.matchClockMs,
    required this.overtimeMs,
    required this.integrity,
  });
  final PeriodId? period;
  final MatchPhaseLabel phase;
  final int periodElapsedMs;
  final int matchClockMs;
  final int overtimeMs;
  final TimeIntegrity integrity;
}

enum TeamSide { home, away }

enum DecisionOutcome {
  playOn,
  advantage,
  penalty,
  freeKick,
  scrum,
  lineout,
  tryAwarded,
  noTry,
  penaltyTry,
  yellowCard,
  redCard20,
  redCard,
  warning,
  tmoReferral,
  noDecision,
}

enum GamePhase { setPiece, breakdown, openPlay, kicking, restart, stoppage, offField }

enum FieldZone { own22, own22ToHalf, halfToOpp22, opp22, inGoal }

/// Decisión del árbitro (tomada o esperada). `outcomes` es una lista: p. ej. golpe + amarilla.
class Decision {
  const Decision({required this.outcomes, this.againstTeam, this.lawRef, this.description});
  final List<DecisionOutcome> outcomes;
  final TeamSide? againstTeam;
  final String? lawRef;
  final String? description;

  bool get isEmpty => outcomes.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is Decision &&
      _listEq(other.outcomes, outcomes) &&
      other.againstTeam == againstTeam &&
      other.lawRef == lawRef &&
      other.description == description;

  @override
  int get hashCode => Object.hash(Object.hashAll(outcomes), againstTeam, lawRef, description);
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Centinela para distinguir "no cambiar" de "poner a null" en copyWith.
const Object _keep = Object();

/// Incidencia: la crea el tap (pantalla 1) y se enriquece en la revisión (pantalla 2).
class Incident {
  const Incident({
    required this.id,
    required this.assessmentId,
    required this.seq,
    required this.sessionMs,
    required this.wallUtc,
    required this.matchTime,
    required this.category,
    required this.criterionCode,
    required this.polarity,
    required this.verdict,
    required this.impact,
    required this.impactConfirmed,
    required this.status,
    this.gamePhase,
    this.fieldZone,
    this.decisionTaken,
    this.decisionExpected,
    this.notes,
    this.infraction,
  });

  final String id;
  final String assessmentId;
  final int seq;
  final int sessionMs;
  final DateTime wallUtc;
  final MatchTimeStamp matchTime;
  final IncidentCategory category;
  final String criterionCode;
  final QuickPolarity polarity;
  final Verdict verdict;
  final ImpactLevel impact;
  final bool impactConfirmed;
  final IncidentStatus status;
  final GamePhase? gamePhase;
  final FieldZone? fieldZone;
  final Decision? decisionTaken;
  final Decision? decisionExpected;
  final String? notes;

  /// Ley o infracción concreta de la acción (catálogo o personalizada), sea acierto o error.
  final InfractionRef? infraction;

  bool get needsReview => status != IncidentStatus.voided && verdict == Verdict.pending;
  bool get isVoid => status == IncidentStatus.voided;

  Incident copyWith({
    IncidentCategory? category,
    String? criterionCode,
    QuickPolarity? polarity,
    Verdict? verdict,
    ImpactLevel? impact,
    bool? impactConfirmed,
    IncidentStatus? status,
    Object? gamePhase = _keep,
    Object? fieldZone = _keep,
    Object? decisionTaken = _keep,
    Object? decisionExpected = _keep,
    Object? notes = _keep,
    Object? infraction = _keep,
  }) =>
      Incident(
        id: id,
        assessmentId: assessmentId,
        seq: seq,
        sessionMs: sessionMs,
        wallUtc: wallUtc,
        matchTime: matchTime,
        category: category ?? this.category,
        criterionCode: criterionCode ?? this.criterionCode,
        polarity: polarity ?? this.polarity,
        verdict: verdict ?? this.verdict,
        impact: impact ?? this.impact,
        impactConfirmed: impactConfirmed ?? this.impactConfirmed,
        status: status ?? this.status,
        gamePhase: identical(gamePhase, _keep) ? this.gamePhase : gamePhase as GamePhase?,
        fieldZone: identical(fieldZone, _keep) ? this.fieldZone : fieldZone as FieldZone?,
        decisionTaken: identical(decisionTaken, _keep) ? this.decisionTaken : decisionTaken as Decision?,
        decisionExpected: identical(decisionExpected, _keep) ? this.decisionExpected : decisionExpected as Decision?,
        notes: identical(notes, _keep) ? this.notes : notes as String?,
        infraction: identical(infraction, _keep) ? this.infraction : infraction as InfractionRef?,
      );

  /// Igualdad de contenido editable (para saber si hay cambios sin guardar).
  bool sameContentAs(Incident o) =>
      o.category == category &&
      o.criterionCode == criterionCode &&
      o.polarity == polarity &&
      o.verdict == verdict &&
      o.impact == impact &&
      o.impactConfirmed == impactConfirmed &&
      o.status == status &&
      o.gamePhase == gamePhase &&
      o.fieldZone == fieldZone &&
      o.decisionTaken == decisionTaken &&
      o.decisionExpected == decisionExpected &&
      (o.notes ?? '') == (notes ?? '') &&
      o.infraction == infraction;
}

/// Valores iniciales de un tap (usecases.ts, quickTagDefaults).
({Verdict verdict, ImpactLevel impact, bool impactConfirmed}) quickTagDefaults(
  QuickPolarity polarity, [
  ImpactLevel? severity,
]) =>
    (
      verdict: polarity == QuickPolarity.positive ? Verdict.correct : Verdict.pending,
      impact: severity ?? (polarity == QuickPolarity.positive ? ImpactLevel.low : ImpactLevel.medium),
      impactConfirmed: severity != null,
    );
