// Estado de la revisión post-partido. A diferencia del directo, aquí cada guardado se ESPERA:
// se está sentado, y el evaluador debe saber que lo que ha redactado ya está en disco.

import 'package:flutter/foundation.dart';

import '../../data/live_session_repository.dart';
import '../../domain/model.dart';
import '../../domain/review.dart';

enum ReviewLoadState { loading, ready, failed }

enum ReviewFilter { pending, all }

class ReviewController extends ChangeNotifier {
  ReviewController({required this.assessmentId, required ReviewRepository repository}) : _repo = repository;

  final String assessmentId;
  final ReviewRepository _repo;

  ReviewLoadState loadState = ReviewLoadState.loading;
  ReviewFilter filter = ReviewFilter.pending;
  String homeTeam = '';
  String awayTeam = '';
  final Map<String, Incident> _byId = {};
  bool _disposed = false;

  Iterable<Incident> get _all => _byId.values;
  List<Incident> get queue => buildReviewQueue(_all);
  List<Incident> get allChronological => chronological(_all);
  List<Incident> get visible => filter == ReviewFilter.pending ? queue : allChronological;
  ReviewProgress get progress => reviewProgress(_all);
  Incident byId(String id) => _byId[id]!;

  Future<void> load() async {
    loadState = ReviewLoadState.loading;
    _notify();
    try {
      final snap = await _repo.loadReview(assessmentId);
      homeTeam = snap.homeTeam;
      awayTeam = snap.awayTeam;
      _byId
        ..clear()
        ..addEntries(snap.incidents.map((i) => MapEntry(i.id, i)));
      loadState = ReviewLoadState.ready;
    } catch (_) {
      loadState = ReviewLoadState.failed;
    }
    _notify();
  }

  void setFilter(ReviewFilter f) {
    if (f == filter) return;
    filter = f;
    _notify();
  }

  /// Guarda el borrador. Devuelve la incidencia guardada; lanza si falla (la UI lo muestra
  /// junto al botón y conserva el borrador para reintentar).
  Future<Incident> save(Incident draft) async {
    final toSave = applyReviewEdit(draft);
    await _repo.saveEnrichment(toSave);
    _byId[toSave.id] = toSave;
    _notify();
    return toSave;
  }

  Future<void> voidIncident(Incident incident, String reason) async {
    await _repo.voidIncident(incident, reason);
    _byId[incident.id] = incident.copyWith(status: IncidentStatus.voided);
    _notify();
  }

  /// Siguiente incidencia pendiente distinta de [currentId] (la cola ya está recalculada).
  Incident? nextPendingAfter(String currentId) {
    for (final i in queue) {
      if (i.id != currentId) return i;
    }
    return null;
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
