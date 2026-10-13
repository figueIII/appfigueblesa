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
export type OfficialRole = 'REFEREE' | 'AR1' | 'AR2' | 'TMO';
export type PeriodId = 'H1' | 'H2' | 'ET1' | 'ET2' | 'SD';

// ───────────────────────── Catálogos ─────────────────────────

/** Configuración de categoría. Se copia (snapshot) dentro de cada partido: si la federación
 *  cambia la duración de M16 la temporada que viene, los informes antiguos no se alteran. */
export interface CategoryConfig {
  code: string;                 // "SENIOR", "M18", "M16", "SEVENS_SENIOR"…
  name: string;
  format: GameFormat;
  periodLengthMin: number;      // 40 (XV senior), 7 (7s)… configurable por federación
  halfTimeMin: number;
  extraTime: { periodLengthMin: number; suddenDeath: boolean } | null; // null = no hay prórroga
  sinBinMin: number;            // 10 (XV), 2 (7s)
  lawVariations: string[];      // códigos libres: "U18_SCRUM_1.5M", "RED_20MIN_TRIAL"…
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

export interface MatchOfficialAssignment {
  role: OfficialRole;
  officialId: Id;
  /** true = este oficial recibe informe en esta evaluación. MVP: solo REFEREE. */
  assessed: boolean;
}

export interface MatchMetadata {
  competition: string;
  round?: string;
  category: CategoryConfig;           // snapshot, no referencia
  kickoff: LocalDateTime;
  venue: string;
  home: TeamRef;
  away: TeamRef;
  officials: MatchOfficialAssignment[];
  assessorId: Id;
  observationMode: ObservationMode;
  difficulty?: MatchDifficulty;       // dato de contexto: NO modifica la nota (ver §2.3)
  conditions?: { weather?: string; pitch?: string };
  finalScore?: { home: number; away: number };
}

// ───────────────────────── 2. AssessmentRubric ─────────────────────────

export type AreaCode = 'PHASES' | 'MANAGEMENT' | 'LAW_DISCIPLINE' | 'FITNESS_POSITIONING';

export type CriterionCode =
  // A · Gestión de fases de juego
  | 'A1_SCRUM' | 'A2_LINEOUT_MAUL' | 'A3_TACKLE_RUCK' | 'A4_OFFSIDE_SPACE'
  // B · Comunicación y gestión del partido
  | 'B1_VERBAL_CONTROL' | 'B2_TONE_PRESENCE' | 'B3_CAPTAINS_PLAYERS' | 'B4_ADVANTAGE'
  // C · Aplicación de leyes y consistencia disciplinaria
  | 'C1_LAW_ACCURACY' | 'C2_FOUL_PLAY' | 'C3_SANCTION_CONSISTENCY'
  // D · Condición física, posicionamiento y líneas de carrera
  | 'D1_FITNESS' | 'D2_POSITIONING' | 'D3_RUNNING_LINES';

/** Etiquetas de registro rápido (un tap). Cada una alimenta exactamente un criterio. */
export type IncidentCategory =
  | 'SCRUM' | 'LINEOUT' | 'MAUL' | 'TACKLE' | 'RUCK'
  | 'OFFSIDE' | 'ADVANTAGE' | 'COMMUNICATION' | 'CAPTAIN_MGMT'
  | 'TRY_GROUNDING' | 'KNOCK_ON_FORWARD_PASS' | 'OTHER_LAW'
  | 'FOUL_PLAY' | 'CARD' | 'TMO_PROCESS'
  | 'POSITIONING' | 'FITNESS' | 'RUNNING_LINE';

export interface ScoreScale { min: number; max: number; step: number }  // 1–10, paso 0,5

export interface PerformanceBand {
  code: string;            // "EXCEPTIONAL", "ABOVE", "STANDARD", "IMPROVE", "BELOW"
  label: string;
  minInclusive: number;    // sobre la nota global redondeada a 1 decimal
}

export interface Criterion {
  code: CriterionCode;
  name: string;
  description: string;
  weight: number;                       // peso dentro del área (se normaliza)
  /** Descriptores por banda para guiar al evaluador (texto de ayuda, no lógica). */
  bandDescriptors?: Record<string, string>;
}

export interface RubricArea {
  code: AreaCode;
  name: string;
  weight: number;                       // peso en la nota global (se normaliza)
  criteria: Criterion[];
}

/** Regla de tope: si en un criterio hay ≥ minCount errores con impacto ≥ minImpact,
 *  la nota sugerida no puede superar `cap`. */
export interface CapRule { minImpact: ImpactLevel; minCount: number; cap: number }

export interface ScoringParams {
  impactWeights: Record<ImpactLevel, number>;     // LOW 1 · MEDIUM 2 · HIGH 4 · MATCH_DEFINING 8
  verdictCredit: Record<AssessedVerdict, number>; // CORRECT 1 · DEBATABLE 0,5 · INCORRECT 0 · MISSED 0
  accuracyToScore: { atZero: number; atOne: number }; // recta p → nota: 1 + 8p
  baseline: number;                     // nota "estándar del nivel" (prior), 7,0
  priorStrength: number;                // k, en incidencias MEDIUM equivalentes, 3
  capRules: CapRule[];
  deviationRequiringJustification: number; // |final − sugerida| > 1,0 ⇒ justificación larga
  minJustificationChars: number;        // 40
}

export interface AssessmentRubric {
  id: Id;
  code: string;                         // "FER-XV-2026"
  version: string;                      // semver; un informe guarda id + versión
  name: string;
  appliesTo: { formats: GameFormat[]; roles: OfficialRole[] };
  scale: ScoreScale;
  bands: PerformanceBand[];             // ordenadas de mayor a menor minInclusive
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
  officialRole: OfficialRole;           // a quién se atribuye (REFEREE por defecto)
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
  suggested: number | null;             // null = sin incidencias evaluadas
  final: number | null;                 // null solo si notObserved
  notObserved: boolean;                 // p. ej. ningún scrum disputado ⇒ el peso se redistribuye
  justification: string;
  evidenceIncidentIds: Id[];
  capApplied: number | null;            // tope aplicado a la sugerida, si lo hubo
}

export interface AreaScore { areaCode: AreaCode; score: number | null }

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
  officialId: Id;
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

export type ReportStatus = 'DRAFT' | 'READY' | 'FINALIZED' | 'SUPERSEDED';

export interface FinalReport {
  assessmentId: Id;
  officialId: Id;
  role: OfficialRole;
  rubric: { id: Id; code: string; version: string };
  criterionScores: CriterionScore[];
  areaScores: AreaScore[];
  overallScore: number | null;          // 1 decimal
  band: string | null;                  // código de PerformanceBand
  keyDecisionAccuracy: { correct: number; total: number; ratio: number | null }; // impacto ≥ HIGH
  summary: string;
  strengths: Finding[];                 // 1–3
  developmentAreas: Finding[];          // 1–3
  actionPoints: ActionPoint[];          // ≥ 1, máx. 3
  previousActionPointReviews: ActionPointReview[]; // todas las OPEN del oficial
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
  | 'FINALIZED'      // todos los informes cerrados y con hash
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
