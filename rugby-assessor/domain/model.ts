// Modelo de dominio — Evaluador arbitral de rugby (contratos).
// Solo tipos: este archivo no contiene lógica. Ver docs/ESPECIFICACION_EVALUADOR_ARBITRAL.md §1.

// ───────────────────────── Tipos base ─────────────────────────

/** UUIDv7 generado en el cliente (ordenable por tiempo, sin colisiones offline). */
export type Id = string;
/** Instante ISO‑8601 en UTC, p. ej. "2026-10-17T15:02:11.348Z". */
export type IsoUtc = string;
/** Fecha y hora local con zona IANA, p. ej. { local: "2026-10-17T17:00", tz: "Europe/Madrid" }. */
export interface LocalDateTime { local: string; tz: string }
/** Milisegundos en el eje monotónico de la sesión (ver clock.ts). Nunca hora de pared. */
export type SessionMs = number;

export type TeamSide = 'HOME' | 'AWAY';
export type GameFormat = 'XV' | 'SEVENS' | 'TENS';
export type PeriodId = 'H1' | 'H2' | 'ET1' | 'ET2' | 'SD';

// ───────────────────────── Catálogos ─────────────────────────

/** Configuración de categoría. Se copia (snapshot) dentro de cada partido: si la federación
 *  cambia la duración de M16 la temporada que viene, los informes antiguos no se alteran.
 *  Los valores oficiales están en category-presets.ts. */
export interface CategoryConfig {
  code: string;                 // "SM_DHCAT_1_2_3", "M16", "SEVENS"…
  name: string;
  competitions: string[];       // competiciones que cubre el preset (informativo, para el selector)
  format: GameFormat;
  periodLengthMin: number;      // duración de cada parte
  halfTimeMin?: number;         // no fijado por los presets; dato opcional
  extraTime: { periodLengthMin: number; suddenDeath: boolean } | null; // null = no hay prórroga
  sinBinMin: number;            // duración de la exclusión temporal
  lawVariations: string[];      // códigos libres: "RED_20MIN_TRIAL"…
}

export interface Official {
  id: Id;
  fullName: string;
  federationLicence?: string;
  grade?: string;               // panel/nivel en la federación
  homeSociety?: string;         // comité o delegación arbitral
}

export interface AssessorProfile {
  id: Id;
  fullName: string;
  federationLicence?: string;
  email?: string;
}

export interface TeamRef { name: string; clubCode?: string }

// ───────────────────────── 1. MatchMetadata ─────────────────────────

export type ObservationMode = 'LIVE' | 'VIDEO' | 'LIVE_AND_VIDEO';
export type MatchDifficulty = 'LOW' | 'MEDIUM' | 'HIGH' | 'VERY_HIGH';

export interface MatchMetadata {
  competition: string;
  round?: string;
  category: CategoryConfig;           // snapshot, no referencia
  kickoff: LocalDateTime;
  venue: string;
  home: TeamRef;
  away: TeamRef;
  /** Único oficial evaluado. La app evalúa EXCLUSIVAMENTE al árbitro principal (decisión R5). */
  refereeId: Id;
  /** Asistentes: solo nombre, como dato descriptivo del partido. No se evalúan. */
  assistants?: { ar1?: string; ar2?: string };
  assessorId: Id;
  observationMode: ObservationMode;
  difficulty?: MatchDifficulty;       // dificultad ESTIMADA. Solo descriptiva: nunca modifica la puntuación (R3)
  conditions?: { weather?: string; pitch?: string };
  finalScore?: { home: number; away: number };
}

// ───────────────────────── 2. AssessmentRubric ─────────────────────────

/** Áreas de competencias del CARC (v3). */
export type AreaCode = 'POSITIONING' | 'COMMUNICATION' | 'CONTINUITY' | 'SET_PIECE' | 'DYNAMIC_PHASES' | 'DISCIPLINE';

/** Competencias del CARC. La cifra es el orden dentro del área; el nivel (N1–N3) va aparte. */
export type CriterionCode =
  // A · Colocación
  | 'A1_STATIC_START' | 'A2_NO_INTERFERENCE' | 'A3_SEES_PLAY' | 'A4_OPEN_PLAY_LINES' | 'A5_REACHES_CONTACT'
  | 'A6_COMMUNICATES_FROM_POSITION'
  // B · Comunicación
  | 'B1_PRIMARY_SIGNAL_WHISTLE' | 'B2_SECONDARY_SIGNAL' | 'B3_PLAYER_COMMUNICATION'
  // C · Continuidad
  | 'C1_ADVANTAGE_SIGNAL' | 'C2_MATERIAL_EFFECT' | 'C3_ADVANTAGE_CONSISTENCY'
  // D · Fases estáticas
  | 'D1_ORDERED_SET_PIECE' | 'D2_SCRUM_SEQUENCE_SAFETY' | 'D3_DANGER_DETECTION' | 'D4_FAIR_CONTEST'
  // E · Fases dinámicas
  | 'E1_PHASE_IDENTIFICATION' | 'E2_TACKLER_TACKLED' | 'E3_GATES_ENTRIES' | 'E4_OFFSIDE_LINES'
  | 'E5_CONTEST_ON_FEET' | 'E6_JACKLER'
  // F · Disciplina
  | 'F1_DANGEROUS_PLAY' | 'F2_FOUL_PLAY' | 'F3_MATCH_CONTROL';

/** Etiquetas de registro rápido (un tap). Cada una alimenta exactamente un criterio. */
export type IncidentCategory =
  | 'SCRUM' | 'LINEOUT' | 'MAUL' | 'TACKLE' | 'RUCK'
  | 'OFFSIDE' | 'ADVANTAGE' | 'COMMUNICATION' | 'CAPTAIN_MGMT'
  | 'TRY_GROUNDING' | 'KNOCK_ON_FORWARD_PASS' | 'OTHER_LAW'
  | 'FOUL_PLAY' | 'CARD' | 'TMO_PROCESS'
  | 'POSITIONING' | 'FITNESS' | 'RUNNING_LINE';

/** Escala numérica INTERNA del motor. Nunca se muestra al evaluador ni en el informe. */
export interface ScoreScale { min: number; max: number }   // 1–10

/** Escala de valoración del CARC: la única cara visible de la evaluación (decisión R2).
 *  E – Excelente · C – Competente · N – No competente todavía · U – Revisión urgente.
 *  (Los informes cerrados con la rúbrica v2 guardan BELOW / AT / ABOVE: se leen como N / C / E.) */
export type BandCode = 'E' | 'C' | 'N' | 'U';

export interface PerformanceBand {
  code: BandCode;
  label: string;            // "Excelente", "Competente"… (castellano)
  labelCa?: string;         // "Excel·lent", "Competent"… (catalán, texto original del CARC)
  description: string;      // texto de ayuda para el evaluador
  descriptionCa?: string;
  representative: number;   // valor interno cuando el evaluador elige esta banda (9 / 7 / 5 / 3)
  /** Límite inferior en la escala interna. E es estricto (> 8,0): los empates exactos caen en
   *  la banda inferior más cercana a "Competente", la opción conservadora. */
  lower: number;
  lowerInclusive: boolean;
}

export interface Criterion {
  code: CriterionCode;
  name: string;                         // castellano
  nameCa?: string;                      // catalán (texto original del CARC)
  /** Nivel de la competencia en el CARC: 1 (básico), 2 o 3 (avanzado). */
  level?: 1 | 2 | 3;
  description: string;
  weight: number;                       // peso dentro del área (se normaliza)
  /** Descriptores por banda para guiar al evaluador (texto de ayuda, no lógica). */
  bandDescriptors?: Record<string, string>;
}

export interface RubricArea {
  code: AreaCode;
  name: string;
  nameCa?: string;
  weight: number;                       // peso en la nota global (se normaliza)
  criteria: Criterion[];
}

/** Regla de tope: si en un criterio hay ≥ minCount errores con impacto ≥ minImpact,
 *  la sugerencia de ESE criterio no puede superar la banda `capBand`. Nunca afecta a otros
 *  criterios, al área ni a la evaluación global de forma directa (decisión R4). */
export interface CapRule { minImpact: ImpactLevel; minCount: number; capBand: BandCode }

export interface ScoringParams {
  impactWeights: Record<ImpactLevel, number>;     // LOW 1 · MEDIUM 2 · HIGH 4 · MATCH_DEFINING 8
  verdictCredit: Record<AssessedVerdict, number>; // CORRECT 1 · DEBATABLE 0,5 · INCORRECT 0 · MISSED 0
  accuracyToScore: { atZero: number; atOne: number }; // recta p → nota: 1 + 8p
  baseline: number;                     // nota "Competente" (prior), 7,0
  priorStrength: number;                // k, en incidencias MEDIUM equivalentes, 3
  capRules: CapRule[];
  /** Longitud recomendada de la justificación cuando la banda final difiere de la sugerida
   *  o supera un tope (solo aviso: desde v3 nada del cierre es obligatorio). */
  minJustificationChars: number;        // 40
}

export interface AssessmentRubric {
  id: Id;
  code: string;                         // "FER-XV-2026"
  version: string;                      // semver; un informe guarda id + versión
  name: string;
  appliesTo: { formats: GameFormat[] };
  scale: ScoreScale;
  bands: PerformanceBand[];             // ordenadas de mayor a menor (E, C, N, U)
  areas: RubricArea[];
  /** Qué criterio alimenta cada etiqueta rápida. Total: todas las categorías mapeadas. */
  categoryToCriterion: Record<IncidentCategory, CriterionCode>;
  scoring: ScoringParams;
  status: 'DRAFT' | 'PUBLISHED' | 'RETIRED';
}

// ───────────────────────── 3. IncidentLog ─────────────────────────

export type ImpactLevel = 'LOW' | 'MEDIUM' | 'HIGH' | 'MATCH_DEFINING';
export type Verdict = 'PENDING' | 'CORRECT' | 'INCORRECT' | 'MISSED' | 'DEBATABLE' | 'NOT_ASSESSABLE';
export type AssessedVerdict = Exclude<Verdict, 'PENDING' | 'NOT_ASSESSABLE'>;
export type QuickPolarity = 'POSITIVE' | 'NEGATIVE' | 'REVIEW';
export type GamePhase = 'SET_PIECE' | 'BREAKDOWN' | 'OPEN_PLAY' | 'KICKING' | 'RESTART' | 'STOPPAGE' | 'OFF_FIELD';
export type FieldZone = 'OWN_22' | 'OWN_22_TO_HALF' | 'HALF_TO_OPP_22' | 'OPP_22' | 'IN_GOAL';

export type DecisionOutcome =
  | 'PLAY_ON' | 'ADVANTAGE' | 'PENALTY' | 'FREE_KICK' | 'SCRUM' | 'LINEOUT'
  | 'TRY' | 'NO_TRY' | 'PENALTY_TRY' | 'YELLOW_CARD' | 'RED_CARD_20' | 'RED_CARD'
  | 'WARNING' | 'TMO_REFERRAL' | 'NO_DECISION';

export interface Decision {
  outcomes: DecisionOutcome[];          // p. ej. ['PENALTY', 'YELLOW_CARD']
  againstTeam?: TeamSide;
  lawRef?: string;                      // número de ley de World Rugby, p. ej. "15.4"
  description?: string;
}

/** Tiempo de partido calculado en el momento de captura (desnormalizado para lectura rápida
 *  y para que el informe sea legible aunque el log de reloj se corrompa). */
export interface MatchTimeStamp {
  period: PeriodId | null;              // null = antes del inicio, descanso o final
  phaseLabel: 'PRE_MATCH' | 'IN_PLAY' | 'TIME_OFF' | 'INTERVAL' | 'FULL_TIME';
  periodElapsedMs: number;
  matchClockMs: number;                 // reloj acumulado "estilo marcador": 41:23 en H2
  overtimeMs: number;                   // > 0 si se jugaba con el tiempo cumplido
  integrity: 'OK' | 'DEGRADED';
  manualOverride?: boolean;             // el evaluador corrigió el minuto a mano
}

export type AttachmentKind = 'VOICE_NOTE' | 'PHOTO' | 'VIDEO_CLIP' | 'VIDEO_LINK';
export interface AttachmentRef {
  id: Id;
  kind: AttachmentKind;
  relativePath?: string;                // dentro del sandbox de la app; nunca ruta absoluta
  url?: string;                         // VIDEO_LINK: enlace + videoPositionMs
  videoPositionMs?: number;
  durationMs?: number;
  sha256?: string;
  status: 'PENDING_WRITE' | 'COMMITTED' | 'MISSING';
  transcript?: string;                  // opcional, transcripción en el dispositivo
}

export interface Incident {
  id: Id;
  assessmentId: Id;
  seq: number;                          // 1, 2, 3… por evaluación; el orden de captura manda
  capturedAt: { sessionMs: SessionMs; wallUtc: IsoUtc };
  matchTime: MatchTimeStamp;
  category: IncidentCategory;
  criterionCode: CriterionCode;         // por defecto, el del mapa de la rúbrica; editable
  polarity: QuickPolarity;
  gamePhase?: GamePhase;
  fieldZone?: FieldZone;
  decisionTaken?: Decision;
  decisionExpected?: Decision;          // obligatoria si verdict ∈ {INCORRECT, MISSED}
  verdict: Verdict;
  impact: ImpactLevel;
  impactConfirmed: boolean;             // false mientras sea el valor por defecto del tap
  notes?: string;
  attachments: AttachmentRef[];
  source: 'ONE_TAP' | 'MANUAL' | 'VIDEO_REVIEW';
  status: 'QUICK' | 'ENRICHED' | 'VOID';
  updatedAt: IsoUtc;
}

// ───────────────────────── 4. FinalReport ─────────────────────────

export interface CriterionScore {
  criterionCode: CriterionCode;
  suggestedBand: BandCode | null;       // lo que ve el evaluador; null = sin incidencias evaluadas
  suggested: number | null;             // interno
  finalBand: BandCode | null;           // lo que ELIGE el evaluador; null = no observado o sin valorar
  final: number | null;                 // interno = representative de finalBand
  notObserved: boolean;                 // p. ej. ningún scrum disputado ⇒ el peso se redistribuye
  justification: string;
  evidenceIncidentIds: Id[];
  capBand: BandCode | null;             // tope aplicado a la sugerencia de este criterio, si lo hubo
}

export interface AreaScore { areaCode: AreaCode; band: BandCode | null; score: number | null /* interno */ }

export interface Finding {
  id: Id;
  kind: 'STRENGTH' | 'DEVELOPMENT';
  criterionCode: CriterionCode;
  text: string;
  evidenceIncidentIds: Id[];
}

/** Recomendación obligatoria que el siguiente evaluador DEBE revisar. */
export interface ActionPoint {
  id: Id;
  refereeId: Id;
  originAssessmentId: Id;
  criterionCode: CriterionCode;
  text: string;                         // qué hacer
  successIndicator: string;             // qué se observará para darlo por logrado
  status: 'OPEN' | 'CLOSED';
}

export type ActionPointReviewStatus = 'ACHIEVED' | 'PARTIAL' | 'NOT_ACHIEVED' | 'NOT_OBSERVED';
export interface ActionPointReview {
  actionPointId: Id;
  status: ActionPointReviewStatus;
  comment: string;
  evidenceIncidentIds: Id[];
}

/** ↑ probar partidos de más exigencia · = mantener en partidos similares · ↓ reducir la exigencia. */
export type LevelRecommendation = 'UP' | 'SAME' | 'DOWN';

export type ReportStatus = 'DRAFT' | 'READY' | 'FINALIZED' | 'SUPERSEDED';

export interface FinalReport {
  assessmentId: Id;
  refereeId: Id;
  rubric: { id: Id; code: string; version: string };
  criterionScores: CriterionScore[];
  areaScores: AreaScore[];
  band: BandCode | null;                // RESULTADO VISIBLE de la evaluación
  overallScore: number | null;          // interno, sin redondear; solo auditoría y exportación técnica
  keyDecisionAccuracy: { correct: number; total: number; ratio: number | null }; // impacto ≥ HIGH
  summary: string;
  /** Dificultad real del partido, valorada al cerrar (la estimada está en MatchMetadata). */
  actualDifficulty?: MatchDifficulty | null;
  /** Recomendación del CARC sobre el nivel de los próximos partidos. */
  levelRecommendation?: LevelRecommendation | null;
  strengths: Finding[];                 // 0–3 (opcional)
  developmentAreas: Finding[];          // 0–3 (opcional)
  actionPoints: ActionPoint[];          // 0–3 (opcional)
  previousActionPointReviews: ActionPointReview[]; // todas las OPEN del árbitro
  status: ReportStatus;
  version: number;                      // 1, 2… (enmiendas)
  supersedesVersion?: number;
  amendmentReason?: string;
  finalizedAt?: IsoUtc;
  contentHash?: string;                 // sha256 del JSON canónico (§3.3)
}

// ───────────────────────── Agregado raíz ─────────────────────────

export type AssessmentStatus =
  | 'SETUP'          // datos del partido incompletos
  | 'READY'          // listo para el saque inicial
  | 'LIVE'           // reloj en marcha o en descanso
  | 'POST_MATCH'     // final del partido; redacción y puntuación
  | 'FINALIZED'      // informe cerrado y con hash
  | 'ARCHIVED';

export interface Assessment {
  id: Id;
  schemaVersion: 1;
  status: AssessmentStatus;
  match: MatchMetadata;
  rubricId: Id;
  createdAt: IsoUtc;
  updatedAt: IsoUtc;
}
