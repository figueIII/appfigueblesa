// Casos de uso (API funcional del repositorio local) + reglas puras de validación.
// Las firmas son el contrato que implementará la capa de persistencia (drift/Room).
// Ver docs/…/ESPECIFICACION… §4.

import type {
  ActionPointReviewStatus, Assessment, AttachmentKind, AttachmentRef, CriterionCode, Decision,
  FieldZone, FinalReport, GamePhase, Id, ImpactLevel, Incident, IncidentCategory, MatchMetadata,
  OfficialRole, QuickPolarity, SessionMs, Verdict,
} from './model.ts';
import type { ClockEventBody, ClockState } from './clock.ts';
import type { SuggestedScore } from './scoring.ts';

// ───────────────────────── Resultado y errores ─────────────────────────

export type DomainErrorCode =
  | 'NOT_FOUND' | 'INVALID_STATE' | 'VALIDATION_FAILED' | 'CLOCK_RULE'
  | 'REPORT_LOCKED' | 'RUBRIC_NOT_PUBLISHED' | 'STORAGE_FULL' | 'MEDIA_WRITE_FAILED';

export type Result<T> =
  | { ok: true; value: T }
  | { ok: false; error: { code: DomainErrorCode; issues?: ValidationIssue[]; detail?: string } };

export interface ValidationIssue {
  code: string;                 // clave i18n estable, p. ej. "INCIDENT_EXPECTED_DECISION_REQUIRED"
  path: string;                 // "incidents[12].decisionExpected"
  severity: 'ERROR' | 'WARNING';
}

// ───────────────────────── Puertos (los implementa la plataforma) ─────────────────────────

export interface SessionClockPort {
  /** Milisegundos monotónicos de la sesión, a prueba de reinicios (§2.1.1). */
  now(): SessionMs;
  wallUtc(): string;
}
export interface IdPort { uuidv7(): Id }

// ───────────────────────── API ─────────────────────────

export interface CreateMatchAssessmentInput {
  match: MatchMetadata;
  rubricId: Id;                 // debe estar PUBLISHED y aplicar al formato y rol
}

export interface LogLiveIncidentInput {
  assessmentId: Id;
  /** Opcional: si no llega, se usa SessionClockPort.now() (caso del tap en directo). */
  timestamp?: SessionMs;
  category: IncidentCategory;
  polarity?: QuickPolarity;     // por defecto REVIEW
  severity?: ImpactLevel;       // = impact; si llega, impactConfirmed = true
  notes?: string;
  officialRole?: OfficialRole;  // por defecto REFEREE
}

export interface IncidentPatch {
  category?: IncidentCategory;
  criterionCode?: CriterionCode;
  verdict?: Verdict;
  impact?: ImpactLevel;
  gamePhase?: GamePhase;
  fieldZone?: FieldZone;
  decisionTaken?: Decision;
  decisionExpected?: Decision;
  notes?: string;
  matchClockOverrideMs?: number; // corrección manual del minuto
}

export interface AssessmentRepository {
  // Ciclo de vida
  createMatchAssessment(input: CreateMatchAssessmentInput): Promise<Result<Assessment>>;
  updateMatchMetadata(assessmentId: Id, patch: Partial<MatchMetadata>): Promise<Result<Assessment>>;
  getAssessment(assessmentId: Id): Promise<Result<Assessment>>;
  listAssessments(filter?: { officialId?: Id; status?: Assessment['status'] }): Promise<Assessment[]>;

  // Reloj (append-only)
  recordClockEvent(assessmentId: Id, body: ClockEventBody): Promise<Result<ClockState>>;
  undoLastClockEvent(assessmentId: Id): Promise<Result<ClockState>>;
  getClockState(assessmentId: Id): Promise<Result<ClockState>>;

  // Incidencias
  logLiveIncident(input: LogLiveIncidentInput): Promise<Result<Incident>>;
  undoLastIncident(assessmentId: Id, withinMs?: number): Promise<Result<Incident>>; // VOID, ventana 10 s
  enrichIncident(incidentId: Id, patch: IncidentPatch): Promise<Result<Incident>>;
  voidIncident(incidentId: Id, reason: string): Promise<Result<Incident>>;
  attachMedia(incidentId: Id, kind: AttachmentKind, source: { tempPath?: string; url?: string; videoPositionMs?: number }): Promise<Result<AttachmentRef>>;
  listIncidents(assessmentId: Id, filter?: { onlyPending?: boolean; criterion?: CriterionCode }): Promise<Incident[]>;

  // Puntuación e informe
  computeSuggestedScores(assessmentId: Id, officialId: Id): Promise<Result<SuggestedScore[]>>;
  updateCriteriaScore(assessmentId: Id, officialId: Id, criterion: CriterionCode,
    score: number | 'NOT_OBSERVED', justification: string): Promise<Result<FinalReport>>;
  upsertFinding(assessmentId: Id, officialId: Id, finding: Omit<FinalReport['strengths'][number], 'id'> & { id?: Id }): Promise<Result<FinalReport>>;
  upsertActionPoint(assessmentId: Id, officialId: Id, ap: { id?: Id; criterionCode: CriterionCode; text: string; successIndicator: string }): Promise<Result<FinalReport>>;
  reviewPreviousActionPoint(assessmentId: Id, actionPointId: Id, status: ActionPointReviewStatus, comment: string): Promise<Result<FinalReport>>;
  generateConsolidatedReport(assessmentId: Id): Promise<Result<FinalReport[]>>; // recalcula, valida, deja en READY o DRAFT con issues
  finalizeReport(assessmentId: Id, officialId: Id): Promise<Result<FinalReport>>; // bloquea, hash, cierra/abre action points
  amendReport(assessmentId: Id, officialId: Id, reason: string): Promise<Result<FinalReport>>; // nueva versión DRAFT

  // Exportación
  exportJson(assessmentId: Id, officialId: Id): Promise<Result<{ path: string; sha256: string }>>;
  exportPdf(assessmentId: Id, officialId: Id, opts?: { locale?: string; includeIncidentAnnex?: boolean }): Promise<Result<{ path: string }>>;

  // Histórico del oficial
  getOfficialHistory(officialId: Id): Promise<{ reports: FinalReport[]; openActionPoints: FinalReport['actionPoints'] }>;
}

// ───────────────────────── Reglas puras ─────────────────────────

/** Valores iniciales de un tap: el evaluador no decide nada en directo salvo la polaridad. */
export function quickTagDefaults(polarity: QuickPolarity, severity?: ImpactLevel): Pick<Incident, 'verdict' | 'impact' | 'impactConfirmed'> {
  return {
    verdict: polarity === 'POSITIVE' ? 'CORRECT' : 'PENDING',
    impact: severity ?? (polarity === 'POSITIVE' ? 'LOW' : 'MEDIUM'),
    impactConfirmed: severity !== undefined,
  };
}

/** Comprueba que un informe se puede finalizar. Devuelve [] si es válido. */
export function validateForFinalization(
  report: FinalReport, incidents: readonly Incident[], openPreviousActionPointIds: readonly Id[],
  params: { deviationRequiringJustification: number; minJustificationChars: number },
): ValidationIssue[] {
  const issues: ValidationIssue[] = [];
  const err = (code: string, path: string) => issues.push({ code, path, severity: 'ERROR' });
  const warn = (code: string, path: string) => issues.push({ code, path, severity: 'WARNING' });

  incidents.forEach((i, k) => {
    if (i.status === 'VOID' || i.officialRole !== report.role) return;
    const p = `incidents[${k}]`;
    if (i.verdict === 'PENDING') err('INCIDENT_VERDICT_PENDING', `${p}.verdict`);
    if (i.verdict === 'INCORRECT' || i.verdict === 'MISSED') {
      if (!i.decisionExpected) err('INCIDENT_EXPECTED_DECISION_REQUIRED', `${p}.decisionExpected`);
      if (!i.impactConfirmed) err('INCIDENT_IMPACT_NOT_CONFIRMED', `${p}.impact`);
    }
    if ((i.impact === 'HIGH' || i.impact === 'MATCH_DEFINING') && !i.notes?.trim()) err('KEY_INCIDENT_NOTES_REQUIRED', `${p}.notes`);
    if (i.attachments.some((a) => a.status !== 'COMMITTED')) warn('ATTACHMENT_NOT_COMMITTED', `${p}.attachments`);
    if (i.matchTime.integrity === 'DEGRADED' && !i.matchTime.manualOverride) warn('INCIDENT_TIME_DEGRADED', `${p}.matchTime`);
  });

  report.criterionScores.forEach((s, k) => {
    const p = `criterionScores[${k}]`;
    if (!s.notObserved && s.final === null) err('CRITERION_SCORE_MISSING', `${p}.final`);
    if (!s.justification.trim()) err('CRITERION_JUSTIFICATION_REQUIRED', `${p}.justification`);
    const deviates = s.final !== null && s.suggested !== null
      && Math.abs(s.final - s.suggested) > params.deviationRequiringJustification;
    const overCap = s.final !== null && s.capApplied !== null && s.final > s.capApplied;
    if ((deviates || overCap) && s.justification.trim().length < params.minJustificationChars) {
      err(overCap ? 'CAP_OVERRIDE_JUSTIFICATION_TOO_SHORT' : 'DEVIATION_JUSTIFICATION_TOO_SHORT', `${p}.justification`);
    }
  });

  if (report.strengths.length < 1 || report.strengths.length > 3) err('STRENGTHS_COUNT_1_TO_3', 'strengths');
  if (report.developmentAreas.length < 1 || report.developmentAreas.length > 3) err('DEVELOPMENT_COUNT_1_TO_3', 'developmentAreas');
  if (report.actionPoints.length < 1 || report.actionPoints.length > 3) err('ACTION_POINTS_COUNT_1_TO_3', 'actionPoints');
  report.actionPoints.forEach((a, k) => {
    if (!a.successIndicator.trim()) err('ACTION_POINT_INDICATOR_REQUIRED', `actionPoints[${k}].successIndicator`);
  });
  const reviewed = new Set(report.previousActionPointReviews.map((r) => r.actionPointId));
  openPreviousActionPointIds.forEach((id) => {
    if (!reviewed.has(id)) err('PREVIOUS_ACTION_POINT_NOT_REVIEWED', `previousActionPointReviews[${id}]`);
  });
  if (!report.summary.trim()) err('SUMMARY_REQUIRED', 'summary');
  return issues;
}

/** JSON canónico (claves ordenadas, sin espacios) para el hash de integridad (§3.3). */
export function canonicalJson(value: unknown): string {
  if (value === null || typeof value !== 'object') return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(',')}]`;
  const entries = Object.entries(value as Record<string, unknown>)
    .filter(([, v]) => v !== undefined)
    .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0));
  return `{${entries.map(([k, v]) => `${JSON.stringify(k)}:${canonicalJson(v)}`).join(',')}}`;
}
