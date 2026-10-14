// Implementación Drift de la evaluación por criterios. Tablas de persistence/schema.sql v2:
// report · criterion_score · finding · action_point · action_point_review · outbox.
// Informe versión 1 (las enmiendas crearán la versión 2+; fuera de esta entrega).

import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/report.dart' as r;
import '../domain/rubric.dart';
import '../domain/scoring.dart';
import 'db/app_database.dart';
import 'drift_live_session_repository.dart';
import 'evaluation_repository.dart';

const _version = 1;

String? _bandOrNull(BandCode? b) => b == null ? null : r.encodeBand(b);

r.ActionPointReviewStatus _decodeReviewStatus(String s) =>
    r.ActionPointReviewStatus.values.firstWhere((v) => r.encodeReviewStatus(v) == s);

class DriftEvaluationRepository implements EvaluationRepository {
  DriftEvaluationRepository(this.db) : _live = DriftLiveSessionRepository(db);
  final AppDatabase db;
  final DriftLiveSessionRepository _live;

  String _now() => DateTime.now().toUtc().toIso8601String();

  Future<AssessmentData> _assessment(String id) =>
      (db.select(db.assessment)..where((t) => t.id.equals(id))).getSingle();

  /// Crea el borrador v1 si no existe (idempotente).
  Future<ReportData> _ensureDraft(AssessmentData a) async {
    await db.into(db.report).insert(
          ReportCompanion.insert(assessmentId: a.id, version: _version, refereeId: a.refereeId, rubricId: a.rubricId, status: 'DRAFT'),
          mode: InsertMode.insertOrIgnore,
        );
    return (db.select(db.report)..where((t) => t.assessmentId.equals(a.id) & t.version.equals(_version))).getSingle();
  }

  @override
  Future<EvaluationSnapshot> loadEvaluation(String assessmentId) async {
    final a = await _assessment(assessmentId);
    final report = await _ensureDraft(a);
    final referee = await (db.select(db.official)..where((t) => t.id.equals(a.refereeId))).getSingle();
    final review = await _live.loadReview(assessmentId);

    final scores = await (db.select(db.criterionScore)
          ..where((t) => t.assessmentId.equals(assessmentId) & t.version.equals(_version)))
        .get();
    final findings = await (db.select(db.finding)
          ..where((t) => t.assessmentId.equals(assessmentId) & t.version.equals(_version))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    final aps = await (db.select(db.actionPoint)
          ..where((t) => t.originAssessmentId.equals(assessmentId) & t.originVersion.equals(_version))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    // Recomendaciones abiertas de informes anteriores del MISMO árbitro (spec §1.4).
    final previous = await (db.select(db.actionPoint)
          ..where((t) => t.refereeId.equals(a.refereeId) & t.status.equals('OPEN') & t.originAssessmentId.equals(assessmentId).not())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    final reviews = await (db.select(db.actionPointReview)
          ..where((t) => t.assessmentId.equals(assessmentId) & t.version.equals(_version)))
        .get();

    return EvaluationSnapshot(
      assessmentId: assessmentId,
      refereeName: referee.fullName,
      homeTeam: a.homeTeam,
      awayTeam: a.awayTeam,
      incidents: review.incidents,
      evaluations: {
        for (final s in scores)
          s.criterionCode: r.CriterionEvaluation(
            criterionCode: s.criterionCode,
            finalBand: decodeBand(s.finalBand),
            notObserved: s.notObserved == 1,
            justification: s.justification,
          ),
      },
      summary: report.summary,
      findings: [
        for (final f in findings)
          r.Finding(
            id: f.id,
            kind: f.kind == 'STRENGTH' ? r.FindingKind.strength : r.FindingKind.development,
            criterionCode: f.criterionCode,
            text: f.bodyText,
            evidenceIncidentIds: (jsonDecode(f.evidenceJson) as List).cast<String>(),
          ),
      ],
      actionPoints: [
        for (final p in aps) r.ActionPoint(id: p.id, criterionCode: p.criterionCode, text: p.bodyText, successIndicator: p.successIndicator),
      ],
      openPrevious: [
        for (final p in previous)
          r.PreviousActionPoint(id: p.id, criterionCode: p.criterionCode, text: p.bodyText, successIndicator: p.successIndicator),
      ],
      previousReviews: {
        for (final v in reviews)
          v.actionPointId: r.ActionPointReview(actionPointId: v.actionPointId, status: _decodeReviewStatus(v.status), comment: v.comment),
      },
      rubricId: a.rubricId,
      estimatedDifficulty: a.difficulty,
      actualDifficulty: report.actualDifficulty,
      levelRecommendation: r.decodeLevelRecommendation(report.levelRecommendation),
      finalized: report.status == 'FINALIZED'
          ? FinalizedInfo(at: DateTime.parse(report.finalizedAt!), contentHash: report.contentHash!, band: decodeBand(report.band))
          : null,
    );
  }

  CriterionScoreCompanion _scoreRow(String assessmentId, r.CriterionEvaluation e, SuggestedScore s) => CriterionScoreCompanion.insert(
        assessmentId: assessmentId,
        version: _version,
        criterionCode: e.criterionCode,
        suggestedBand: Value(_bandOrNull(s.suggestedBand)),
        suggested: Value(s.suggested),
        // CHECK del esquema: un criterio no observado no tiene banda.
        finalBand: Value(e.notObserved ? null : _bandOrNull(e.finalBand)),
        notObserved: Value(e.notObserved ? 1 : 0),
        justification: Value(e.justification),
        capBand: Value(_bandOrNull(s.capBand)),
        evidenceJson: Value(jsonEncode(s.evidenceIncidentIds)),
      );

  @override
  Future<void> saveCriterion(String assessmentId, r.CriterionEvaluation e, SuggestedScore s) =>
      db.into(db.criterionScore).insertOnConflictUpdate(_scoreRow(assessmentId, e, s));

  @override
  Future<void> saveSummary(String assessmentId, String summary) =>
      (db.update(db.report)..where((t) => t.assessmentId.equals(assessmentId) & t.version.equals(_version)))
          .write(ReportCompanion(summary: Value(summary)));

  @override
  Future<void> upsertFinding(String assessmentId, r.Finding f, int position) =>
      db.into(db.finding).insertOnConflictUpdate(FindingCompanion.insert(
            id: f.id,
            assessmentId: assessmentId,
            version: _version,
            kind: f.kind == r.FindingKind.strength ? 'STRENGTH' : 'DEVELOPMENT',
            criterionCode: f.criterionCode,
            bodyText: f.text,
            evidenceJson: Value(jsonEncode(f.evidenceIncidentIds)),
            position: position,
          ));

  @override
  Future<void> deleteFinding(String findingId) => (db.delete(db.finding)..where((t) => t.id.equals(findingId))).go();

  @override
  Future<void> upsertActionPoint(String assessmentId, r.ActionPoint a) async {
    final as = await _assessment(assessmentId);
    final existing = await (db.select(db.actionPoint)..where((t) => t.id.equals(a.id))).getSingleOrNull();
    await db.into(db.actionPoint).insertOnConflictUpdate(ActionPointCompanion.insert(
          id: a.id,
          refereeId: as.refereeId,
          originAssessmentId: assessmentId,
          originVersion: _version,
          criterionCode: a.criterionCode,
          bodyText: a.text,
          successIndicator: a.successIndicator,
          status: 'DRAFT', // pasa a OPEN al cerrar el informe
          createdAt: existing?.createdAt ?? _now(),
        ));
  }

  @override
  Future<void> deleteActionPoint(String actionPointId) =>
      (db.delete(db.actionPoint)..where((t) => t.id.equals(actionPointId) & t.status.equals('DRAFT'))).go();

  @override
  Future<void> savePreviousReview(String assessmentId, r.ActionPointReview v) =>
      db.into(db.actionPointReview).insertOnConflictUpdate(ActionPointReviewCompanion.insert(
            assessmentId: assessmentId,
            version: _version,
            actionPointId: v.actionPointId,
            status: r.encodeReviewStatus(v.status),
            comment: v.comment,
          ));

  Future<void> _writeDraft(String assessmentId, ReportCompanion c) =>
      (db.update(db.report)..where((t) => t.assessmentId.equals(assessmentId) & t.version.equals(_version) & t.status.equals('DRAFT')))
          .write(c);

  @override
  Future<void> saveActualDifficulty(String assessmentId, String? difficulty) =>
      _writeDraft(assessmentId, ReportCompanion(actualDifficulty: Value(difficulty)));

  @override
  Future<void> saveLevelRecommendation(String assessmentId, r.LevelRecommendation? recommendation) => _writeDraft(
        assessmentId,
        ReportCompanion(levelRecommendation: Value(recommendation == null ? null : r.encodeLevelRecommendation(recommendation))),
      );

  @override
  Future<void> finalize(String assessmentId, FinalizationData d) => db.transaction(() async {
        // 1) Todas las filas de criterio, con la sugerencia con la que se cerró.
        for (final entry in d.suggestions.entries) {
          final e = d.evaluations[entry.key] ?? r.CriterionEvaluation(criterionCode: entry.key);
          await db.into(db.criterionScore).insertOnConflictUpdate(_scoreRow(assessmentId, e, entry.value));
        }
        // 2) Informe congelado (a partir de aquí el trigger report_finalized_immutable lo protege).
        final n = await (db.update(db.report)
              ..where((t) => t.assessmentId.equals(assessmentId) & t.version.equals(_version) & t.status.equals('DRAFT')))
            .write(ReportCompanion(
          status: const Value('FINALIZED'),
          summary: Value(d.summary.trim()),
          actualDifficulty: Value(d.actualDifficulty),
          levelRecommendation: Value(d.levelRecommendation == null ? null : r.encodeLevelRecommendation(d.levelRecommendation!)),
          band: Value(_bandOrNull(d.aggregate.band)),
          overallScore: Value(d.aggregate.overallScore),
          keyCorrect: Value(d.keyDecisions.correct),
          keyTotal: Value(d.keyDecisions.total),
          finalizedAt: Value(d.finalizedAt.toUtc().toIso8601String()),
          canonicalJson: Value(r.canonicalJson(d.signedReport)),
          contentHash: Value(d.contentHash),
        ));
        if (n != 1) throw StateError('REPORT_NOT_DRAFT');
        // 3) Recomendaciones nuevas: DRAFT → OPEN (el próximo evaluador deberá revisarlas).
        await (db.update(db.actionPoint)
              ..where((t) => t.originAssessmentId.equals(assessmentId) & t.status.equals('DRAFT')))
            .write(const ActionPointCompanion(status: Value('OPEN')));
        // 4) Recomendaciones anteriores logradas: OPEN → CLOSED.
        for (final v in d.previousReviews.values.where((v) => v.status == r.ActionPointReviewStatus.achieved)) {
          await (db.update(db.actionPoint)..where((t) => t.id.equals(v.actionPointId))).write(ActionPointCompanion(
            status: const Value('CLOSED'),
            closedByAssessmentId: Value(assessmentId),
          ));
        }
        // 5) Evaluación cerrada (bloquea las incidencias por trigger) y aviso para una futura sincronización.
        await (db.update(db.assessment)..where((t) => t.id.equals(assessmentId)))
            .write(AssessmentCompanion(status: const Value('FINALIZED'), updatedAt: Value(_now())));
        await db.into(db.outbox).insert(OutboxCompanion.insert(
              aggregateId: assessmentId,
              kind: 'REPORT_FINALIZED',
              payloadJson: jsonEncode({'assessmentId': assessmentId, 'version': _version, 'contentHash': d.contentHash}),
              createdAt: _now(),
            ));
      });
}
