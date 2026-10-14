// Estado de la pantalla 3. Toda la lógica (sugerencias, topes, agregación, avisos de cierre,
// hash) vive en el dominio puro; aquí solo se orquesta y se persiste. Desde la rúbrica CARC nada
// es obligatorio para cerrar: las competencias sin valorar y los textos vacíos no cuentan.
//
// Persistencia: cada cambio se guarda en orden. Los textos (justificaciones, resumen, hallazgos)
// se guardan con un retardo de 400 ms tras la última pulsación; flush() los fuerza (al cerrar o
// al salir de la pantalla).

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/platform_ports.dart';
import '../../data/evaluation_repository.dart';
import '../../domain/model.dart';
import '../../domain/report.dart';
import '../../domain/rubric.dart';
import '../../domain/scoring.dart';

enum EvaluationLoadState { loading, ready, failed }

class EvaluationController extends ChangeNotifier {
  EvaluationController({
    required this.assessmentId,
    required EvaluationRepository repository,
    required this.rubric,
    required this._ids,
    DateTime Function()? now,
    this.textDebounce = const Duration(milliseconds: 400),
  }) : _repo = repository,
       _now = now ?? (() => DateTime.now().toUtc());

  final String assessmentId;
  final AssessmentRubric rubric;
  final Duration textDebounce;
  final EvaluationRepository _repo;
  final IdGenerator _ids;
  final DateTime Function() _now;

  EvaluationLoadState loadState = EvaluationLoadState.loading;
  String refereeName = '';
  String homeTeam = '';
  String awayTeam = '';
  List<Incident> incidents = const [];
  Map<String, SuggestedScore> suggestions = const {};
  final Map<String, CriterionEvaluation> _evaluations = {};
  String summary = '';
  final List<Finding> _findings = [];
  final List<ActionPoint> _actionPoints = [];
  List<PreviousActionPoint> openPrevious = const [];
  final Map<String, ActionPointReview> _previousReviews = {};
  FinalizedInfo? finalized;

  /// Dificultad estimada (preparación del partido) y real (se valora al cerrar). LOW…VERY_HIGH.
  String? estimatedDifficulty;
  String? actualDifficulty;

  /// Recomendación del CARC sobre el nivel de los próximos partidos.
  LevelRecommendation? levelRecommendation;

  bool saveFailed = false;
  bool finalizing = false;
  bool _disposed = false;

  final List<Future<void> Function()> _queue = [];
  bool _draining = false;
  final Map<String, Timer> _debouncers = {};
  final Map<String, Future<void> Function()> _debounced = {};

  // ───────────── Lectura derivada ─────────────

  bool get isFinalized => finalized != null;
  CriterionEvaluation? evaluationOf(String code) => _evaluations[code];
  List<Finding> findingsOf(FindingKind kind) => [
    for (final f in _findings)
      if (f.kind == kind) f,
  ];
  List<ActionPoint> get actionPoints => List.unmodifiable(_actionPoints);
  ActionPointReview? previousReviewOf(String id) => _previousReviews[id];

  Map<String, CriterionChoice> get _choices => {
    for (final e in _evaluations.values) e.criterionCode: CriterionChoice(finalBand: e.finalBand, notObserved: e.notObserved),
  };

  AggregateResult get aggregateResult => aggregate(rubric, _choices);
  KeyDecisionAccuracy get keyDecisions => keyDecisionAccuracy(incidents);

  /// ¿Competencia valorada (banda o "no observado")? Solo sirve para mostrar el progreso.
  bool isComplete(String code) => isRated(_evaluations[code]);
  int get completedCount => rubric.criteria.where((c) => isComplete(c.code)).length;
  int completedIn(RubricArea a) => a.criteria.where((c) => isComplete(c.code)).length;

  /// Avisos antes de cerrar (nunca bloquean).
  List<CloseIssue> get closeWarningsList => closeWarnings(
    rubric: rubric,
    incidents: incidents,
    evaluations: _evaluations,
    openPrevious: openPrevious,
    previousReviews: _previousReviews,
  );

  // ───────────── Carga ─────────────

  Future<void> load() async {
    loadState = EvaluationLoadState.loading;
    _notify();
    try {
      final s = await _repo.loadEvaluation(assessmentId);
      refereeName = s.refereeName;
      homeTeam = s.homeTeam;
      awayTeam = s.awayTeam;
      incidents = s.incidents;
      suggestions = {for (final c in rubric.criteria) c.code: suggestCriterionScore(c.code, incidents, rubric)};
      _evaluations
        ..clear()
        ..addAll(s.evaluations);
      summary = s.summary;
      _findings
        ..clear()
        ..addAll(s.findings);
      _actionPoints
        ..clear()
        ..addAll(s.actionPoints);
      openPrevious = s.openPrevious;
      _previousReviews
        ..clear()
        ..addAll(s.previousReviews);
      finalized = s.finalized;
      estimatedDifficulty = s.estimatedDifficulty;
      actualDifficulty = s.actualDifficulty;
      levelRecommendation = s.levelRecommendation;
      loadState = EvaluationLoadState.ready;
    } catch (_) {
      loadState = EvaluationLoadState.failed;
    }
    _notify();
  }

  // ───────────── Criterios ─────────────

  CriterionEvaluation _eval(String code) => _evaluations[code] ?? CriterionEvaluation(criterionCode: code);

  void setBand(String code, BandCode band) {
    if (isFinalized) return;
    _evaluations[code] = _eval(code).copyWith(finalBand: band, notObserved: false);
    _saveCriterion(code);
  }

  /// Quita la banda elegida: la competencia vuelve a quedar sin valorar (no cuenta).
  void clearBand(String code) {
    if (isFinalized) return;
    _evaluations[code] = _eval(code).copyWith(finalBand: null);
    _saveCriterion(code);
  }

  void setNotObserved(String code, bool value) {
    if (isFinalized) return;
    _evaluations[code] = _eval(code).copyWith(notObserved: value, finalBand: value ? null : _eval(code).finalBand);
    _saveCriterion(code);
  }

  void setJustification(String code, String text) {
    if (isFinalized) return;
    _evaluations[code] = _eval(code).copyWith(justification: text);
    _notify();
    _debounce('crit:$code', () => _repo.saveCriterion(assessmentId, _eval(code), suggestions[code]!));
  }

  void _saveCriterion(String code) {
    _cancelDebounce('crit:$code');
    final e = _eval(code), s = suggestions[code]!;
    _notify();
    _enqueue(() => _repo.saveCriterion(assessmentId, e, s));
  }

  // ───────────── Cierre: resumen, hallazgos, recomendaciones ─────────────

  void setSummary(String text) {
    if (isFinalized) return;
    summary = text;
    _notify();
    _debounce('summary', () => _repo.saveSummary(assessmentId, summary));
  }

  /// Dificultad real del partido (null = sin indicar).
  void setActualDifficulty(String? code) {
    if (isFinalized) return;
    actualDifficulty = code;
    _notify();
    _enqueue(() => _repo.saveActualDifficulty(assessmentId, code));
  }

  /// Recomendación de nivel del CARC (null = sin indicar).
  void setLevelRecommendation(LevelRecommendation? r) {
    if (isFinalized) return;
    levelRecommendation = r;
    _notify();
    _enqueue(() => _repo.saveLevelRecommendation(assessmentId, r));
  }

  /// Competencia por defecto: la primera valorada E (fortaleza) o U / N (mejora).
  String _defaultCriterion(FindingKind kind) {
    final wanted = kind == FindingKind.strength ? const {BandCode.excellent} : const {BandCode.urgent, BandCode.notYet};
    for (final c in rubric.criteria) {
      if (wanted.contains(_evaluations[c.code]?.finalBand)) return c.code;
    }
    return rubric.criteria.first.code;
  }

  Finding? addFinding(FindingKind kind) {
    if (isFinalized || findingsOf(kind).length >= 3) return null;
    final f = Finding(id: _ids.next(), kind: kind, criterionCode: _defaultCriterion(kind), text: '');
    _findings.add(f);
    _notify();
    final pos = _findings.length;
    _enqueue(() => _repo.upsertFinding(assessmentId, f, pos));
    return f;
  }

  void updateFinding(String id, {String? criterionCode, String? text}) {
    if (isFinalized) return;
    final idx = _findings.indexWhere((f) => f.id == id);
    _findings[idx] = _findings[idx].copyWith(criterionCode: criterionCode, text: text);
    _notify();
    Future<void> op() {
      final i = _findings.indexWhere((f) => f.id == id);
      return i < 0 ? Future.value() : _repo.upsertFinding(assessmentId, _findings[i], i + 1);
    }

    text != null ? _debounce('finding:$id', op) : _enqueue(op);
  }

  void removeFinding(String id) {
    if (isFinalized) return;
    _cancelDebounce('finding:$id');
    _findings.removeWhere((f) => f.id == id);
    _notify();
    _enqueue(() => _repo.deleteFinding(id));
  }

  ActionPoint? addActionPoint() {
    if (isFinalized || _actionPoints.length >= 3) return null;
    final a = ActionPoint(
      id: _ids.next(),
      criterionCode: _defaultCriterion(FindingKind.development),
      text: '',
      successIndicator: '',
    );
    _actionPoints.add(a);
    _notify();
    _enqueue(() => _repo.upsertActionPoint(assessmentId, a));
    return a;
  }

  void updateActionPoint(String id, {String? criterionCode, String? text, String? successIndicator}) {
    if (isFinalized) return;
    final idx = _actionPoints.indexWhere((a) => a.id == id);
    _actionPoints[idx] = _actionPoints[idx].copyWith(
      criterionCode: criterionCode,
      text: text,
      successIndicator: successIndicator,
    );
    _notify();
    Future<void> op() {
      final i = _actionPoints.indexWhere((a) => a.id == id);
      return i < 0 ? Future.value() : _repo.upsertActionPoint(assessmentId, _actionPoints[i]);
    }

    criterionCode != null ? _enqueue(op) : _debounce('ap:$id', op);
  }

  void removeActionPoint(String id) {
    if (isFinalized) return;
    _cancelDebounce('ap:$id');
    _actionPoints.removeWhere((a) => a.id == id);
    _notify();
    _enqueue(() => _repo.deleteActionPoint(id));
  }

  void setPreviousReview(String id, {ActionPointReviewStatus? status, String? comment}) {
    if (isFinalized) return;
    final current = _previousReviews[id];
    final st = status ?? current?.status;
    if (st == null) return; // el comentario solo tiene sentido con un estado elegido
    _previousReviews[id] = ActionPointReview(actionPointId: id, status: st, comment: comment ?? current?.comment ?? '');
    _notify();
    Future<void> op() => _repo.savePreviousReview(assessmentId, _previousReviews[id]!);
    comment != null ? _debounce('prev:$id', op) : _enqueue(op);
  }

  // ───────────── Cierre del informe ─────────────

  /// Cierra el informe. Nada es obligatorio: los avisos ([closeWarningsList]) se enseñan antes,
  /// pero no impiden cerrar. Las fortalezas, áreas de mejora y recomendaciones sin texto se
  /// descartan (un hueco vacío no es contenido del informe).
  Future<void> finalize() async {
    if (isFinalized) return;
    finalizing = true;
    _notify();
    try {
      for (final f in [..._findings.where((f) => f.text.trim().isEmpty)]) {
        removeFinding(f.id);
      }
      for (final a in [..._actionPoints.where((a) => a.text.trim().isEmpty)]) {
        removeActionPoint(a.id);
      }
      await flush();
      if (saveFailed) throw StateError('PENDING_WRITES');
      final at = _now();
      final agg = aggregateResult;
      final keys = keyDecisions;
      final signed = buildSignedReport(
        version: 1,
        finalizedAt: at,
        rubric: rubric,
        suggestions: suggestions,
        evaluations: _evaluations,
        aggregate: agg,
        keyDecisions: keys,
        summary: summary,
        findings: _findings,
        actionPoints: _actionPoints,
        openPrevious: openPrevious,
        previousReviews: _previousReviews,
        actualDifficulty: actualDifficulty,
        levelRecommendation: levelRecommendation,
      );
      final hash = contentHash(signed);
      await _repo.finalize(
        assessmentId,
        FinalizationData(
          finalizedAt: at,
          signedReport: signed,
          contentHash: hash,
          aggregate: agg,
          keyDecisions: keys,
          suggestions: suggestions,
          evaluations: Map.of(_evaluations),
          summary: summary,
          findings: List.of(_findings),
          actionPoints: List.of(_actionPoints),
          previousReviews: Map.of(_previousReviews),
          actualDifficulty: actualDifficulty,
          levelRecommendation: levelRecommendation,
        ),
      );
      finalized = FinalizedInfo(at: at, contentHash: hash, band: agg.band);
    } finally {
      finalizing = false;
      _notify();
    }
  }

  // ───────────── Escritura ordenada ─────────────

  void _debounce(String key, Future<void> Function() op) {
    _debouncers[key]?.cancel();
    _debounced[key] = op;
    _debouncers[key] = Timer(textDebounce, () {
      _debouncers.remove(key);
      final pending = _debounced.remove(key);
      if (pending != null) _enqueue(pending);
    });
  }

  void _cancelDebounce(String key) {
    _debouncers.remove(key)?.cancel();
    _debounced.remove(key);
  }

  void _enqueue(Future<void> Function() op) {
    _queue.add(op);
    _drain();
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    while (_queue.isNotEmpty) {
      try {
        await _queue.first();
        _queue.removeAt(0);
        if (saveFailed) {
          saveFailed = false;
          _notify();
        }
      } catch (_) {
        saveFailed = true;
        _notify();
        break;
      }
    }
    _draining = false;
  }

  Future<void> retryPendingWrites() => _drain();

  /// Fuerza los textos pendientes y espera a que la cola quede vacía (o falle).
  Future<void> flush() async {
    for (final key in _debouncers.keys.toList()) {
      _debouncers.remove(key)?.cancel();
      final op = _debounced.remove(key);
      if (op != null) _queue.add(op);
    }
    await _drain();
    while (_draining) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    // Nunca se pierde texto: lo pendiente de escribir se encola y se vacía aunque la pantalla
    // ya no exista (el repositorio vive más que el controlador).
    unawaited(flush());
    super.dispose();
  }
}
