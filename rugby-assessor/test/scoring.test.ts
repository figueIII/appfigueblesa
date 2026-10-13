import { test } from 'node:test';
import assert from 'node:assert/strict';
import { aggregate, keyDecisionAccuracy, suggestCriterionScore } from '../domain/scoring.ts';
import { DEFAULT_RUBRIC as R } from '../domain/rubric-default.ts';
import { quickTagDefaults, validateForFinalization, canonicalJson } from '../domain/usecases.ts';
import type { CriterionCode, CriterionScore, FinalReport, ImpactLevel, Incident, Verdict } from '../domain/model.ts';

let n = 0;
function inc(criterionCode: CriterionCode, verdict: Verdict, impact: ImpactLevel, extra: Partial<Incident> = {}): Incident {
  n += 1;
  return {
    id: `i${n}`, assessmentId: 'a1', seq: n, capturedAt: { sessionMs: n * 1000, wallUtc: '2026-10-17T15:00:00Z' },
    matchTime: { period: 'H1', phaseLabel: 'IN_PLAY', periodElapsedMs: n * 1000, matchClockMs: n * 1000, overtimeMs: 0, integrity: 'OK' },
    officialRole: 'REFEREE', category: 'RUCK', criterionCode, polarity: 'REVIEW', verdict, impact, impactConfirmed: true,
    attachments: [], source: 'ONE_TAP', status: 'ENRICHED', updatedAt: '2026-10-17T15:00:00Z', ...extra,
  };
}

test('ejemplo resuelto §2.3.3: placaje/ruck con un error HIGH', () => {
  const list = [
    inc('A3_TACKLE_RUCK', 'CORRECT', 'MEDIUM'), inc('A3_TACKLE_RUCK', 'CORRECT', 'LOW'),
    inc('A3_TACKLE_RUCK', 'INCORRECT', 'HIGH'), inc('A3_TACKLE_RUCK', 'DEBATABLE', 'MEDIUM'),
    inc('A3_TACKLE_RUCK', 'CORRECT', 'MEDIUM'), inc('A3_TACKLE_RUCK', 'PENDING', 'HIGH'),
    inc('A3_TACKLE_RUCK', 'INCORRECT', 'HIGH', { status: 'VOID' }),
  ];
  const s = suggestCriterionScore('A3_TACKLE_RUCK', list, R);
  assert.equal(s.evidenceWeight, 11);
  assert.ok(Math.abs(s.accuracy! - 6 / 11) < 1e-12);
  assert.ok(Math.abs(s.raw! - 50.5 / 8.5) < 1e-12);   // 5,941…
  assert.equal(s.suggested, 6.0);
  assert.equal(s.capApplied, null);
  assert.equal(s.evidenceIncidentIds.length, 5);       // ni PENDING ni VOID
});

test('un error MATCH_DEFINING topa la nota aunque el resto sea excelente', () => {
  const list = [...Array.from({ length: 10 }, () => inc('A1_SCRUM', 'CORRECT', 'HIGH')), inc('A1_SCRUM', 'MISSED', 'MATCH_DEFINING')];
  const s = suggestCriterionScore('A1_SCRUM', list, R);
  assert.ok(Math.abs(s.raw! - 5.5) < 1e-12);           // sin tope sería 205/27 = 7,59
  assert.equal(s.capApplied, 5.5);
  assert.equal(s.suggested, 5.5);
});

test('poca evidencia ⇒ la sugerida se queda cerca del estándar', () => {
  const s = suggestCriterionScore('B4_ADVANTAGE', [inc('B4_ADVANTAGE', 'CORRECT', 'LOW')], R);
  assert.ok(Math.abs(s.raw! - 25.5 / 3.5) < 1e-12);    // 7,29
  assert.equal(s.suggested, 7.5);
  assert.equal(suggestCriterionScore('D1_FITNESS', [], R).suggested, null);
});

function scores(map: Partial<Record<CriterionCode, number | 'NO'>>): CriterionScore[] {
  return R.areas.flatMap((a) => a.criteria).map((c) => {
    const v = map[c.code] ?? 7;
    return { criterionCode: c.code, suggested: null, final: v === 'NO' ? null : v, notObserved: v === 'NO', justification: 'ok', evidenceIncidentIds: [], capApplied: null };
  });
}

test('agregación ponderada y redistribución de "no observado"', () => {
  const r = aggregate(R, scores({ A1_SCRUM: 5.5, A3_TACKLE_RUCK: 6, B4_ADVANTAGE: 8, C2_FOUL_PLAY: 'NO', D2_POSITIONING: 8 }));
  // A = (25·5,5 + 20·7 + 35·6 + 20·7)/100 = 6,275 · B = (30·7+20·7+20·7+30·8)/100 = 7,3
  // C = 7 (C2 fuera) · D = (30·7 + 40·8 + 30·7)/100 = 7,4
  // Global = (40·6,275 + 25·7,3 + 20·7 + 15·7,4)/100 = 6,846 → 6,8
  assert.deepEqual(r.areaScores.map((a) => a.score), [6.3, 7.3, 7, 7.4]);
  assert.equal(r.overallScore, 6.8);
  assert.equal(r.band, 'STANDARD');
});

test('precisión en decisiones clave', () => {
  const k = keyDecisionAccuracy([inc('A1_SCRUM', 'CORRECT', 'HIGH'), inc('A1_SCRUM', 'INCORRECT', 'MATCH_DEFINING'), inc('A1_SCRUM', 'CORRECT', 'LOW')]);
  assert.deepEqual(k, { correct: 1, total: 2, ratio: 0.5 });
});

test('tap rápido: el positivo se da por correcto, el resto queda pendiente', () => {
  assert.deepEqual(quickTagDefaults('POSITIVE'), { verdict: 'CORRECT', impact: 'LOW', impactConfirmed: false });
  assert.deepEqual(quickTagDefaults('NEGATIVE'), { verdict: 'PENDING', impact: 'MEDIUM', impactConfirmed: false });
  assert.deepEqual(quickTagDefaults('REVIEW', 'HIGH'), { verdict: 'PENDING', impact: 'HIGH', impactConfirmed: true });
});

test('validación de cierre: bloquea pendientes, desvíos sin justificar y action points sin revisar', () => {
  const report: FinalReport = {
    assessmentId: 'a1', officialId: 'o1', role: 'REFEREE', rubric: { id: R.id, code: R.code, version: R.version },
    criterionScores: [{ criterionCode: 'A1_SCRUM', suggested: 5.5, final: 7.5, notObserved: false, justification: 'Visto en vídeo', evidenceIncidentIds: [], capApplied: 5.5 }],
    areaScores: [], overallScore: null, band: null, keyDecisionAccuracy: { correct: 0, total: 0, ratio: null },
    summary: 'Resumen', strengths: [], developmentAreas: [], actionPoints: [], previousActionPointReviews: [],
    status: 'DRAFT', version: 1,
  };
  const issues = validateForFinalization(report, [inc('A1_SCRUM', 'PENDING', 'MEDIUM'), inc('A1_SCRUM', 'MISSED', 'HIGH', { impactConfirmed: false })], ['ap-prev'], R.scoring);
  const codes = issues.filter((i) => i.severity === 'ERROR').map((i) => i.code).sort();
  assert.deepEqual(codes, [
    'ACTION_POINTS_COUNT_1_TO_3', 'CAP_OVERRIDE_JUSTIFICATION_TOO_SHORT', 'DEVELOPMENT_COUNT_1_TO_3',
    'INCIDENT_EXPECTED_DECISION_REQUIRED', 'INCIDENT_IMPACT_NOT_CONFIRMED', 'INCIDENT_VERDICT_PENDING',
    'KEY_INCIDENT_NOTES_REQUIRED', 'PREVIOUS_ACTION_POINT_NOT_REVIEWED', 'STRENGTHS_COUNT_1_TO_3',
  ]);
});

test('JSON canónico estable para el hash', () => {
  assert.equal(canonicalJson({ b: 1, a: [{ d: 2, c: undefined, e: null }] }), '{"a":[{"d":2,"e":null}],"b":1}');
});
