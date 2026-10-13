// Puerto de persistencia de la captura en directo. La implementación Drift (schema.sql v2,
// una transacción por tap, synchronous=FULL) implementará esta misma interfaz; la UI no cambia.

import '../domain/clock.dart';
import '../domain/model.dart';

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
  Future<void> appendClockEvent(String assessmentId, ClockEvent event);
  Future<void> insertIncident(Incident incident);
  Future<void> updateIncident(Incident incident);
}

/// Implementación en memoria para la demo y los tests de widget.
class InMemoryLiveSessionRepository implements LiveSessionRepository {
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
  Future<void> appendClockEvent(String assessmentId, ClockEvent event) async {
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
}
