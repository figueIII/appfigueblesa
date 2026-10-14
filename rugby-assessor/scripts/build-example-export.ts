// Genera export/example-export.json con el motor real (sirve de fixture y de prueba del esquema).
import { createHash } from 'node:crypto';
import { writeFileSync } from 'node:fs';
import { DEFAULT_RUBRIC as R } from '../domain/rubric-default.ts';
import { categoryPreset } from '../domain/category-presets.ts';
import { aggregate, keyDecisionAccuracy, suggestCriterionScore } from '../domain/scoring.ts';
import { canonicalJson } from '../domain/usecases.ts';
import type { BandCode, CriterionScore, Incident } from '../domain/model.ts';

const INC_ID = '0192a1b0-0000-7000-8000-000000000012';
const incident: Incident = {
  id: INC_ID, assessmentId: '0192a1b0-0000-7000-8000-000000000001', seq: 12,
  capturedAt: { sessionMs: 3_900_000, wallUtc: '2026-10-17T16:05:14Z' },
  matchTime: { period: 'H2', phaseLabel: 'IN_PLAY', periodElapsedMs: 1_034_000, matchClockMs: 3_134_000, overtimeMs: 0, integrity: 'OK' },
  category: 'OTHER_LAW', criterionCode: 'C2_MATERIAL_EFFECT', polarity: 'NEGATIVE', gamePhase: 'RESTART', fieldZone: 'OWN_22_TO_HALF',
  decisionTaken: { outcomes: ['SCRUM'], againstTeam: 'HOME', description: 'Saque de centro que no recorre 10 m: scrum en el centro.' },
  decisionExpected: { outcomes: ['FREE_KICK', 'SCRUM'], againstTeam: 'HOME', lawRef: '12', description: 'El equipo no infractor elige: lanzar de nuevo, scrum o puntapié libre (opción no ofrecida).' },
  verdict: 'INCORRECT', impact: 'HIGH', impactConfirmed: true, notes: 'Error de reglamento teórico: no ofreció las opciones al capitán.',
  attachments: [], source: 'ONE_TAP', status: 'ENRICHED', updatedAt: '2026-10-17T19:40:00Z',
};

// Bandas elegidas por el evaluador (todo "Competente" salvo lo indicado).
const chosen: Partial<Record<string, BandCode>> = { C2_MATERIAL_EFFECT: 'N', C3_ADVANTAGE_CONSISTENCY: 'E' };
const criterionScores: CriterionScore[] = R.areas.flatMap((a) => a.criteria).map((c) => {
  const s = suggestCriterionScore(c.code, [incident], R);
  return {
    criterionCode: c.code, suggestedBand: s.suggestedBand, suggested: s.suggested,
    finalBand: chosen[c.code] ?? 'C', final: null, notObserved: false,
    justification: c.code === 'C2_MATERIAL_EFFECT'
      ? 'No ofreció las opciones reglamentarias tras el saque de centro corto (52:14).'
      : c.code === 'C3_ADVANTAGE_CONSISTENCY' ? 'Ventajas largas y bien cerradas, con lectura territorial.' : '',
    capBand: s.capBand, evidenceIncidentIds: s.evidenceIncidentIds,
  };
});
const agg = aggregate(R, criterionScores);

const report = {
  version: 1, status: 'FINALIZED', finalizedAt: '2026-10-18T09:12:00Z',
  criterionScores: criterionScores.map(({ final: _f, ...rest }) => rest),
  areaScores: agg.areaScores, band: agg.band, overallScore: agg.overallScore,
  keyDecisionAccuracy: keyDecisionAccuracy([incident]),
  summary: 'Partido bien gestionado en lo físico y en la ventaja; el conocimiento reglamentario en reinicios es la prioridad.',
  actualDifficulty: 'VERY_HIGH', levelRecommendation: 'SAME',
  strengths: [{ criterionCode: 'C3_ADVANTAGE_CONSISTENCY', text: 'Ventaja territorial bien leída y cerrada con claridad.', evidenceIncidentIds: [] }],
  developmentAreas: [{ criterionCode: 'C2_MATERIAL_EFFECT', text: 'Opciones del equipo no infractor en reinicios incorrectos.', evidenceIncidentIds: [INC_ID] }],
  actionPoints: [{ id: '0192a1b0-0000-7000-8000-0000000000a1', criterionCode: 'C2_MATERIAL_EFFECT', text: 'Repasar la ley 12 (saque de centro y reinicios) y sus opciones.', successIndicator: 'En la próxima evaluación, todas las infracciones en reinicios se resuelven con las opciones correctas.' }],
  previousActionPointReviews: [],
};
const { status: _omit, ...signed } = report;
const contentHash = createHash('sha256').update(canonicalJson(signed), 'utf8').digest('hex');
const category = categoryPreset('SM_DHCAT_1_2_3');

const doc = {
  format: 'rugby-referee-assessment', formatVersion: '2.2', exportedAt: '2026-10-18T09:13:05Z',
  generator: { app: 'RefAssess', appVersion: '1.2.0', rubricEngineVersion: R.version },
  match: {
    assessmentId: incident.assessmentId, competition: 'DHCAT', round: 'J5',
    category: { code: category.code, name: category.name, format: category.format, periodLengthMin: category.periodLengthMin, sinBinMin: category.sinBinMin, lawVariations: category.lawVariations },
    kickoff: { local: '2026-10-17T17:00', tz: 'Europe/Madrid' }, venue: 'Campo Municipal',
    home: { name: 'Club Local RC' }, away: { name: 'Visitante RT' }, finalScore: { home: 24, away: 19 },
    observationMode: 'LIVE', difficulty: 'HIGH',
    refereeName: 'Árbitro Ejemplo', assistants: { ar1: 'Asistente Uno', ar2: 'Asistente Dos' },
  },
  referee: { id: '0192a1b0-0000-7000-8000-0000000000f1', fullName: 'Árbitro Ejemplo' },
  assessor: { id: '0192a1b0-0000-7000-8000-0000000000e1', fullName: 'Evaluador Ejemplo' },
  rubric: {
    id: R.id, code: R.code, version: R.version,
    bands: R.bands.map((b) => ({ code: b.code, label: b.label, labelCa: b.labelCa })),
    areas: R.areas.map((a) => ({
      code: a.code, name: a.name, nameCa: a.nameCa, weight: a.weight,
      criteria: a.criteria.map((c) => ({ code: c.code, name: c.name, nameCa: c.nameCa, level: c.level, weight: c.weight })),
    })),
  },
  report,
  incidents: [{
    id: INC_ID, seq: 12, matchClock: '52:14', period: 'H2', overtime: false, timeIntegrity: 'OK',
    category: incident.category, criterionCode: incident.criterionCode, gamePhase: incident.gamePhase, fieldZone: incident.fieldZone,
    decisionTaken: incident.decisionTaken, decisionExpected: incident.decisionExpected,
    verdict: incident.verdict, impact: incident.impact, notes: incident.notes, attachments: [],
  }],
  integrity: { algorithm: 'SHA-256', canonicalization: 'sorted-keys-no-whitespace-v1', hashedPointer: '/report', contentHash },
};
writeFileSync(new URL('../export/example-export.json', import.meta.url), JSON.stringify(doc, null, 2) + '\n');
console.log('band', agg.band, '| areas', agg.areaScores.map((a) => `${a.areaCode}:${a.band}`).join(' '), '| C2 sugerida', criterionScores.find((c) => c.criterionCode === 'C2_MATERIAL_EFFECT')!.suggestedBand, '| hash', contentHash.slice(0, 16));
