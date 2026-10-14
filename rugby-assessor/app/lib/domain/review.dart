// Lógica pura de la revisión post-partido (spec §2.2 "Después del partido").
// Las reglas por incidencia son las de validateForFinalization (domain/usecases.ts):
//  · OBLIGATORIO (bloquea la cola y el cierre): solo el veredicto.
//  · RECOMENDADO (aviso, no bloquea, v1.1.2): notas en las clave, decisión esperada e impacto
//    confirmado en los errores.

import 'model.dart';

/// Lo que falta (obligatorio) o conviene completar (recomendado) en una incidencia.
enum ReviewIssue {
  /// INCIDENT_VERDICT_PENDING
  verdictPending,

  /// KEY_INCIDENT_NOTES_REQUIRED (impacto Alto o Decisivo sin notas)
  keyIncidentNotesMissing,

  /// INCIDENT_EXPECTED_DECISION_REQUIRED (Incorrecta / No pitada sin decisión esperada)
  expectedDecisionMissing,

  /// INCIDENT_IMPACT_NOT_CONFIRMED (Incorrecta / No pitada con el impacto por defecto del tap)
  impactNotConfirmed,
}

bool _isError(Verdict v) => v == Verdict.incorrect || v == Verdict.missed;
bool _isKey(ImpactLevel i) => i == ImpactLevel.high || i == ImpactLevel.matchDefining;

/// Lo OBLIGATORIO que falta: solo el veredicto (¿bien o mal?). Sin él, la marca no cuenta.
List<ReviewIssue> reviewIssues(Incident i) {
  if (i.isVoid) return const [];
  return [if (i.verdict == Verdict.pending) ReviewIssue.verdictPending];
}

/// Lo RECOMENDADO que falta: mejora el informe, pero no bloquea ni la cola ni el cierre.
List<ReviewIssue> reviewRecommendations(Incident i) {
  if (i.isVoid) return const [];
  return [
    if (_isKey(i.impact) && (i.notes ?? '').trim().isEmpty) ReviewIssue.keyIncidentNotesMissing,
    if (_isError(i.verdict) && (i.decisionExpected == null || i.decisionExpected!.isEmpty)) ReviewIssue.expectedDecisionMissing,
    if (_isError(i.verdict) && !i.impactConfirmed) ReviewIssue.impactNotConfirmed,
  ];
}

/// Cola de revisión: las incidencias sin veredicto, por IMPACTO de mayor a menor y, a igualdad,
/// por minuto de partido (cronológico).
List<Incident> buildReviewQueue(Iterable<Incident> incidents) {
  final pending = [
    for (final i in incidents)
      if (reviewIssues(i).isNotEmpty) i,
  ];
  pending.sort((a, b) {
    final imp = b.impact.index.compareTo(a.impact.index);
    if (imp != 0) return imp;
    final time = a.sessionMs.compareTo(b.sessionMs);
    return time != 0 ? time : a.seq.compareTo(b.seq);
  });
  return pending;
}

/// Todas las incidencias activas en orden cronológico (vista "Todas").
List<Incident> chronological(Iterable<Incident> incidents) =>
    [for (final i in incidents) if (!i.isVoid) i]..sort((a, b) => a.sessionMs.compareTo(b.sessionMs));

class ReviewProgress {
  const ReviewProgress({required this.total, required this.resolved});
  final int total;
  final int resolved;
  int get remaining => total - resolved;
  bool get complete => total > 0 && remaining == 0;
  double get fraction => total == 0 ? 1 : resolved / total;
}

ReviewProgress reviewProgress(Iterable<Incident> incidents) {
  final active = [for (final i in incidents) if (!i.isVoid) i];
  return ReviewProgress(total: active.length, resolved: active.where((i) => reviewIssues(i).isEmpty).length);
}

/// Al guardar desde la revisión: elegir un impacto lo confirma; la polaridad se alinea con el
/// veredicto para que la vista en directo y la revisión cuenten lo mismo.
Incident applyReviewEdit(Incident draft) {
  final polarity = switch (draft.verdict) {
    Verdict.correct => QuickPolarity.positive,
    Verdict.incorrect || Verdict.missed => QuickPolarity.negative,
    _ => draft.polarity,
  };
  return draft.copyWith(polarity: polarity, status: IncidentStatus.enriched);
}
