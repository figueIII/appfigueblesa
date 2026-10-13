// Motor de puntuación. Calcula con números en una escala INTERNA (1–10) y expone BANDAS
// cualitativas (BELOW / AT / ABOVE), que son lo único visible para el evaluador y en el informe.
// Puro y determinista. Ver docs/…/ESPECIFICACION… §2.3.

import type {
  AreaScore, AssessedVerdict, AssessmentRubric, BandCode, CriterionCode, CriterionScore,
  ImpactLevel, Incident, ScoringParams,
} from './model.ts';

const IMPACT_ORDER: ImpactLevel[] = ['LOW', 'MEDIUM', 'HIGH', 'MATCH_DEFINING'];
const BAND_RANK: Record<BandCode, number> = { BELOW: 0, AT: 1, ABOVE: 2 };
const ASSESSED: ReadonlySet<string> = new Set<AssessedVerdict>(['CORRECT', 'INCORRECT', 'MISSED', 'DEBATABLE']);
const ERROR: ReadonlySet<string> = new Set(['INCORRECT', 'MISSED']);
/** Tolerancia para que el ruido de coma flotante no cruce un límite de banda (8,000000001). */
const EPS = 1e-9;

const atLeast = (i: ImpactLevel, min: ImpactLevel) => IMPACT_ORDER.indexOf(i) >= IMPACT_ORDER.indexOf(min);

export const bandRank = (b: BandCode) => BAND_RANK[b];
export const minBand = (a: BandCode, b: BandCode): BandCode => (BAND_RANK[a] <= BAND_RANK[b] ? a : b);

/** Valor interno → banda. Los empates exactos en un límite estricto caen en la banda central. */
export function toBand(value: number, rubric: AssessmentRubric): BandCode {
  for (const b of rubric.bands) {
    if (b.lowerInclusive ? value >= b.lower - EPS : value > b.lower + EPS) return b.code;
  }
  return rubric.bands[rubric.bands.length - 1].code;
}

export function bandRepresentative(code: BandCode, rubric: AssessmentRubric): number {
  const b = rubric.bands.find((x) => x.code === code);
  if (!b) throw new Error(`UNKNOWN_BAND: ${code}`);
  return b.representative;
}

export interface SuggestedScore {
  criterionCode: CriterionCode;
  suggestedBand: BandCode | null;  // visible
  suggested: number | null;        // interno, ya con el tope aplicado
  raw: number | null;              // interno, antes del tope (trazabilidad y tests)
  accuracy: number | null;         // p ∈ [0, 1]
  evidenceWeight: number;          // W = Σ peso de impacto
  capBand: BandCode | null;
  evidenceIncidentIds: string[];
}

/**
 * Sugerencia de un criterio (escala interna):
 *   p     = Σ wᵢ·créditoᵢ / Σ wᵢ                      (precisión ponderada por impacto)
 *   s_p   = atZero + (atOne − atZero)·p                (1 + 8p: 100 % ⇒ 9, representativo de ABOVE)
 *   n     = W / w_MEDIUM                               (evidencia en "incidencias medias equivalentes")
 *   s     = (k·baseline + n·s_p) / (k + n)             (contracción hacia "En el nivel" con poca evidencia)
 * Tope: si se cumple una CapRule, la sugerencia de ESTE criterio no supera su banda tope
 * (s = min(s, representativo de la banda tope)). No se propaga a otros criterios ni a la global.
 */
export function suggestCriterionScore(
  criterion: CriterionCode, incidents: readonly Incident[], rubric: AssessmentRubric,
): SuggestedScore {
  const P: ScoringParams = rubric.scoring;
  const relevant = incidents.filter((i) => i.status !== 'VOID' && i.criterionCode === criterion && ASSESSED.has(i.verdict));
  if (relevant.length === 0) {
    return { criterionCode: criterion, suggestedBand: null, suggested: null, raw: null, accuracy: null, evidenceWeight: 0, capBand: null, evidenceIncidentIds: [] };
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
  const raw = (P.priorStrength * P.baseline + n * sp) / (P.priorStrength + n);

  let capBand: BandCode | null = null;
  for (const rule of P.capRules) {
    const count = relevant.filter((i) => ERROR.has(i.verdict) && atLeast(i.impact, rule.minImpact)).length;
    if (count >= rule.minCount) capBand = capBand === null ? rule.capBand : minBand(capBand, rule.capBand);
  }
  const { min, max } = rubric.scale;
  let suggested = Math.min(max, Math.max(min, raw));
  if (capBand !== null) suggested = Math.min(suggested, bandRepresentative(capBand, rubric));
  let suggestedBand = toBand(suggested, rubric);
  if (capBand !== null) suggestedBand = minBand(suggestedBand, capBand);
  return {
    criterionCode: criterion, suggestedBand, suggested, raw, accuracy: p, evidenceWeight: W, capBand,
    evidenceIncidentIds: relevant.map((i) => i.id),
  };
}

export interface AggregateResult {
  areaScores: AreaScore[];
  overallScore: number | null;  // interno, sin redondear
  band: BandCode | null;        // visible
}

/**
 * Agregación: cada banda final del evaluador vale su representativo (5 / 7 / 9); media
 * ponderada por criterios dentro del área y por áreas en la global. Los "no observados"
 * salen y su peso se redistribuye. La banda se obtiene del valor sin redondear.
 */
export function aggregate(rubric: AssessmentRubric, scores: readonly CriterionScore[]): AggregateResult {
  const byCode = new Map(scores.map((s) => [s.criterionCode, s]));
  const valueOf = (s: CriterionScore | undefined) =>
    !s || s.notObserved || s.finalBand === null ? null : bandRepresentative(s.finalBand, rubric);

  const areaScores: AreaScore[] = rubric.areas.map((area) => {
    let wsum = 0, acc = 0;
    for (const c of area.criteria) {
      const v = valueOf(byCode.get(c.code));
      if (v === null) continue;
      wsum += c.weight; acc += c.weight * v;
    }
    const score = wsum === 0 ? null : acc / wsum;
    return { areaCode: area.code, score, band: score === null ? null : toBand(score, rubric) };
  });
  let wsum = 0, acc = 0;
  rubric.areas.forEach((area, idx) => {
    const sc = areaScores[idx].score;
    if (sc === null) return;
    wsum += area.weight; acc += area.weight * sc;
  });
  const overall = wsum === 0 ? null : acc / wsum;
  return { areaScores, overallScore: overall, band: overall === null ? null : toBand(overall, rubric) };
}

/** Precisión en decisiones clave (impacto ≥ HIGH). Se muestra como "n de m", no como nota. */
export function keyDecisionAccuracy(incidents: readonly Incident[]) {
  const key = incidents.filter((i) => i.status !== 'VOID' && atLeast(i.impact, 'HIGH') && ASSESSED.has(i.verdict));
  const correct = key.filter((i) => i.verdict === 'CORRECT').length;
  return { correct, total: key.length, ratio: key.length === 0 ? null : correct / key.length };
}
