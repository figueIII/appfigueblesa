// Puerto de persistencia de la captura en directo. La implementación Drift (schema.sql v2,
// una transacción por tap, synchronous=FULL) implementará esta misma interfaz; la UI no cambia.

import '../core/platform_ports.dart';
import '../domain/clock.dart';
import '../domain/model.dart';

/// Estado de la evaluación que deriva del reloj (spec §4): READY → LIVE → POST_MATCH.
enum AssessmentPhase { ready, live, postMatch }

AssessmentPhase phaseFor(ClockStatus s) => switch (s) {
      ClockStatus.preMatch => AssessmentPhase.ready,
      ClockStatus.running || ClockStatus.stopped || ClockStatus.interval => AssessmentPhase.live,
      ClockStatus.fullTime || ClockStatus.abandoned => AssessmentPhase.postMatch,
    };

class LiveSessionSnapshot {
  const LiveSessionSnapshot({
    required this.assessmentId,
    required this.category,
    required this.homeTeam,
    required this.awayTeam,
    required this.clockLog,
    required this.incidents,
  });
  final String assessmentId;
  final CategoryConfig category;
  final String homeTeam;
  final String awayTeam;
  final List<ClockEvent> clockLog;
  final List<Incident> incidents;
}

abstract interface class LiveSessionRepository {
  Future<LiveSessionSnapshot> load(String assessmentId);
  /// Añade el evento (append-only) y actualiza el estado de la evaluación en UNA transacción.
  Future<void> appendClockEvent(String assessmentId, ClockEvent event, TimeSample at, AssessmentPhase phase);

  /// Una transacción por tap.
  Future<void> insertIncident(Incident incident);
  Future<void> updateIncident(Incident incident);
}

class ReviewSnapshot {
  const ReviewSnapshot({required this.homeTeam, required this.awayTeam, required this.incidents});
  final String homeTeam;
  final String awayTeam;
  final List<Incident> incidents;
}

/// Persistencia de la revisión post-partido (pantalla 2).
abstract interface class ReviewRepository {
  Future<ReviewSnapshot> loadReview(String assessmentId);

  /// Guarda todo el contenido editable de una incidencia en una transacción (el trigger
  /// incident_audit conserva la versión anterior).
  Future<void> saveEnrichment(Incident incident);

  /// Anulación lógica con motivo (nunca se borra).
  Future<void> voidIncident(Incident incident, String reason);
}

/// Implementación en memoria para la demo y los tests de widget.
class InMemoryLiveSessionRepository implements LiveSessionRepository, ReviewRepository {
  InMemoryLiveSessionRepository(this._seed);

  /// Estado inicial (p. ej. un partido ya empezado, para probar la recuperación).
  final LiveSessionSnapshot _seed;
  final List<ClockEvent> _clock = [];
  final Map<String, Incident> _incidents = {};

  /// Permite simular un fallo de escritura en los tests.
  bool failWrites = false;

  List<ClockEvent> get clockLog => [..._seed.clockLog, ..._clock];
  List<Incident> get incidents {
    final byId = {for (final i in _seed.incidents) i.id: i, ..._incidents};
    return byId.values.toList()..sort((a, b) => a.seq.compareTo(b.seq));
  }

  @override
  Future<LiveSessionSnapshot> load(String assessmentId) async => LiveSessionSnapshot(
        assessmentId: _seed.assessmentId,
        category: _seed.category,
        homeTeam: _seed.homeTeam,
        awayTeam: _seed.awayTeam,
        clockLog: clockLog,
        incidents: incidents,
      );

  void _guard() {
    if (failWrites) throw StateError('STORAGE_WRITE_FAILED');
  }

  @override
  Future<void> appendClockEvent(String assessmentId, ClockEvent event, TimeSample at, AssessmentPhase phase) async {
    _guard();
    _clock.add(event);
  }

  @override
  Future<void> insertIncident(Incident incident) async {
    _guard();
    _incidents[incident.id] = incident;
  }

  @override
  Future<void> updateIncident(Incident incident) async {
    _guard();
    _incidents[incident.id] = incident;
  }

  final Map<String, String> voidReasons = {};

  @override
  Future<ReviewSnapshot> loadReview(String assessmentId) async =>
      ReviewSnapshot(homeTeam: _seed.homeTeam, awayTeam: _seed.awayTeam, incidents: incidents);

  @override
  Future<void> saveEnrichment(Incident incident) async {
    _guard();
    _incidents[incident.id] = incident;
  }

  @override
  Future<void> voidIncident(Incident incident, String reason) async {
    _guard();
    _incidents[incident.id] = incident.copyWith(status: IncidentStatus.voided);
    voidReasons[incident.id] = reason;
  }
}
