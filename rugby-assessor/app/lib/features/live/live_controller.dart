// Estado y lógica de la pantalla de directo. La UI solo lee este controlador y llama a sus
// métodos; toda la lógica de reloj vive en domain/clock.dart (puro y probado).
//
// Política de escritura (spec §3.1, cero pérdidas): la marca se aplica en memoria y se
// confirma al usuario en el mismo frame (háptica + visual); la escritura se encola en orden
// estricto. Si falla, la cola se conserva, se avisa y se reintenta sin perder el orden.

import 'package:flutter/foundation.dart';

import '../../core/platform_ports.dart';
import '../../data/live_session_repository.dart';
import '../../data/session_time.dart';
import '../../domain/clock.dart';
import '../../domain/laws.dart';
import '../../domain/match_facts.dart';
import '../../domain/model.dart';

enum LiveLoadState { loading, ready, failed }

/// Acción principal del reloj según el estado (un único botón contextual).
sealed class PrimaryClockAction {
  const PrimaryClockAction();
}

final class StartPeriodAction extends PrimaryClockAction {
  const StartPeriodAction(this.period);
  final PeriodId period;
}

final class StopTimeAction extends PrimaryClockAction {
  const StopTimeAction();
}

final class ResumeTimeAction extends PrimaryClockAction {
  const ResumeTimeAction();
}

final class GoToReviewAction extends PrimaryClockAction {
  const GoToReviewAction();
}

/// Opción para cerrar el periodo en curso (requiere mantener pulsado).
class EndPeriodOption {
  const EndPeriodOption(this.next, this.label);
  final PeriodEndNext next;
  final String label;
}

class LiveController extends ChangeNotifier {
  LiveController({
    required this.assessmentId,
    required LiveSessionRepository repository,
    required this._clock,
    required this._ids,
    required this._haptics,
    AnchorResolution? clockRecovery,
  })  : _repo = repository,
        _recovery = clockRecovery;

  final String assessmentId;
  final LiveSessionRepository _repo;
  final SessionClock _clock;
  final IdGenerator _ids;
  final Haptics _haptics;

  /// Resultado de abrir el reloj de sesión (data/session_time.dart). Si el ancla es estimada
  /// (reinicio del móvil) y el reloj de partido estaba en marcha, se registra INTEGRITY_LOST.
  AnchorResolution? _recovery;

  LiveLoadState loadState = LiveLoadState.loading;
  late CategoryConfig category;
  String homeTeam = '';
  String awayTeam = '';
  List<ClockEvent> _clockLog = const [];
  ClockState clockState = ClockState.initial;
  final List<Incident> _incidents = [];
  final List<ScoreEvent> _scores = [];

  String? _lastIncidentId;
  int _refineUntil = 0;

  final List<Future<void> Function()> _pendingWrites = [];
  bool _draining = false;
  bool saveFailed = false;
  bool _disposed = false;

  // ───────────── Lectura ─────────────

  int now() => _clock.now();

  List<Incident> get incidents => List.unmodifiable(_incidents);
  Iterable<Incident> get _active => _incidents.where((i) => i.status != IncidentStatus.voided);
  int get activeCount => _active.length;
  int get pendingReviewCount => _active.where((i) => i.needsReview).length;
  int countFor(IncidentCategory c) => _active.where((i) => i.category == c).length;
  int get pendingWriteCount => _pendingWrites.length;

  Incident? get lastIncident =>
      _lastIncidentId == null ? null : _incidents.firstWhere((i) => i.id == _lastIncidentId);

  /// ¿Se puede valorar o deshacer la última marca ahora?
  bool canRefine(int nowMs) {
    final last = lastIncident;
    return last != null && last.status != IncidentStatus.voided && nowMs < _refineUntil;
  }

  int get refineUntil => _refineUntil;

  MatchTimeStamp matchTimeAt(int t) {
    final state = t >= clockState.lastT ? clockState : foldClock(_clockLog, category, upTo: t);
    return matchTimeAtState(state, t, category);
  }

  PrimaryClockAction get primaryAction => switch (clockState.status) {
        ClockStatus.preMatch || ClockStatus.interval => StartPeriodAction(
            expectedNextPeriod(clockState.completedPeriods, category) ?? PeriodId.h1,
          ),
        ClockStatus.running => const StopTimeAction(),
        ClockStatus.stopped => const ResumeTimeAction(),
        ClockStatus.fullTime || ClockStatus.abandoned => const GoToReviewAction(),
      };

  /// Opciones de cierre del periodo en curso. Vacía si no se está jugando.
  List<EndPeriodOption> get endPeriodOptions {
    if (!clockState.isPlaying) return const [];
    final p = clockState.period!;
    final more = expectedNextPeriod([...clockState.completedPeriods, p], category) != null;
    if (p == PeriodId.h1) return const [EndPeriodOption(PeriodEndNext.interval, 'Fin de la 1ª parte')];
    return [
      const EndPeriodOption(PeriodEndNext.fullTime, 'Final del partido'),
      if (more) EndPeriodOption(PeriodEndNext.interval, 'Fin de ${periodLabel(p).toLowerCase()} · sigue'),
    ];
  }

  bool get canUndoClock => effectiveEvents(_clockLog).isNotEmpty;

  // Marcador y sanciones: todo derivado de los registros activos (match_facts.dart).
  List<ScoreEvent> get scores => List.unmodifiable(_scores);
  /// Sanciones = decisiones tomadas (golpe o tarjeta contra un equipo) de las marcas.
  List<SanctionEvent> get sanctions => sanctionsOf(_incidents);
  Scoreline get scoreline => scorelineOf(_scores);
  bool canConvert(TeamSide team) => conversionAvailable(_scores, team);
  ScoreEvent? get lastScore => lastActiveScore(_scores);
  SanctionTally get sanctionTally => SanctionTally(sanctions);
  List<InfractionCount> breakdown(TeamSide team) => breakdownOf(sanctions, team);
  List<SanctionEvent> cards(TeamSide team) => cardsOf(sanctions, team);
  SanctionEvent? get lastSanction => lastActiveSanction(sanctions);
  String teamName(TeamSide t) => t == TeamSide.home ? homeTeam : awayTeam;

  List<ClockEvent> get clockLog => List.unmodifiable(_clockLog);

  // ───────────── Carga ─────────────

  Future<void> load() async {
    loadState = LiveLoadState.loading;
    _notify();
    try {
      final snap = await _repo.load(assessmentId);
      category = snap.category;
      homeTeam = snap.homeTeam;
      awayTeam = snap.awayTeam;
      _clockLog = snap.clockLog;
      clockState = foldClock(_clockLog, category);
      _incidents
        ..clear()
        ..addAll(snap.incidents);
      _scores
        ..clear()
        ..addAll(snap.scores);
      loadState = LiveLoadState.ready;
      final recovery = _recovery;
      _recovery = null; // una sola vez, aunque se recargue
      if (recovery != null && recovery.estimated && clockState.status == ClockStatus.running) {
        applyClock(IntegrityLost(recovery.estimatedGapMs ?? 0));
      }
    } catch (_) {
      loadState = LiveLoadState.failed;
    }
    _notify();
  }

  /// Vuelve a leer marcas y marcador sin pasar por "Recuperando el partido…" (tras editarlas
  /// desde el directo; el reloj no se toca).
  Future<void> reloadMarks() async {
    await flush();
    final snap = await _repo.load(assessmentId);
    _incidents
      ..clear()
      ..addAll(snap.incidents);
    _scores
      ..clear()
      ..addAll(snap.scores);
    _notify();
  }

  // ───────────── Marcas ─────────────

  /// Registra una marca con el instante `t` capturado al primer contacto del dedo.
  Incident logIncident(IncidentCategory category, {required int t}) {
    final defaults = quickTagDefaults(QuickPolarity.review);
    final incident = Incident(
      id: _ids.next(),
      assessmentId: assessmentId,
      seq: _incidents.length + 1,
      sessionMs: t,
      wallUtc: _clock.wallUtc(),
      matchTime: matchTimeAt(t),
      category: category,
      criterionCode: kCategoryToCriterion[category]!,
      polarity: QuickPolarity.review,
      verdict: defaults.verdict,
      impact: defaults.impact,
      impactConfirmed: defaults.impactConfirmed,
      status: IncidentStatus.quick,
    );
    _incidents.add(incident);
    _lastIncidentId = incident.id;
    _refineUntil = _clock.now() + 10000;
    _haptics.incidentLogged();
    _notify();
    _persist(() => _repo.insertIncident(incident));
    return incident;
  }

  /// Valoración rápida opcional de la última marca (✓ bien / ✗ error / ● revisar).
  void refineLast(QuickPolarity polarity) {
    final last = lastIncident;
    if (last == null || !canRefine(_clock.now()) || last.polarity == polarity) return;
    final d = quickTagDefaults(polarity);
    final updated = last.copyWith(polarity: polarity, verdict: d.verdict, impact: d.impact);
    _replace(updated);
    _haptics.refined();
    _notify();
    _persist(() => _repo.updateIncident(updated));
  }

  /// Anula la última marca (VOID lógico: nunca se borra).
  void undoLast() {
    final last = lastIncident;
    if (last == null || !canRefine(_clock.now())) return;
    final voided = last.copyWith(status: IncidentStatus.voided);
    _replace(voided);
    _refineUntil = 0;
    _haptics.undone();
    _notify();
    _persist(() => _repo.updateIncident(voided));
  }

  /// Ley o infracción de una marca (desde el directo; también fuera de la ventana de 10 s).
  void setIncidentInfraction(String incidentId, InfractionRef? infraction) {
    final idx = _incidents.indexWhere((i) => i.id == incidentId);
    if (idx < 0 || _incidents[idx].isVoid || _incidents[idx].infraction == infraction) return;
    final updated = _incidents[idx].copyWith(infraction: infraction);
    _incidents[idx] = updated;
    _haptics.refined();
    _notify();
    _persist(() => _repo.updateIncident(updated));
  }

  // ───────────── Marcador ─────────────

  /// Suma un tanto al equipo. `t` = instante del toque. Devuelve el error si no es legal ahora
  /// (transformación sin ensayo previo).
  ScoreRuleError? addScore(TeamSide team, ScoreKind kind, {required int t}) {
    final error = validateScore(_scores, team, kind);
    if (error != null) {
      _haptics.warning();
      return error;
    }
    final m = matchTimeAt(t);
    final event = ScoreEvent(
      id: _ids.next(),
      assessmentId: assessmentId,
      seq: _scores.length + 1,
      team: team,
      kind: kind,
      sessionMs: t,
      wallUtc: _clock.wallUtc(),
      period: m.period,
      matchClockMs: m.matchClockMs,
    );
    _scores.add(event);
    _haptics.incidentLogged();
    _notify();
    _persist(() => _repo.insertScoreEvent(event));
    return null;
  }

  /// Anula el último tanto activo (nunca se borra).
  void undoLastScore() {
    final last = lastScore;
    if (last == null) return;
    final voided = last.asVoided();
    _scores[_scores.indexWhere((e) => e.id == last.id)] = voided;
    _haptics.undone();
    _notify();
    _persist(() => _repo.voidScoreEvent(voided));
  }

  // ───────────── Sanciones ─────────────

  /// Registra una sanción del árbitro contra [team] (equipo infractor). Es una MARCA más: queda
  /// como última marca, con Bien / Error / Ley / Deshacer, y se revisa como las demás. El motivo
  /// puede quedar sin especificar y completarse después ([setIncidentInfraction]).
  Incident logSanction(TeamSide team, SanctionKind kind, {required int t, InfractionRef? infraction}) {
    final category = categoryForSanction(kind, infraction);
    final defaults = quickTagDefaults(QuickPolarity.review);
    final incident = Incident(
      id: _ids.next(),
      assessmentId: assessmentId,
      seq: _incidents.length + 1,
      sessionMs: t,
      wallUtc: _clock.wallUtc(),
      matchTime: matchTimeAt(t),
      category: category,
      criterionCode: kCategoryToCriterion[category]!,
      polarity: QuickPolarity.review,
      verdict: defaults.verdict,
      impact: defaults.impact,
      impactConfirmed: defaults.impactConfirmed,
      status: IncidentStatus.quick,
      decisionTaken: Decision(outcomes: [outcomeFor(kind)], againstTeam: team),
      infraction: infraction,
    );
    _incidents.add(incident);
    _lastIncidentId = incident.id;
    _refineUntil = _clock.now() + 10000;
    _haptics.incidentLogged();
    _notify();
    _persist(() => _repo.insertIncident(incident));
    return incident;
  }

  /// Anula la marca de la última sanción activa (nunca se borra).
  void undoLastSanction() {
    final last = lastSanction;
    if (last == null) return;
    final idx = _incidents.indexWhere((i) => i.id == last.incidentId);
    final voided = _incidents[idx].copyWith(status: IncidentStatus.voided);
    _incidents[idx] = voided;
    if (_lastIncidentId == voided.id) _refineUntil = 0;
    _haptics.undone();
    _notify();
    _persist(() => _repo.updateIncident(voided));
  }

  void _replace(Incident updated) {
    final idx = _incidents.indexWhere((i) => i.id == updated.id);
    _incidents[idx] = updated;
  }

  // ───────────── Reloj ─────────────

  /// Aplica un evento de reloj. Devuelve el error de regla si la transición no es legal.
  ClockRuleException? applyClock(ClockEventBody body) {
    try {
      final at = _clock.sample();
      final next = appendClockEvent(_clockLog, body, at.sessionMs, category);
      final event = next.last;
      _clockLog = next;
      clockState = foldClock(_clockLog, category);
      final phase = phaseFor(clockState.status);
      _haptics.clockChanged();
      _notify();
      _persist(() => _repo.appendClockEvent(assessmentId, event, at, phase));
      return null;
    } on ClockRuleException catch (e) {
      _haptics.warning();
      return e;
    }
  }

  ClockRuleException? runPrimaryAction() => switch (primaryAction) {
        StartPeriodAction(:final period) => applyClock(PeriodStart(period)),
        StopTimeAction() => applyClock(const TimeOff()),
        ResumeTimeAction() => applyClock(const TimeOn()),
        GoToReviewAction() => null,
      };

  ClockRuleException? undoLastClockEvent() {
    final eff = effectiveEvents(_clockLog);
    if (eff.isEmpty) return const ClockRuleException(ClockError.nothingToVoid);
    return applyClock(VoidEvent(eff.last.seq));
  }

  // ───────────── Escritura ordenada ─────────────

  void _persist(Future<void> Function() op) {
    _pendingWrites.add(op);
    _drain();
  }

  Future<void> retryPendingWrites() => _drain();

  /// Espera a que la cola quede vacía (o falle). Se llama al pasar la app a segundo plano.
  Future<void> flush() async {
    await _drain();
    while (_draining) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    while (_pendingWrites.isNotEmpty) {
      try {
        await _pendingWrites.first();
        _pendingWrites.removeAt(0);
        if (saveFailed) {
          saveFailed = false;
          _notify();
        }
      } catch (_) {
        if (!saveFailed) _haptics.warning();
        saveFailed = true;
        _notify();
        break;
      }
    }
    _draining = false;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Alias para evitar el choque de nombres con LiveController.matchTimeAt.
MatchTimeStamp matchTimeAtState(ClockState s, int t, CategoryConfig cat) => matchTimeAt(s, t, cat);

String periodLabel(PeriodId p) => switch (p) {
      PeriodId.h1 => '1ª parte',
      PeriodId.h2 => '2ª parte',
      PeriodId.et1 => 'Prórroga 1',
      PeriodId.et2 => 'Prórroga 2',
      PeriodId.sd => 'Muerte súbita',
    };
