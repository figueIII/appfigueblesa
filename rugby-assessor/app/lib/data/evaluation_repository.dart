// Persistencia de la evaluación por criterios (pantalla 3): borrador del informe v1 y cierre.

import '../domain/model.dart';
import '../domain/report.dart';
import '../domain/rubric.dart';
import '../domain/scoring.dart';

class FinalizedInfo {
  const FinalizedInfo({required this.at, required this.contentHash, required this.band});
  final DateTime at;
  final String contentHash;
  final BandCode? band;
}

class EvaluationSnapshot {
  const EvaluationSnapshot({
    required this.assessmentId,
    required this.refereeName,
    required this.homeTeam,
    required this.awayTeam,
    required this.incidents,
    required this.evaluations,
    required this.summary,
    required this.findings,
    required this.actionPoints,
    required this.openPrevious,
    required this.previousReviews,
    this.finalized,
  });
  final String assessmentId;
  final String refereeName;
  final String homeTeam;
  final String awayTeam;
  final List<Incident> incidents;
  final Map<String, CriterionEvaluation> evaluations;
  final String summary;
  final List<Finding> findings;
  final List<ActionPoint> actionPoints;
  final List<PreviousActionPoint> openPrevious;
  final Map<String, ActionPointReview> previousReviews;
  final FinalizedInfo? finalized;
}

/// Lo que se congela al cerrar.
class FinalizationData {
  const FinalizationData({
    required this.finalizedAt,
    required this.signedReport,
    required this.contentHash,
    required this.aggregate,
    required this.keyDecisions,
    required this.suggestions,
    required this.evaluations,
    required this.summary,
    required this.findings,
    required this.actionPoints,
    required this.previousReviews,
  });
  final DateTime finalizedAt;
  final Map<String, Object?> signedReport;
  final String contentHash;
  final AggregateResult aggregate;
  final KeyDecisionAccuracy keyDecisions;
  final Map<String, SuggestedScore> suggestions;
  final Map<String, CriterionEvaluation> evaluations;
  final String summary;
  final List<Finding> findings;
  final List<ActionPoint> actionPoints;
  final Map<String, ActionPointReview> previousReviews;
}

abstract interface class EvaluationRepository {
  Future<EvaluationSnapshot> loadEvaluation(String assessmentId);
  Future<void> saveCriterion(String assessmentId, CriterionEvaluation e, SuggestedScore s);
  Future<void> saveSummary(String assessmentId, String summary);
  Future<void> upsertFinding(String assessmentId, Finding f, int position);
  Future<void> deleteFinding(String findingId);
  Future<void> upsertActionPoint(String assessmentId, ActionPoint a);
  Future<void> deleteActionPoint(String actionPointId);
  Future<void> savePreviousReview(String assessmentId, ActionPointReview r);

  /// Cierre en UNA transacción: informe FINALIZED con JSON canónico y hash, recomendaciones
  /// nuevas a OPEN, recomendaciones previas logradas a CLOSED, evaluación FINALIZED y outbox.
  Future<void> finalize(String assessmentId, FinalizationData data);
}

/// Implementación en memoria para tests de widget y demos.
class InMemoryEvaluationRepository implements EvaluationRepository {
  InMemoryEvaluationRepository(this._seed);
  EvaluationSnapshot _seed;
  bool failWrites = false;
  FinalizationData? finalizedWith;
  final Map<String, CriterionEvaluation> evaluations = {};
  final Map<String, Finding> findings = {};
  final Map<String, ActionPoint> actionPoints = {};
  final Map<String, ActionPointReview> reviews = {};
  String summary = '';

  void _guard() {
    if (failWrites) throw StateError('STORAGE_WRITE_FAILED');
  }

  @override
  Future<EvaluationSnapshot> loadEvaluation(String assessmentId) async => EvaluationSnapshot(
        assessmentId: _seed.assessmentId,
        refereeName: _seed.refereeName,
        homeTeam: _seed.homeTeam,
        awayTeam: _seed.awayTeam,
        incidents: _seed.incidents,
        evaluations: {..._seed.evaluations, ...evaluations},
        summary: summary.isEmpty ? _seed.summary : summary,
        findings: [..._seed.findings, ...findings.values],
        actionPoints: [..._seed.actionPoints, ...actionPoints.values],
        openPrevious: _seed.openPrevious,
        previousReviews: {..._seed.previousReviews, ...reviews},
        finalized: _seed.finalized,
      );

  @override
  Future<void> saveCriterion(String assessmentId, CriterionEvaluation e, SuggestedScore s) async {
    _guard();
    evaluations[e.criterionCode] = e;
  }

  @override
  Future<void> saveSummary(String assessmentId, String s) async {
    _guard();
    summary = s;
  }

  @override
  Future<void> upsertFinding(String assessmentId, Finding f, int position) async {
    _guard();
    findings[f.id] = f;
  }

  @override
  Future<void> deleteFinding(String findingId) async {
    _guard();
    findings.remove(findingId);
  }

  @override
  Future<void> upsertActionPoint(String assessmentId, ActionPoint a) async {
    _guard();
    actionPoints[a.id] = a;
  }

  @override
  Future<void> deleteActionPoint(String actionPointId) async {
    _guard();
    actionPoints.remove(actionPointId);
  }

  @override
  Future<void> savePreviousReview(String assessmentId, ActionPointReview r) async {
    _guard();
    reviews[r.actionPointId] = r;
  }

  @override
  Future<void> finalize(String assessmentId, FinalizationData data) async {
    _guard();
    finalizedWith = data;
    _seed = EvaluationSnapshot(
      assessmentId: _seed.assessmentId,
      refereeName: _seed.refereeName,
      homeTeam: _seed.homeTeam,
      awayTeam: _seed.awayTeam,
      incidents: _seed.incidents,
      evaluations: _seed.evaluations,
      summary: _seed.summary,
      findings: _seed.findings,
      actionPoints: _seed.actionPoints,
      openPrevious: _seed.openPrevious,
      previousReviews: _seed.previousReviews,
      finalized: FinalizedInfo(at: data.finalizedAt, contentHash: data.contentHash, band: data.aggregate.band),
    );
  }
}
