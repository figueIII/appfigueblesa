import { test } from 'node:test';
import assert from 'node:assert/strict';
import { aggregate, keyDecisionAccuracy, suggestCriterionScore, toBand } from '../domain/scoring.ts';
import { DEFAULT_RUBRIC as R } from '../domain/rubric-default.ts';
import { quickTagDefaults, validateForFinalization, canonicalJson } from '../domain/usecases.ts';
import type { BandCode, CriterionCode, CriterionScore, FinalReport, ImpactLevel, Incident, Verdict } from '../domain/model.ts';

let n = 0;
function inc(criterionCode: CriterionCode, verdict: Verdict, impact: ImpactLevel, extra: Partial<Incident> = {}): Incident {
  n += 1;
  return {
    id: `i${n}`, assessmentId: 'a1', seq: n, capturedAt: { sessionMs: n * 1000, wallUtc: '2026-10-17T15:00:00Z' },
    matchTime: { period: 'H1', phaseLabel: 'IN_PLAY', periodElapsedMs: n * 1000, matchClockMs: n * 1000, overtimeMs: 0, integrity: 'OK' },
    category: 'RUCK', criterionCode, polarity: 'REVIEW', verdict, impact, impactConfirmed: true,
    attachments: [], source: 'ONE_TAP', status: 'ENRICHED', updatedAt: '2026-10-17T15:00:00Z', ...extra,
  };
}
const times = (k: number, f: () => Incident) => Array.from({ length: k }, f);

test('rúbrica v2: pesos de áreas y criterios (R1)', () => {
  const w = Object.fromEntries(R.areas.map((a) => [a.code, a.weight]));
  assert.deepEqual(w, { PHASES: 35, MANAGEMENT: 20, LAW_DISCIPLINE: 30, FITNESS_POSITIONING: 15 });
  const c = R.areas.find((a) => a.code === 'LAW_DISCIPLINE')!.criteria.map((x) => [x.code, x.weight]);
  assert.deepEqual(c, [['C1_LAW_ACCURACY', 50], ['C2_FOUL_PLAY', 30], ['C3_SANCTION_CONSISTENCY', 20]]);
  assert.equal(R.areas.reduce((s, a) => s + a.weight, 0), 100);
  for (const a of R.areas) assert.equal(a.criteria.reduce((s, x) => s + x.weight, 0), 100, a.code);
  assert.deepEqual(R.bands.map((b) => b.code), ['ABOVE', 'AT', 'BELOW']);
});

test('límites de banda: los empates exactos caen en "En el nivel"', () => {
  assert.equal(toBand(8.0, R), 'AT');
  assert.equal(toBand(8.0 + 1e-12, R), 'AT');     // ruido de coma flotante
  assert.equal(toBand(8.01, R), 'ABOVE');
  assert.equal(toBand(6.0, R), 'AT');
  assert.equal(toBand(6.0 - 1e-12, R), 'AT');
  assert.equal(toBand(5.99, R), 'BELOW');
  assert.equal(toBand(1, R), 'BELOW');
});

test('ejemplo resuelto §2.3.3: placaje/ruck con un error HIGH ⇒ sugerencia "Por debajo"', () => {
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
  assert.equal(s.suggestedBand, 'BELOW');
  assert.equal(s.capBand, null);
  assert.equal(s.evidenceIncidentIds.length, 5);       // ni PENDING ni VOID
});

test('tope R4: un error MATCH_DEFINING limita SOLO su criterio a "Por debajo"', () => {
  const list = [...times(10, () => inc('A1_SCRUM', 'CORRECT', 'HIGH')), inc('A1_SCRUM', 'MISSED', 'MATCH_DEFINING'),
    ...times(6, () => inc('A3_TACKLE_RUCK', 'CORRECT', 'HIGH'))];
  const scrum = suggestCriterionScore('A1_SCRUM', list, R);
  assert.ok(Math.abs(scrum.raw! - 205 / 27) < 1e-12);  // sin tope: 7,59 ⇒ "En el nivel"
  assert.equal(scrum.capBand, 'BELOW');
  assert.equal(scrum.suggested, 5);
  assert.equal(scrum.suggestedBand, 'BELOW');
  const ruck = suggestCriterionScore('A3_TACKLE_RUCK', list, R);
  assert.equal(ruck.capBand, null);                     // el tope no contamina otros criterios
  assert.ok(Math.abs(ruck.suggested! - 129 / 15) < 1e-12); // 8,6
  assert.equal(ruck.suggestedBand, 'ABOVE');
});

test('dos errores HIGH en el mismo criterio también lo limitan a "Por debajo"', () => {
  const s = suggestCriterionScore('C1_LAW_ACCURACY',
    [...times(8, () => inc('C1_LAW_ACCURACY', 'CORRECT', 'HIGH')), ...times(2, () => inc('C1_LAW_ACCURACY', 'INCORRECT', 'HIGH'))], R);
  assert.ok(s.raw! > 6);                                // 7,26 sin tope
  assert.equal(s.suggestedBand, 'BELOW');
});

test('poca evidencia ⇒ la sugerencia se queda "En el nivel"', () => {
  const s = suggestCriterionScore('B4_ADVANTAGE', [inc('B4_ADVANTAGE', 'CORRECT', 'LOW')], R);
  assert.ok(Math.abs(s.raw! - 25.5 / 3.5) < 1e-12);    // 7,29
  assert.equal(s.suggestedBand, 'AT');
  assert.equal(suggestCriterionScore('D1_FITNESS', [], R).suggestedBand, null);
});

function scores(map: Partial<Record<CriterionCode, BandCode | 'NO'>>): CriterionScore[] {
  return R.areas.flatMap((a) => a.criteria).map((c) => {
    const v = map[c.code] ?? 'AT';
    return {
      criterionCode: c.code, suggestedBand: null, suggested: null, finalBand: v === 'NO' ? null : v, final: null,
      notObserved: v === 'NO', justification: 'ok', evidenceIncidentIds: [], capBand: null,
    };
  });
}

test('agregación por bandas con los pesos v2 y redistribución de "no observado"', () => {
  const r = aggregate(R, scores({ A1_SCRUM: 'BELOW', B4_ADVANTAGE: 'ABOVE', C1_LAW_ACCURACY: 'BELOW', C2_FOUL_PLAY: 'NO', D2_POSITIONING: 'ABOVE' }));
  // A = (25·5 + 75·7)/100 = 6,5 · B = (70·7 + 30·9)/100 = 7,6
  // C = (50·5 + 20·7)/70 = 5,571 (C2 fuera) · D = (60·7 + 40·9)/100 = 7,8
  // Global = (35·6,5 + 20·7,6 + 30·5,571 + 15·7,8)/100 = 6,636
  assert.deepEqual(r.areaScores.map((a) => a.band), ['AT', 'AT', 'BELOW', 'AT']);
  assert.ok(Math.abs(r.areaScores[2].score! - 39 / 7) < 1e-12);
  assert.ok(Math.abs(r.overallScore! - (35 * 6.5 + 20 * 7.6 + 30 * 39 / 7 + 15 * 7.8) / 100) < 1e-12);
  assert.equal(r.band, 'AT');
});

test('el reglamento pesa: C1 y C3 por debajo hunden el área C y la global', () => {
  // C = (50·5 + 30·7 + 20·5)/100 = 5,6 ⇒ BELOW. Global = 0,30·5,6 + 0,70·7 = 6,58 ⇒ AT (justo).
  const r1 = aggregate(R, scores({ C1_LAW_ACCURACY: 'BELOW', C3_SANCTION_CONSISTENCY: 'BELOW' }));
  assert.equal(r1.areaScores[2].band, 'BELOW');
  assert.equal(r1.band, 'AT');
  // Para caer "Por debajo" en global hace falta más: scrum, touch y ruck (A = 5,4) y ventaja (B = 6,4).
  // Global = 0,35·5,4 + 0,20·6,4 + 0,30·5,6 + 0,15·7 = 5,90 ⇒ BELOW.
  const r2 = aggregate(R, scores({
    C1_LAW_ACCURACY: 'BELOW', C3_SANCTION_CONSISTENCY: 'BELOW',
    A1_SCRUM: 'BELOW', A2_LINEOUT_MAUL: 'BELOW', A3_TACKLE_RUCK: 'BELOW', B4_ADVANTAGE: 'BELOW',
  }));
  assert.ok(Math.abs(r2.overallScore! - 5.9) < 1e-12);
  assert.equal(r2.band, 'BELOW');
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

function baseReport(criterionScores: CriterionScore[]): FinalReport {
  return {
    assessmentId: 'a1', refereeId: 'o1', rubric: { id: R.id, code: R.code, version: R.version },
    criterionScores, areaScores: [], band: null, overallScore: null, keyDecisionAccuracy: { correct: 0, total: 0, ratio: null },
    summary: 'Resumen', strengths: [], developmentAreas: [], actionPoints: [], previousActionPointReviews: [],
    status: 'DRAFT', version: 1,
  };
}
const cs = (o: Partial<CriterionScore>): CriterionScore => ({
  criterionCode: 'A1_SCRUM', suggestedBand: null, suggested: null, finalBand: 'AT', final: null, notObserved: false,
  justification: 'ok', evidenceIncidentIds: [], capBand: null, ...o,
});

test('validación de cierre: bloquea pendientes, superar el tope sin justificar y action points sin revisar', () => {
  const report = baseReport([cs({ suggestedBand: 'BELOW', finalBand: 'AT', capBand: 'BELOW', justification: 'Visto en vídeo' })]);
  const issues = validateForFinalization(report, [inc('A1_SCRUM', 'PENDING', 'MEDIUM'), inc('A1_SCRUM', 'MISSED', 'HIGH', { impactConfirmed: false })], ['ap-prev'], R.scoring);
  const codes = issues.filter((i) => i.severity === 'ERROR').map((i) => i.code).sort();
  assert.deepEqual(codes, [
    'ACTION_POINTS_COUNT_1_TO_3', 'CAP_OVERRIDE_JUSTIFICATION_TOO_SHORT', 'DEVELOPMENT_COUNT_1_TO_3',
    'INCIDENT_EXPECTED_DECISION_REQUIRED', 'INCIDENT_IMPACT_NOT_CONFIRMED', 'INCIDENT_VERDICT_PENDING',
    'KEY_INCIDENT_NOTES_REQUIRED', 'PREVIOUS_ACTION_POINT_NOT_REVIEWED', 'STRENGTHS_COUNT_1_TO_3',
  ]);
});

test('validación por bandas: elegir otra banda que la sugerida exige justificación larga', () => {
  const codesFor = (o: Partial<CriterionScore>) =>
    validateForFinalization(baseReport([cs(o)]), [], [], R.scoring).map((i) => i.code)
      .filter((c) => c.includes('JUSTIFICATION') || c.includes('BAND'));
  assert.deepEqual(codesFor({ suggestedBand: 'AT', finalBand: 'ABOVE', justification: 'corta' }), ['DEVIATION_JUSTIFICATION_TOO_SHORT']);
  assert.deepEqual(codesFor({ suggestedBand: 'AT', finalBand: 'AT', justification: 'corta' }), []);
  assert.deepEqual(codesFor({ suggestedBand: 'AT', finalBand: 'ABOVE', justification: 'x'.repeat(40) }), []);
  assert.deepEqual(codesFor({ finalBand: null }), ['CRITERION_BAND_MISSING']);
  assert.deepEqual(codesFor({ finalBand: null, notObserved: true }), []);
});

test('JSON canónico estable para el hash', () => {
  assert.equal(canonicalJson({ b: 1, a: [{ d: 2, c: undefined, e: null }] }), '{"a":[{"d":2,"e":null}],"b":1}');
});
