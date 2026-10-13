// Subconjunto del modelo de dominio (domain/model.ts) que necesita la captura en directo.

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

/// Mapa categoría → criterio de la rúbrica v2.0.0 (rubric-default.ts, categoryToCriterion).
const Map<IncidentCategory, String> kCategoryToCriterion = {
  IncidentCategory.scrum: 'A1_SCRUM',
  IncidentCategory.lineout: 'A2_LINEOUT_MAUL',
  IncidentCategory.maul: 'A2_LINEOUT_MAUL',
  IncidentCategory.tackle: 'A3_TACKLE_RUCK',
  IncidentCategory.ruck: 'A3_TACKLE_RUCK',
  IncidentCategory.offside: 'A4_OFFSIDE_SPACE',
  IncidentCategory.communication: 'B1_VERBAL_CONTROL',
  IncidentCategory.captainMgmt: 'B3_CAPTAINS_PLAYERS',
  IncidentCategory.advantage: 'B4_ADVANTAGE',
  IncidentCategory.tryGrounding: 'C1_LAW_ACCURACY',
  IncidentCategory.knockOnForwardPass: 'C1_LAW_ACCURACY',
  IncidentCategory.otherLaw: 'C1_LAW_ACCURACY',
  IncidentCategory.foulPlay: 'C2_FOUL_PLAY',
  IncidentCategory.tmoProcess: 'C2_FOUL_PLAY',
  IncidentCategory.card: 'C3_SANCTION_CONSISTENCY',
  IncidentCategory.fitness: 'D1_FITNESS',
  IncidentCategory.positioning: 'D2_POSITIONING',
  IncidentCategory.runningLine: 'D3_RUNNING_LINES',
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

/// Incidencia tal y como la crea el tap. El enriquecimiento llega en la pantalla 2.
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

  bool get needsReview => status != IncidentStatus.voided && verdict == Verdict.pending;

  Incident copyWith({QuickPolarity? polarity, Verdict? verdict, ImpactLevel? impact, IncidentStatus? status}) =>
      Incident(
        id: id,
        assessmentId: assessmentId,
        seq: seq,
        sessionMs: sessionMs,
        wallUtc: wallUtc,
        matchTime: matchTime,
        category: category,
        criterionCode: criterionCode,
        polarity: polarity ?? this.polarity,
        verdict: verdict ?? this.verdict,
        impact: impact ?? this.impact,
        impactConfirmed: impactConfirmed,
        status: status ?? this.status,
      );
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
