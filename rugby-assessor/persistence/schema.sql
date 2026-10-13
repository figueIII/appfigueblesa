-- Esquema SQLite offline-first — Evaluador arbitral de rugby (schema v3).
-- v2: solo se evalúa al árbitro principal (R5) y la evaluación visible es por bandas (R2).
-- v3: marcador (score_event), sanciones (sanction_event) e infracción de cada incidencia.
-- Portable a drift (Flutter) o Room (Android). Requiere SQLite ≥ 3.37 (tablas STRICT).
-- Ver docs/ESPECIFICACION_EVALUADOR_ARBITRAL.md §3.

PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA synchronous = FULL;     -- cada tap sobrevive a un apagado por batería (§3.1)
PRAGMA user_version = 3;

-- ───────────── Catálogos ─────────────

CREATE TABLE official (
  id               TEXT PRIMARY KEY,
  full_name        TEXT NOT NULL,
  federation_licence TEXT,
  grade            TEXT,
  home_society     TEXT,
  created_at       TEXT NOT NULL,
  updated_at       TEXT NOT NULL
) STRICT;

CREATE TABLE assessor_profile (
  id               TEXT PRIMARY KEY,
  full_name        TEXT NOT NULL,
  federation_licence TEXT,
  email            TEXT
) STRICT;

CREATE TABLE rubric (
  id               TEXT PRIMARY KEY,
  code             TEXT NOT NULL,
  version          TEXT NOT NULL,
  status           TEXT NOT NULL CHECK (status IN ('DRAFT','PUBLISHED','RETIRED')),
  definition_json  TEXT NOT NULL CHECK (json_valid(definition_json)), -- AssessmentRubric completo
  UNIQUE (code, version)
) STRICT;

-- Una rúbrica publicada es inmutable: los informes la referencian por id+versión.
CREATE TRIGGER rubric_published_immutable BEFORE UPDATE OF definition_json, code, version ON rubric
WHEN OLD.status <> 'DRAFT'
BEGIN SELECT RAISE(ABORT, 'RUBRIC_IMMUTABLE'); END;

-- ───────────── Evaluación (agregado raíz) ─────────────

CREATE TABLE assessment (
  id               TEXT PRIMARY KEY,
  schema_version   INTEGER NOT NULL DEFAULT 1,
  status           TEXT NOT NULL CHECK (status IN ('SETUP','READY','LIVE','POST_MATCH','FINALIZED','ARCHIVED')),
  rubric_id        TEXT NOT NULL REFERENCES rubric(id),
  assessor_id      TEXT NOT NULL REFERENCES assessor_profile(id),
  referee_id       TEXT NOT NULL REFERENCES official(id),   -- único oficial evaluado
  ar1_name         TEXT,                                    -- descriptivo, no se evalúa
  ar2_name         TEXT,                                    -- descriptivo, no se evalúa
  competition      TEXT NOT NULL,
  round            TEXT,
  kickoff_local    TEXT NOT NULL,
  kickoff_tz       TEXT NOT NULL,
  venue            TEXT NOT NULL,
  home_team        TEXT NOT NULL,
  away_team        TEXT NOT NULL,
  observation_mode TEXT NOT NULL CHECK (observation_mode IN ('LIVE','VIDEO','LIVE_AND_VIDEO')),
  difficulty       TEXT CHECK (difficulty IN ('LOW','MEDIUM','HIGH','VERY_HIGH')), -- solo contexto (R3)
  category_code    TEXT NOT NULL,                                     -- preset elegido (R6)
  category_json    TEXT NOT NULL CHECK (json_valid(category_json)),  -- snapshot de CategoryConfig
  conditions_json  TEXT CHECK (conditions_json IS NULL OR json_valid(conditions_json)),
  final_score_home INTEGER,
  final_score_away INTEGER,
  created_at       TEXT NOT NULL,
  updated_at       TEXT NOT NULL
) STRICT;
CREATE INDEX assessment_kickoff ON assessment(kickoff_local);
CREATE INDEX assessment_by_referee ON assessment(referee_id);

-- ───────────── Reloj: log append-only ─────────────

CREATE TABLE clock_event (
  assessment_id    TEXT NOT NULL REFERENCES assessment(id) ON DELETE CASCADE,
  seq              INTEGER NOT NULL,
  type             TEXT NOT NULL CHECK (type IN ('PERIOD_START','TIME_OFF','TIME_ON','PERIOD_END','ADJUST','INTEGRITY_LOST','ABANDON','VOID')),
  t_session_ms     INTEGER NOT NULL,           -- eje monotónico de la sesión
  boot_id          TEXT NOT NULL,              -- auditoría del origen del instante
  mono_ms          INTEGER NOT NULL,           -- SystemClock.elapsedRealtime() crudo
  wall_utc         TEXT NOT NULL,
  payload_json     TEXT NOT NULL DEFAULT '{}' CHECK (json_valid(payload_json)),
  PRIMARY KEY (assessment_id, seq)
) STRICT;

CREATE TRIGGER clock_event_no_update BEFORE UPDATE ON clock_event
BEGIN SELECT RAISE(ABORT, 'CLOCK_LOG_APPEND_ONLY'); END;
CREATE TRIGGER clock_event_no_delete BEFORE DELETE ON clock_event
WHEN (SELECT status FROM assessment WHERE id = OLD.assessment_id) IS NOT NULL
BEGIN SELECT RAISE(ABORT, 'CLOCK_LOG_APPEND_ONLY'); END;

-- Anclas del eje de sesión por arranque del dispositivo (§2.1.1).
CREATE TABLE session_time_anchor (
  assessment_id    TEXT NOT NULL REFERENCES assessment(id) ON DELETE CASCADE,
  boot_id          TEXT NOT NULL,
  mono_at_anchor   INTEGER NOT NULL,
  session_at_anchor INTEGER NOT NULL,
  wall_utc_at_anchor TEXT NOT NULL,
  estimated        INTEGER NOT NULL CHECK (estimated IN (0,1)), -- 1 = hueco estimado por hora de pared
  PRIMARY KEY (assessment_id, boot_id)
) STRICT;

-- ───────────── Incidencias ─────────────

CREATE TABLE incident (
  id               TEXT PRIMARY KEY,
  assessment_id    TEXT NOT NULL REFERENCES assessment(id) ON DELETE CASCADE,
  seq              INTEGER NOT NULL,
  t_session_ms     INTEGER NOT NULL,
  wall_utc         TEXT NOT NULL,
  -- tiempo de partido desnormalizado en la captura
  period           TEXT CHECK (period IN ('H1','H2','ET1','ET2','SD')),
  phase_label      TEXT NOT NULL CHECK (phase_label IN ('PRE_MATCH','IN_PLAY','TIME_OFF','INTERVAL','FULL_TIME')),
  period_elapsed_ms INTEGER NOT NULL,
  match_clock_ms   INTEGER NOT NULL,
  overtime_ms      INTEGER NOT NULL DEFAULT 0,
  time_integrity   TEXT NOT NULL CHECK (time_integrity IN ('OK','DEGRADED')),
  time_manual_override INTEGER NOT NULL DEFAULT 0 CHECK (time_manual_override IN (0,1)),
  -- clasificación
  category         TEXT NOT NULL,
  criterion_code   TEXT NOT NULL,
  polarity         TEXT NOT NULL CHECK (polarity IN ('POSITIVE','NEGATIVE','REVIEW')),
  game_phase       TEXT,
  field_zone       TEXT,
  decision_taken_json    TEXT CHECK (decision_taken_json IS NULL OR json_valid(decision_taken_json)),
  decision_expected_json TEXT CHECK (decision_expected_json IS NULL OR json_valid(decision_expected_json)),
  verdict          TEXT NOT NULL CHECK (verdict IN ('PENDING','CORRECT','INCORRECT','MISSED','DEBATABLE','NOT_ASSESSABLE')),
  impact           TEXT NOT NULL CHECK (impact IN ('LOW','MEDIUM','HIGH','MATCH_DEFINING')),
  impact_confirmed INTEGER NOT NULL CHECK (impact_confirmed IN (0,1)),
  notes            TEXT,
  source           TEXT NOT NULL CHECK (source IN ('ONE_TAP','MANUAL','VIDEO_REVIEW')),
  status           TEXT NOT NULL CHECK (status IN ('QUICK','ENRICHED','VOID')),
  void_reason      TEXT,
  updated_at       TEXT NOT NULL,
  -- v3: ley o infracción de la acción (laws.dart); CUSTOM = texto libre del evaluador
  infraction_code  TEXT,
  infraction_custom TEXT,
  infraction_law_ref TEXT,
  UNIQUE (assessment_id, seq),
  CHECK (infraction_code IS NOT 'CUSTOM' OR infraction_custom IS NOT NULL)
) STRICT;
CREATE INDEX incident_by_criterion ON incident(assessment_id, criterion_code) WHERE status <> 'VOID';
CREATE INDEX incident_pending ON incident(assessment_id) WHERE verdict = 'PENDING' AND status <> 'VOID';

-- Auditoría: cada edición guarda la versión anterior completa.
CREATE TABLE incident_revision (
  incident_id      TEXT NOT NULL REFERENCES incident(id) ON DELETE CASCADE,
  revised_at       TEXT NOT NULL,
  previous_json    TEXT NOT NULL CHECK (json_valid(previous_json))
) STRICT;

CREATE TRIGGER incident_audit AFTER UPDATE ON incident
BEGIN
  INSERT INTO incident_revision (incident_id, revised_at, previous_json)
  VALUES (OLD.id, NEW.updated_at, json_object(
    'category', OLD.category, 'criterion_code', OLD.criterion_code, 'verdict', OLD.verdict,
    'impact', OLD.impact, 'impact_confirmed', OLD.impact_confirmed, 'notes', OLD.notes,
    'decision_taken', json(OLD.decision_taken_json), 'decision_expected', json(OLD.decision_expected_json),
    'match_clock_ms', OLD.match_clock_ms, 'status', OLD.status, 'updated_at', OLD.updated_at,
    'infraction_code', OLD.infraction_code, 'infraction_custom', OLD.infraction_custom));
END;

-- Con la evaluación finalizada, las incidencias quedan congeladas (las enmiendas no las tocan).
CREATE TRIGGER incident_locked_after_finalize BEFORE UPDATE ON incident
WHEN (SELECT status FROM assessment WHERE id = OLD.assessment_id) IN ('FINALIZED','ARCHIVED')
BEGIN SELECT RAISE(ABORT, 'ASSESSMENT_LOCKED'); END;

CREATE TABLE attachment (
  id               TEXT PRIMARY KEY,
  incident_id      TEXT NOT NULL REFERENCES incident(id) ON DELETE CASCADE,
  kind             TEXT NOT NULL CHECK (kind IN ('VOICE_NOTE','PHOTO','VIDEO_CLIP','VIDEO_LINK')),
  relative_path    TEXT,
  url              TEXT,
  video_position_ms INTEGER,
  duration_ms      INTEGER,
  sha256           TEXT,
  status           TEXT NOT NULL CHECK (status IN ('PENDING_WRITE','COMMITTED','MISSING')),
  transcript       TEXT,
  created_at       TEXT NOT NULL,
  CHECK ((kind = 'VIDEO_LINK' AND url IS NOT NULL) OR (kind <> 'VIDEO_LINK' AND relative_path IS NOT NULL))
) STRICT;

-- ───────────── Hechos del partido (v3): marcador y sanciones ─────────────
-- Registros de solo inserción, como el reloj: "deshacer" anula (status VOID), nunca borra.

CREATE TABLE score_event (
  id               TEXT PRIMARY KEY,
  assessment_id    TEXT NOT NULL REFERENCES assessment(id) ON DELETE CASCADE,
  seq              INTEGER NOT NULL,
  team             TEXT NOT NULL CHECK (team IN ('HOME','AWAY')),
  kind             TEXT NOT NULL CHECK (kind IN ('TRY','CONVERSION','PENALTY_GOAL','DROP_GOAL')),
  points           INTEGER NOT NULL,
  t_session_ms     INTEGER NOT NULL,
  wall_utc         TEXT NOT NULL,
  period           TEXT CHECK (period IN ('H1','H2','ET1','ET2','SD')),
  match_clock_ms   INTEGER NOT NULL,
  status           TEXT NOT NULL CHECK (status IN ('ACTIVE','VOID')),
  UNIQUE (assessment_id, seq),
  CHECK ((kind = 'TRY' AND points = 5) OR (kind = 'CONVERSION' AND points = 2)
         OR (kind IN ('PENALTY_GOAL','DROP_GOAL') AND points = 3))
) STRICT;

CREATE TABLE sanction_event (
  id               TEXT PRIMARY KEY,
  assessment_id    TEXT NOT NULL REFERENCES assessment(id) ON DELETE CASCADE,
  seq              INTEGER NOT NULL,
  team             TEXT NOT NULL CHECK (team IN ('HOME','AWAY')),  -- equipo infractor
  kind             TEXT NOT NULL CHECK (kind IN ('PENALTY','FREE_KICK','YELLOW_CARD','RED_CARD')),
  infraction_code  TEXT,                                            -- NULL = sin especificar
  infraction_custom TEXT,
  infraction_law_ref TEXT,
  t_session_ms     INTEGER NOT NULL,
  wall_utc         TEXT NOT NULL,
  period           TEXT CHECK (period IN ('H1','H2','ET1','ET2','SD')),
  match_clock_ms   INTEGER NOT NULL,
  status           TEXT NOT NULL CHECK (status IN ('ACTIVE','VOID')),
  UNIQUE (assessment_id, seq),
  CHECK (infraction_code IS NOT 'CUSTOM' OR infraction_custom IS NOT NULL)
) STRICT;

-- Solo se permite anular (ACTIVE → VOID) y, en las sanciones, completar el motivo.
CREATE TRIGGER score_event_void_only BEFORE UPDATE ON score_event
WHEN NOT (OLD.status = 'ACTIVE' AND NEW.status = 'VOID' AND NEW.team = OLD.team AND NEW.kind = OLD.kind
          AND NEW.points = OLD.points AND NEW.seq = OLD.seq AND NEW.match_clock_ms = OLD.match_clock_ms)
BEGIN SELECT RAISE(ABORT, 'MATCH_FACTS_APPEND_ONLY'); END;
CREATE TRIGGER sanction_event_void_or_reason BEFORE UPDATE ON sanction_event
WHEN NOT (NEW.team = OLD.team AND NEW.kind = OLD.kind AND NEW.seq = OLD.seq AND NEW.match_clock_ms = OLD.match_clock_ms
          AND (NEW.status = OLD.status OR (OLD.status = 'ACTIVE' AND NEW.status = 'VOID')))
BEGIN SELECT RAISE(ABORT, 'MATCH_FACTS_APPEND_ONLY'); END;
CREATE TRIGGER score_event_no_delete BEFORE DELETE ON score_event
WHEN (SELECT status FROM assessment WHERE id = OLD.assessment_id) IS NOT NULL
BEGIN SELECT RAISE(ABORT, 'MATCH_FACTS_APPEND_ONLY'); END;
CREATE TRIGGER sanction_event_no_delete BEFORE DELETE ON sanction_event
WHEN (SELECT status FROM assessment WHERE id = OLD.assessment_id) IS NOT NULL
BEGIN SELECT RAISE(ABORT, 'MATCH_FACTS_APPEND_ONLY'); END;

-- Con la evaluación finalizada, los hechos del partido quedan congelados.
CREATE TRIGGER score_event_locked_insert BEFORE INSERT ON score_event
WHEN (SELECT status FROM assessment WHERE id = NEW.assessment_id) IN ('FINALIZED','ARCHIVED')
BEGIN SELECT RAISE(ABORT, 'ASSESSMENT_LOCKED'); END;
CREATE TRIGGER score_event_locked_update BEFORE UPDATE ON score_event
WHEN (SELECT status FROM assessment WHERE id = OLD.assessment_id) IN ('FINALIZED','ARCHIVED')
BEGIN SELECT RAISE(ABORT, 'ASSESSMENT_LOCKED'); END;
CREATE TRIGGER sanction_event_locked_insert BEFORE INSERT ON sanction_event
WHEN (SELECT status FROM assessment WHERE id = NEW.assessment_id) IN ('FINALIZED','ARCHIVED')
BEGIN SELECT RAISE(ABORT, 'ASSESSMENT_LOCKED'); END;
CREATE TRIGGER sanction_event_locked_update BEFORE UPDATE ON sanction_event
WHEN (SELECT status FROM assessment WHERE id = OLD.assessment_id) IN ('FINALIZED','ARCHIVED')
BEGIN SELECT RAISE(ABORT, 'ASSESSMENT_LOCKED'); END;

-- ───────────── Informe (versionado) ─────────────

CREATE TABLE report (
  assessment_id    TEXT NOT NULL REFERENCES assessment(id) ON DELETE CASCADE,
  version          INTEGER NOT NULL,
  referee_id       TEXT NOT NULL REFERENCES official(id),
  rubric_id        TEXT NOT NULL REFERENCES rubric(id),
  status           TEXT NOT NULL CHECK (status IN ('DRAFT','READY','FINALIZED','SUPERSEDED')),
  summary          TEXT NOT NULL DEFAULT '',
  band             TEXT CHECK (band IN ('BELOW','AT','ABOVE')),  -- resultado visible
  overall_score    REAL,                                          -- interno (auditoría)
  key_correct      INTEGER NOT NULL DEFAULT 0,
  key_total        INTEGER NOT NULL DEFAULT 0,
  amendment_reason TEXT,
  finalized_at     TEXT,
  canonical_json   TEXT CHECK (canonical_json IS NULL OR json_valid(canonical_json)),
  content_hash     TEXT,
  PRIMARY KEY (assessment_id, version),
  CHECK (status <> 'FINALIZED' OR (canonical_json IS NOT NULL AND content_hash IS NOT NULL AND finalized_at IS NOT NULL)),
  CHECK (version = 1 OR amendment_reason IS NOT NULL)
) STRICT;

-- Una versión FINALIZED solo puede pasar a SUPERSEDED; su contenido no cambia nunca.
CREATE TRIGGER report_finalized_immutable BEFORE UPDATE ON report
WHEN OLD.status = 'FINALIZED' AND NOT (
  NEW.status = 'SUPERSEDED' AND NEW.content_hash IS OLD.content_hash AND NEW.canonical_json IS OLD.canonical_json
  AND NEW.overall_score IS OLD.overall_score AND NEW.band IS OLD.band AND NEW.summary IS OLD.summary)
BEGIN SELECT RAISE(ABORT, 'REPORT_LOCKED'); END;
CREATE TRIGGER report_superseded_immutable BEFORE UPDATE ON report
WHEN OLD.status = 'SUPERSEDED'
BEGIN SELECT RAISE(ABORT, 'REPORT_LOCKED'); END;

CREATE TABLE criterion_score (
  assessment_id    TEXT NOT NULL,
  version          INTEGER NOT NULL,
  criterion_code   TEXT NOT NULL,
  suggested_band   TEXT CHECK (suggested_band IN ('BELOW','AT','ABOVE')),
  suggested        REAL,                                   -- interno
  final_band       TEXT CHECK (final_band IN ('BELOW','AT','ABOVE')), -- lo que elige el evaluador
  not_observed     INTEGER NOT NULL DEFAULT 0 CHECK (not_observed IN (0,1)),
  justification    TEXT NOT NULL DEFAULT '',
  cap_band         TEXT CHECK (cap_band IN ('BELOW','AT','ABOVE')),
  evidence_json    TEXT NOT NULL DEFAULT '[]' CHECK (json_valid(evidence_json)), -- ids de incidencias
  PRIMARY KEY (assessment_id, version, criterion_code),
  FOREIGN KEY (assessment_id, version) REFERENCES report(assessment_id, version) ON DELETE CASCADE,
  CHECK (not_observed = 0 OR final_band IS NULL)
) STRICT;

CREATE TABLE finding (
  id               TEXT PRIMARY KEY,
  assessment_id    TEXT NOT NULL,
  version          INTEGER NOT NULL,
  kind             TEXT NOT NULL CHECK (kind IN ('STRENGTH','DEVELOPMENT')),
  criterion_code   TEXT NOT NULL,
  text             TEXT NOT NULL,
  evidence_json    TEXT NOT NULL DEFAULT '[]' CHECK (json_valid(evidence_json)),
  position         INTEGER NOT NULL,
  FOREIGN KEY (assessment_id, version) REFERENCES report(assessment_id, version) ON DELETE CASCADE
) STRICT;

-- Las recomendaciones viven por árbitro, no por informe: cruzan evaluaciones.
CREATE TABLE action_point (
  id               TEXT PRIMARY KEY,
  referee_id       TEXT NOT NULL REFERENCES official(id),
  origin_assessment_id TEXT NOT NULL REFERENCES assessment(id),
  origin_version   INTEGER NOT NULL,
  criterion_code   TEXT NOT NULL,
  text             TEXT NOT NULL,
  success_indicator TEXT NOT NULL,
  status           TEXT NOT NULL CHECK (status IN ('DRAFT','OPEN','CLOSED')), -- DRAFT hasta finalizar el informe de origen
  closed_by_assessment_id TEXT REFERENCES assessment(id),
  created_at       TEXT NOT NULL
) STRICT;
CREATE INDEX action_point_open ON action_point(referee_id) WHERE status = 'OPEN';

CREATE TABLE action_point_review (
  assessment_id    TEXT NOT NULL,
  version          INTEGER NOT NULL,
  action_point_id  TEXT NOT NULL REFERENCES action_point(id),
  status           TEXT NOT NULL CHECK (status IN ('ACHIEVED','PARTIAL','NOT_ACHIEVED','NOT_OBSERVED')),
  comment          TEXT NOT NULL,
  evidence_json    TEXT NOT NULL DEFAULT '[]' CHECK (json_valid(evidence_json)),
  PRIMARY KEY (assessment_id, version, action_point_id),
  FOREIGN KEY (assessment_id, version) REFERENCES report(assessment_id, version) ON DELETE CASCADE
) STRICT;

-- ───────────── Sincronización futura y exportaciones ─────────────

-- Patrón outbox: cada cambio relevante deja una fila; un sincronizador futuro la consume.
CREATE TABLE outbox (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  aggregate_id     TEXT NOT NULL,
  kind             TEXT NOT NULL,         -- 'REPORT_FINALIZED', 'INCIDENT_UPSERTED'…
  payload_json     TEXT NOT NULL CHECK (json_valid(payload_json)),
  created_at       TEXT NOT NULL,
  sent_at          TEXT
) STRICT;

CREATE TABLE export_log (
  id               TEXT PRIMARY KEY,
  assessment_id    TEXT NOT NULL REFERENCES assessment(id),
  version          INTEGER NOT NULL,
  format           TEXT NOT NULL CHECK (format IN ('JSON','PDF')),
  relative_path    TEXT NOT NULL,
  sha256           TEXT NOT NULL,
  created_at       TEXT NOT NULL
) STRICT;
