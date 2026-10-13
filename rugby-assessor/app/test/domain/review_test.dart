import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/domain/model.dart';
import 'package:ref_assess/domain/review.dart';

Incident inc(
  int seq, {
  Verdict verdict = Verdict.pending,
  ImpactLevel impact = ImpactLevel.medium,
  bool confirmed = false,
  String? notes,
  Decision? expected,
  IncidentStatus status = IncidentStatus.quick,
  int? t,
}) =>
    Incident(
      id: 'i$seq',
      assessmentId: 'a',
      seq: seq,
      sessionMs: t ?? seq * 1000,
      wallUtc: DateTime.utc(2026),
      matchTime: const MatchTimeStamp(period: PeriodId.h1, phase: MatchPhaseLabel.inPlay, periodElapsedMs: 0, matchClockMs: 0, overtimeMs: 0, integrity: TimeIntegrity.ok),
      category: IncidentCategory.ruck,
      criterionCode: 'A3_TACKLE_RUCK',
      polarity: QuickPolarity.review,
      verdict: verdict,
      impact: impact,
      impactConfirmed: confirmed,
      status: status,
      notes: notes,
      decisionExpected: expected,
    );

const penalty = Decision(outcomes: [DecisionOutcome.penalty], againstTeam: TeamSide.away);

void main() {
  test('reglas por incidencia = validateForFinalization (usecases.ts)', () {
    expect(reviewIssues(inc(1)), [ReviewIssue.verdictPending]);
    expect(reviewIssues(inc(1, verdict: Verdict.correct)), isEmpty, reason: 'un ✓ del directo ya está resuelto');
    expect(reviewIssues(inc(1, verdict: Verdict.incorrect)), [ReviewIssue.expectedDecisionMissing, ReviewIssue.impactNotConfirmed]);
    expect(reviewIssues(inc(1, verdict: Verdict.missed, confirmed: true, expected: penalty)), isEmpty);
    expect(reviewIssues(inc(1, verdict: Verdict.correct, impact: ImpactLevel.high)), [ReviewIssue.keyIncidentNotesMissing]);
    expect(reviewIssues(inc(1, verdict: Verdict.correct, impact: ImpactLevel.matchDefining, notes: '  ')), [ReviewIssue.keyIncidentNotesMissing]);
    expect(reviewIssues(inc(1, verdict: Verdict.debatable, impact: ImpactLevel.high, notes: 'ok')), isEmpty);
    expect(reviewIssues(inc(1, verdict: Verdict.incorrect, confirmed: true, expected: const Decision(outcomes: []))), [ReviewIssue.expectedDecisionMissing]);
    expect(reviewIssues(inc(1, status: IncidentStatus.voided)), isEmpty, reason: 'las anuladas no cuentan');
  });

  test('cola: sin veredicto primero, luego claves sin notas, luego errores incompletos; dentro, por impacto y minuto', () {
    final list = [
      inc(1, verdict: Verdict.incorrect, impact: ImpactLevel.matchDefining, confirmed: true, notes: 'x'), // nivel 3, decisivo
      inc(2), // nivel 1, medio, t=2000
      inc(3, impact: ImpactLevel.high, confirmed: true), // nivel 1, alto
      inc(4, verdict: Verdict.correct, impact: ImpactLevel.high), // nivel 2
      inc(5, impact: ImpactLevel.medium, t: 500), // nivel 1, medio, antes que el 2
      inc(6, verdict: Verdict.correct), // resuelta: fuera
      inc(7, status: IncidentStatus.voided), // anulada: fuera
      inc(8, verdict: Verdict.missed, impact: ImpactLevel.low, confirmed: true), // nivel 3, bajo
    ];
    expect(buildReviewQueue(list).map((i) => i.seq), [3, 5, 2, 4, 1, 8]);
  });

  test('progreso y fin de revisión', () {
    final list = [inc(1), inc(2, verdict: Verdict.correct), inc(3, status: IncidentStatus.voided)];
    final p = reviewProgress(list);
    expect((p.total, p.resolved, p.remaining, p.complete), (2, 1, 1, false));
    expect(reviewProgress([inc(1, verdict: Verdict.correct)]).complete, isTrue);
    expect(reviewProgress(const []).complete, isFalse, reason: 'sin marcas no hay nada que "completar"');
  });

  test('guardar desde la revisión alinea la polaridad y marca ENRICHED', () {
    expect(applyReviewEdit(inc(1, verdict: Verdict.missed)).polarity, QuickPolarity.negative);
    expect(applyReviewEdit(inc(1, verdict: Verdict.correct)).polarity, QuickPolarity.positive);
    expect(applyReviewEdit(inc(1, verdict: Verdict.debatable)).polarity, QuickPolarity.review);
    expect(applyReviewEdit(inc(1)).status, IncidentStatus.enriched);
  });

  test('copyWith distingue "no cambiar" de "borrar"', () {
    final a = inc(1, notes: 'nota', expected: penalty);
    expect(a.copyWith().notes, 'nota');
    expect(a.copyWith(notes: null).notes, isNull);
    expect(a.copyWith(decisionExpected: null).decisionExpected, isNull);
    expect(a.copyWith().sameContentAs(a), isTrue);
    expect(a.copyWith(notes: 'otra').sameContentAs(a), isFalse);
    expect(const Decision(outcomes: [DecisionOutcome.penalty], againstTeam: TeamSide.away) == penalty, isTrue);
  });
}
