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

test('rúbrica v3 (CARC): 6 áreas, 25 competencias con nivel, pesos iguales y escala E/C/N/U', () => {
  assert.deepEqual(R.areas.map((a) => [a.code, a.criteria.length]), [
    ['POSITIONING', 6], ['COMMUNICATION', 3], ['CONTINUITY', 3], ['SET_PIECE', 4], ['DYNAMIC_PHASES', 6], ['DISCIPLINE', 3],
  ]);
  const all = R.areas.flatMap((a) => a.criteria);
  assert.equal(all.length, 25);
  assert.equal(new Set(all.map((c) => c.code)).size, 25);
  for (const a of R.areas) {
    assert.equal(a.weight, 1, a.code);
    assert.ok(a.nameCa, a.code);
    for (const c of a.criteria) {
      assert.equal(c.weight, 1, c.code);
      assert.ok(c.level && c.level >= 1 && c.level <= 3, c.code);
      assert.ok(c.nameCa && c.name, c.code);
    }
  }
  assert.deepEqual(R.areas.find((a) => a.code === 'DYNAMIC_PHASES')!.criteria.map((c) => c.level), [1, 1, 2, 2, 3, 3]);
  assert.deepEqual(R.bands.map((b) => b.code), ['E', 'C', 'N', 'U']);
  assert.deepEqual(R.bands.map((b) => b.labelCa), ['Excel·lent', 'Competent', 'No competent encara', 'Urgent revisar']);
  // Todas las categorías del tap rápido alimentan una competencia que existe.
  for (const code of Object.values(R.categoryToCriterion)) assert.ok(all.some((c) => c.code === code), code);
});

test('límites de banda: los empates exactos caen en la banda conservadora', () => {
  assert.equal(toBand(8.0, R), 'C');
  assert.equal(toBand(8.0 + 1e-12, R), 'C');     // ruido de coma flotante
  assert.equal(toBand(8.01, R), 'E');
  assert.equal(toBand(6.0, R), 'C');
  assert.equal(toBand(6.0 - 1e-12, R), 'C');
  assert.equal(toBand(5.99, R), 'N');
  assert.equal(toBand(4.0, R), 'N');
  assert.equal(toBand(3.99, R), 'U');
  assert.equal(toBand(1, R), 'U');
});

test('ejemplo resuelto §2.3.3: placaje con un error HIGH ⇒ sugerencia "No competente todavía"', () => {
  const list = [
    inc('E2_TACKLER_TACKLED', 'CORRECT', 'MEDIUM'), inc('E2_TACKLER_TACKLED', 'CORRECT', 'LOW'),
    inc('E2_TACKLER_TACKLED', 'INCORRECT', 'HIGH'), inc('E2_TACKLER_TACKLED', 'DEBATABLE', 'MEDIUM'),
    inc('E2_TACKLER_TACKLED', 'CORRECT', 'MEDIUM'), inc('E2_TACKLER_TACKLED', 'PENDING', 'HIGH'),
    inc('E2_TACKLER_TACKLED', 'INCORRECT', 'HIGH', { status: 'VOID' }),
  ];
  const s = suggestCriterionScore('E2_TACKLER_TACKLED', list, R);
  assert.equal(s.evidenceWeight, 11);
  assert.ok(Math.abs(s.accuracy! - 6 / 11) < 1e-12);
  assert.ok(Math.abs(s.raw! - 50.5 / 8.5) < 1e-12);   // 5,941…
  assert.equal(s.suggestedBand, 'N');
  assert.equal(s.capBand, null);
  assert.equal(s.evidenceIncidentIds.length, 5);       // ni PENDING ni VOID
});

test('tope R4: un error MATCH_DEFINING limita SOLO su competencia a "No competente todavía"', () => {
  const list = [...times(10, () => inc('D2_SCRUM_SEQUENCE_SAFETY', 'CORRECT', 'HIGH')), inc('D2_SCRUM_SEQUENCE_SAFETY', 'MISSED', 'MATCH_DEFINING'),
    ...times(6, () => inc('E3_GATES_ENTRIES', 'CORRECT', 'HIGH'))];
  const scrum = suggestCriterionScore('D2_SCRUM_SEQUENCE_SAFETY', list, R);
  assert.ok(Math.abs(scrum.raw! - 205 / 27) < 1e-12);  // sin tope: 7,59 ⇒ "Competente"
  assert.equal(scrum.capBand, 'N');
  assert.equal(scrum.suggested, 5);
  assert.equal(scrum.suggestedBand, 'N');
  const ruck = suggestCriterionScore('E3_GATES_ENTRIES', list, R);
  assert.equal(ruck.capBand, null);                     // el tope no contamina otras competencias
  assert.ok(Math.abs(ruck.suggested! - 129 / 15) < 1e-12); // 8,6
  assert.equal(ruck.suggestedBand, 'E');
});

test('dos errores HIGH en la misma competencia también la limitan a "No competente todavía"', () => {
  const s = suggestCriterionScore('C2_MATERIAL_EFFECT',
    [...times(8, () => inc('C2_MATERIAL_EFFECT', 'CORRECT', 'HIGH')), ...times(2, () => inc('C2_MATERIAL_EFFECT', 'INCORRECT', 'HIGH'))], R);
  assert.ok(s.raw! > 6);                                // 7,26 sin tope
  assert.equal(s.suggestedBand, 'N');
});

test('muchos errores ⇒ "Revisión urgente"; poca evidencia ⇒ "Competente"', () => {
  const bad = suggestCriterionScore('F1_DANGEROUS_PLAY', times(6, () => inc('F1_DANGEROUS_PLAY', 'INCORRECT', 'MEDIUM')), R);
  assert.ok(Math.abs(bad.raw! - 27 / 9) < 1e-12);      // (3·7 + 6·1)/(3 + 6) = 3
  assert.equal(bad.suggestedBand, 'U');
  const s = suggestCriterionScore('C3_ADVANTAGE_CONSISTENCY', [inc('C3_ADVANTAGE_CONSISTENCY', 'CORRECT', 'LOW')], R);
  assert.ok(Math.abs(s.raw! - 25.5 / 3.5) < 1e-12);    // 7,29
  assert.equal(s.suggestedBand, 'C');
  assert.equal(suggestCriterionScore('A5_REACHES_CONTACT', [], R).suggestedBand, null);
});

function scores(map: Partial<Record<CriterionCode, BandCode | 'NO' | 'NONE'>>): CriterionScore[] {
  return R.areas.flatMap((a) => a.criteria).map((c) => {
    const v = map[c.code] ?? 'C';
    return {
      criterionCode: c.code, suggestedBand: null, suggested: null, finalBand: v === 'NO' || v === 'NONE' ? null : v, final: null,
      notObserved: v === 'NO', justification: '', evidenceIncidentIds: [], capBand: null,
    };
  });
}

test('agregación E/C/N/U con pesos iguales; "no observado" y "sin valorar" no cuentan', () => {
  const r = aggregate(R, scores({
    A1_STATIC_START: 'E', A2_NO_INTERFERENCE: 'N',
    B1_PRIMARY_SIGNAL_WHISTLE: 'U', B2_SECONDARY_SIGNAL: 'NO',
    D1_ORDERED_SET_PIECE: 'E', D2_SCRUM_SEQUENCE_SAFETY: 'E', D3_DANGER_DETECTION: 'E', D4_FAIR_CONTEST: 'E',
    F1_DANGEROUS_PLAY: 'U', F2_FOUL_PLAY: 'U', F3_MATCH_CONTROL: 'N',
    E6_JACKLER: 'NONE',
  }));
  // A = (9 + 5 + 4·7)/6 = 7 · B = (3 + 7)/2 = 5 · C = 7 · D = 9 · E = 7 (E6 sin valorar) · F = 11/3
  assert.deepEqual(r.areaScores.map((a) => a.band), ['C', 'N', 'C', 'E', 'C', 'U']);
  assert.ok(Math.abs(r.areaScores[5].score! - 11 / 3) < 1e-12);
  assert.ok(Math.abs(r.overallScore! - (7 + 5 + 7 + 9 + 7 + 11 / 3) / 6) < 1e-12); // 6,44
  assert.equal(r.band, 'C');
  // Un área entera sin valorar sale de la media global.
  const only = aggregate(R, R.areas.flatMap((a) => a.criteria).map((c) => ({
    criterionCode: c.code, suggestedBand: null, suggested: null, finalBand: c.code.startsWith('F') ? 'U' : null, final: null,
    notObserved: false, justification: '', evidenceIncidentIds: [], capBand: null,
  }) as CriterionScore));
  assert.equal(only.overallScore, 3);
  assert.equal(only.band, 'U');
  assert.equal(only.areaScores[0].band, null);
});

test('precisión en decisiones clave', () => {
  const k = keyDecisionAccuracy([inc('D1_ORDERED_SET_PIECE', 'CORRECT', 'HIGH'), inc('D1_ORDERED_SET_PIECE', 'INCORRECT', 'MATCH_DEFINING'), inc('D1_ORDERED_SET_PIECE', 'CORRECT', 'LOW')]);
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
    summary: '', strengths: [], developmentAreas: [], actionPoints: [], previousActionPointReviews: [],
    status: 'DRAFT', version: 1,
  };
}
const cs = (o: Partial<CriterionScore>): CriterionScore => ({
  criterionCode: 'D2_SCRUM_SEQUENCE_SAFETY', suggestedBand: null, suggested: null, finalBand: 'C', final: null, notObserved: false,
  justification: '', evidenceIncidentIds: [], capBand: null, ...o,
});

test('cierre v3: nada es obligatorio; todo lo que falta son avisos', () => {
  const report = baseReport([cs({ suggestedBand: 'N', finalBand: 'C', capBand: 'N', justification: 'Visto en vídeo' }), cs({ finalBand: null })]);
  const issues = validateForFinalization(report,
    [inc('D2_SCRUM_SEQUENCE_SAFETY', 'PENDING', 'MEDIUM'), inc('D2_SCRUM_SEQUENCE_SAFETY', 'MISSED', 'HIGH', { impactConfirmed: false })], ['ap-prev'], R.scoring);
  assert.deepEqual(issues.filter((i) => i.severity === 'ERROR'), []);
  assert.deepEqual(issues.map((i) => i.code).sort(), [
    'CAP_OVERRIDE_JUSTIFICATION_TOO_SHORT', 'CRITERION_BAND_MISSING', 'INCIDENT_EXPECTED_DECISION_REQUIRED',
    'INCIDENT_IMPACT_NOT_CONFIRMED', 'INCIDENT_VERDICT_PENDING', 'KEY_INCIDENT_NOTES_REQUIRED', 'PREVIOUS_ACTION_POINT_NOT_REVIEWED',
  ]);
  // Sin resumen, sin fortalezas, sin áreas de mejora y sin recomendaciones: nada que avisar.
  assert.deepEqual(validateForFinalization(baseReport([cs({})]), [], [], R.scoring), []);
});

test('justificación: sin texto no pasa nada; solo se avisa si contradice la sugerencia con un texto corto', () => {
  const codesFor = (o: Partial<CriterionScore>) =>
    validateForFinalization(baseReport([cs(o)]), [], [], R.scoring).map((i) => i.code);
  assert.deepEqual(codesFor({ suggestedBand: 'C', finalBand: 'E', justification: 'corta' }), ['DEVIATION_JUSTIFICATION_TOO_SHORT']);
  assert.deepEqual(codesFor({ suggestedBand: 'C', finalBand: 'C', justification: '' }), []);
  assert.deepEqual(codesFor({ suggestedBand: 'C', finalBand: 'E', justification: 'x'.repeat(40) }), []);
  assert.deepEqual(codesFor({ finalBand: null, notObserved: true }), []);
});

test('JSON canónico estable para el hash', () => {
  assert.equal(canonicalJson({ b: 1, a: [{ d: 2, c: undefined, e: null }] }), '{"a":[{"d":2,"e":null}],"b":1}');
});
