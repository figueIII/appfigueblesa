// Motor de puntuación: nota sugerida por criterio a partir de incidencias, agregación ponderada
// por áreas y banda de rendimiento. Puro y determinista. Ver docs/…/ESPECIFICACION… §2.3.

import type {
  AreaScore, AssessedVerdict, AssessmentRubric, CriterionCode, CriterionScore,
  ImpactLevel, Incident, ScoringParams,
} from './model.ts';

const IMPACT_ORDER: ImpactLevel[] = ['LOW', 'MEDIUM', 'HIGH', 'MATCH_DEFINING'];
const ASSESSED: ReadonlySet<string> = new Set<AssessedVerdict>(['CORRECT', 'INCORRECT', 'MISSED', 'DEBATABLE']);
const ERROR: ReadonlySet<string> = new Set(['INCORRECT', 'MISSED']);

const atLeast = (i: ImpactLevel, min: ImpactLevel) => IMPACT_ORDER.indexOf(i) >= IMPACT_ORDER.indexOf(min);

/** Redondeo a 1 decimal, mitades hacia arriba, inmune a 6.45 → 6.4999… */
export const round1 = (x: number) => Math.round((x + Number.EPSILON) * 10) / 10;
/** Redondeo al paso de la escala (0,5 por defecto) para la nota sugerida. */
export const roundToStep = (x: number, step: number) => Math.round((x + Number.EPSILON) / step) * step;

export interface SuggestedScore {
  criterionCode: CriterionCode;
  suggested: number | null;     // ya redondeada al paso de la escala
  raw: number | null;           // sin redondear (para trazabilidad y tests)
  accuracy: number | null;      // p ∈ [0, 1]
  evidenceWeight: number;       // W = Σ peso de impacto
  capApplied: number | null;
  evidenceIncidentIds: string[];
}

/**
 * Nota sugerida de un criterio.
 *   p     = Σ wᵢ·créditoᵢ / Σ wᵢ                      (precisión ponderada por impacto)
 *   s_p   = atZero + (atOne − atZero)·p                (1 + 8p: 100 % ⇒ 9; el 10 es criterio del evaluador)
 *   n     = W / w_MEDIUM                               (evidencia en "incidencias medias equivalentes")
 *   s     = (k·baseline + n·s_p) / (k + n)             (contracción hacia el estándar con poca evidencia)
 *   s     = min(s, tope)                               (reglas de tope por errores graves)
 */
export function suggestCriterionScore(
  criterion: CriterionCode, incidents: readonly Incident[], rubric: AssessmentRubric,
): SuggestedScore {
  const P: ScoringParams = rubric.scoring;
  const relevant = incidents.filter((i) => i.status !== 'VOID' && i.criterionCode === criterion && ASSESSED.has(i.verdict));
  const ids = relevant.map((i) => i.id);
  if (relevant.length === 0) {
    return { criterionCode: criterion, suggested: null, raw: null, accuracy: null, evidenceWeight: 0, capApplied: null, evidenceIncidentIds: [] };
  }
  let W = 0, C = 0;
  for (const i of relevant) {
    const w = P.impactWeights[i.impact];
    W += w;
    C += w * P.verdictCredit[i.verdict as AssessedVerdict];
  }
  const p = C / W;
  const sp = P.accuracyToScore.atZero + (P.accuracyToScore.atOne - P.accuracyToScore.atZero) * p;
  const n = W / P.impactWeights.MEDIUM;
  let raw = (P.priorStrength * P.baseline + n * sp) / (P.priorStrength + n);

  let capApplied: number | null = null;
  for (const rule of P.capRules) {
    const count = relevant.filter((i) => ERROR.has(i.verdict) && atLeast(i.impact, rule.minImpact)).length;
    if (count >= rule.minCount && raw > rule.cap) {
      capApplied = capApplied === null ? rule.cap : Math.min(capApplied, rule.cap);
    }
  }
  if (capApplied !== null) raw = Math.min(raw, capApplied);

  const { min, max, step } = rubric.scale;
  let suggested = Math.min(max, Math.max(min, roundToStep(raw, step)));
  // El redondeo al paso nunca puede saltarse el tope (p. ej. tope 5,4 con paso 0,5 ⇒ 5,0).
  if (capApplied !== null && suggested > capApplied) suggested = Math.floor(capApplied / step) * step;
  return { criterionCode: criterion, suggested, raw, accuracy: p, evidenceWeight: W, capApplied, evidenceIncidentIds: ids };
}

export interface AggregateResult {
  areaScores: AreaScore[];
  overallScore: number | null;
  band: string | null;
}

/** Media ponderada; los criterios "no observados" salen y su peso se redistribuye. */
export function aggregate(rubric: AssessmentRubric, scores: readonly CriterionScore[]): AggregateResult {
  const byCode = new Map(scores.map((s) => [s.criterionCode, s]));
  const areaScores: AreaScore[] = rubric.areas.map((area) => {
    let wsum = 0, acc = 0;
    for (const c of area.criteria) {
      const s = byCode.get(c.code);
      if (!s || s.notObserved || s.final === null) continue;
      wsum += c.weight; acc += c.weight * s.final;
    }
    return { areaCode: area.code, score: wsum === 0 ? null : acc / wsum };
  });
  let wsum = 0, acc = 0;
  rubric.areas.forEach((area, idx) => {
    const sc = areaScores[idx].score;
    if (sc === null) return;
    wsum += area.weight; acc += area.weight * sc;
  });
  const overall = wsum === 0 ? null : round1(acc / wsum);
  const band = overall === null ? null : (rubric.bands.find((b) => overall >= b.minInclusive)?.code ?? null);
  return { areaScores: areaScores.map((a) => ({ ...a, score: a.score === null ? null : round1(a.score) })), overallScore: overall, band };
}

/** Precisión en decisiones clave (impacto ≥ HIGH), métrica habitual en paneles de élite. */
export function keyDecisionAccuracy(incidents: readonly Incident[]) {
  const key = incidents.filter((i) => i.status !== 'VOID' && atLeast(i.impact, 'HIGH') && ASSESSED.has(i.verdict));
  const correct = key.filter((i) => i.verdict === 'CORRECT').length;
  return { correct, total: key.length, ratio: key.length === 0 ? null : correct / key.length };
}
