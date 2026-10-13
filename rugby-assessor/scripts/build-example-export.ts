// Genera export/example-export.json a partir del dominio (sirve de fixture y de prueba del esquema).
import { createHash } from 'node:crypto';
import { writeFileSync } from 'node:fs';
import { DEFAULT_RUBRIC as R } from '../domain/rubric-default.ts';
import { canonicalJson } from '../domain/usecases.ts';

const report = {
  version: 1, status: 'FINALIZED', finalizedAt: '2026-10-18T09:12:00Z',
  criterionScores: R.areas.flatMap((a) => a.criteria).map((c) => ({
    criterionCode: c.code,
    suggested: c.code === 'A3_TACKLE_RUCK' ? 6 : null,
    final: c.code === 'A3_TACKLE_RUCK' ? 6 : 7,
    notObserved: false,
    justification: c.code === 'A3_TACKLE_RUCK' ? 'Lectura correcta del placador; un error clave al no sancionar la entrada lateral en el 52.' : 'Nivel acorde a la categoría.',
    capApplied: null,
    evidenceIncidentIds: c.code === 'A3_TACKLE_RUCK' ? ['0192a1b0-0000-7000-8000-000000000012'] : [],
  })),
  areaScores: [{ areaCode: 'PHASES', score: 6.7 }, { areaCode: 'MANAGEMENT', score: 7 }, { areaCode: 'LAW_DISCIPLINE', score: 7 }, { areaCode: 'FITNESS_POSITIONING', score: 7 }],
  overallScore: 6.9, band: 'STANDARD',
  keyDecisionAccuracy: { correct: 0, total: 1, ratio: 0 },
  summary: 'Partido de dificultad alta bien gestionado en lo físico; el breakdown es la prioridad.',
  strengths: [{ criterionCode: 'B4_ADVANTAGE', text: 'Ventaja territorial bien leída y cerrada con claridad.', evidenceIncidentIds: [] }],
  developmentAreas: [{ criterionCode: 'A3_TACKLE_RUCK', text: 'Entradas laterales del tercera línea defensor sin sancionar.', evidenceIncidentIds: ['0192a1b0-0000-7000-8000-000000000012'] }],
  actionPoints: [{ id: '0192a1b0-0000-7000-8000-0000000000a1', criterionCode: 'A3_TACKLE_RUCK', text: 'Posicionarse en el lado de la llegada defensiva tras el placaje.', successIndicator: 'En la próxima evaluación, ≥ 80 % de rucks observados desde el lado defensor.' }],
  previousActionPointReviews: [],
};
const { status: _omit, ...signed } = report;
const contentHash = createHash('sha256').update(canonicalJson(signed), 'utf8').digest('hex');

const doc = {
  format: 'rugby-referee-assessment', formatVersion: '1.0', exportedAt: '2026-10-18T09:13:05Z',
  generator: { app: 'RefAssess', appVersion: '0.1.0', rubricEngineVersion: '1.0.0' },
  match: {
    assessmentId: '0192a1b0-0000-7000-8000-000000000001', competition: 'Liga Territorial Sénior', round: 'J5',
    category: { code: 'SENIOR', name: 'Sénior', format: 'XV', periodLengthMin: 40, lawVariations: [] },
    kickoff: { local: '2026-10-17T17:00', tz: 'Europe/Madrid' }, venue: 'Campo Municipal',
    home: { name: 'Club Local RC' }, away: { name: 'Visitante RT' }, finalScore: { home: 24, away: 19 },
    observationMode: 'LIVE', difficulty: 'HIGH',
    officials: [{ role: 'REFEREE', fullName: 'Árbitro Ejemplo' }, { role: 'AR1', fullName: 'Asistente Uno' }, { role: 'AR2', fullName: 'Asistente Dos' }],
  },
  official: { id: '0192a1b0-0000-7000-8000-0000000000f1', fullName: 'Árbitro Ejemplo', role: 'REFEREE' },
  assessor: { id: '0192a1b0-0000-7000-8000-0000000000e1', fullName: 'Evaluador Ejemplo' },
  rubric: { id: R.id, code: R.code, version: R.version, areas: R.areas.map((a) => ({ code: a.code, name: a.name, weight: a.weight, criteria: a.criteria.map((c) => ({ code: c.code, name: c.name, weight: c.weight })) })) },
  report,
  incidents: [{
    id: '0192a1b0-0000-7000-8000-000000000012', seq: 12, matchClock: '52:14', period: 'H2', overtime: false, timeIntegrity: 'OK',
    officialRole: 'REFEREE', category: 'RUCK', criterionCode: 'A3_TACKLE_RUCK', gamePhase: 'BREAKDOWN', fieldZone: 'OPP_22',
    decisionTaken: { outcomes: ['PLAY_ON'] },
    decisionExpected: { outcomes: ['PENALTY'], againstTeam: 'AWAY', lawRef: '15.10' },
    verdict: 'INCORRECT', impact: 'HIGH', notes: 'Entrada lateral del 7 visitante; recuperan y salen de 22.',
    attachments: [{ kind: 'VOICE_NOTE', fileName: 'inc-012.m4a', sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855' }],
  }],
  integrity: { algorithm: 'SHA-256', canonicalization: 'sorted-keys-no-whitespace-v1', hashedPointer: '/report', contentHash },
};
writeFileSync(new URL('../export/example-export.json', import.meta.url), JSON.stringify(doc, null, 2) + '\n');
console.log('hash', contentHash);
