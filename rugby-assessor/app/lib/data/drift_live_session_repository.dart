// Implementación Drift de la persistencia de la captura en directo y de las anclas de tiempo.
// Cada operación es UNA transacción SQLite; con synchronous=FULL (app_database.dart), cuando el
// Future completa, el dato ya está en disco.

import 'package:drift/drift.dart';

import '../core/platform_ports.dart';
import '../domain/clock.dart' as d;
import '../domain/laws.dart' as d;
import '../domain/match_facts.dart' as d;
import '../domain/model.dart' as d;
import 'codecs.dart';
import 'db/app_database.dart';
import 'live_session_repository.dart';
import 'session_time.dart';

class DriftLiveSessionRepository implements LiveSessionRepository, ReviewRepository, SessionTimeStore {
  DriftLiveSessionRepository(this.db);
  final AppDatabase db;

  String _iso(DateTime t) => t.toUtc().toIso8601String();
  String _nowIso() => _iso(DateTime.now());

  // ───────────── Carga ─────────────

  @override
  Future<LiveSessionSnapshot> load(String assessmentId) async {
    final a = await (db.select(db.assessment)..where((t) => t.id.equals(assessmentId))).getSingleOrNull();
    if (a == null) throw StateError('ASSESSMENT_NOT_FOUND: $assessmentId');

    final events = await (db.select(db.clockEvent)
          ..where((t) => t.assessmentId.equals(assessmentId))
          ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
        .get();
    final incidents = await (db.select(db.incident)
          ..where((t) => t.assessmentId.equals(assessmentId))
          ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
        .get();
    final scores = await (db.select(db.scoreEvent)
          ..where((t) => t.assessmentId.equals(assessmentId))
          ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
        .get();
    final sanctions = await (db.select(db.sanctionEvent)
          ..where((t) => t.assessmentId.equals(assessmentId))
          ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
        .get();

    return LiveSessionSnapshot(
      assessmentId: a.id,
      category: decodeCategoryConfig(a.categoryJson),
      homeTeam: a.homeTeam,
      awayTeam: a.awayTeam,
      clockLog: [
        for (final e in events) d.ClockEvent(seq: e.seq, t: e.tSessionMs, body: decodeClockBody(e.type, e.payloadJson)),
      ],
      incidents: [for (final i in incidents) _toIncident(i)],
      scores: [
        for (final e in scores)
          d.ScoreEvent(
            id: e.id,
            assessmentId: e.assessmentId,
            seq: e.seq,
            team: decodeTeam(e.team),
            kind: decodeScoreKind(e.kind),
            sessionMs: e.tSessionMs,
            wallUtc: DateTime.parse(e.wallUtc),
            period: e.period == null ? null : decodePeriod(e.period!),
            matchClockMs: e.matchClockMs,
            voided: e.status == 'VOID',
          ),
      ],
      sanctions: [
        for (final e in sanctions)
          d.SanctionEvent(
            id: e.id,
            assessmentId: e.assessmentId,
            seq: e.seq,
            team: decodeTeam(e.team),
            kind: decodeSanctionKind(e.kind),
            sessionMs: e.tSessionMs,
            wallUtc: DateTime.parse(e.wallUtc),
            period: e.period == null ? null : decodePeriod(e.period!),
            matchClockMs: e.matchClockMs,
            infraction: d.InfractionRef.decode(e.infractionCode, e.infractionCustom, e.infractionLawRef),
            voided: e.status == 'VOID',
          ),
      ],
    );
  }

  d.Incident _toIncident(IncidentData i) => d.Incident(
        id: i.id,
        assessmentId: i.assessmentId,
        seq: i.seq,
        sessionMs: i.tSessionMs,
        wallUtc: DateTime.parse(i.wallUtc),
        matchTime: d.MatchTimeStamp(
          period: i.period == null ? null : decodePeriod(i.period!),
          phase: decodePhase(i.phaseLabel),
          periodElapsedMs: i.periodElapsedMs,
          matchClockMs: i.matchClockMs,
          overtimeMs: i.overtimeMs,
          integrity: decodeIntegrity(i.timeIntegrity),
        ),
        category: decodeCategory(i.category),
        criterionCode: i.criterionCode,
        polarity: decodePolarity(i.polarity),
        verdict: decodeVerdict(i.verdict),
        impact: decodeImpact(i.impact),
        impactConfirmed: i.impactConfirmed == 1,
        status: decodeIncidentStatus(i.status),
        gamePhase: i.gamePhase == null ? null : decodeGamePhase(i.gamePhase!),
        fieldZone: i.fieldZone == null ? null : decodeZone(i.fieldZone!),
        decisionTaken: decodeDecision(i.decisionTakenJson),
        decisionExpected: decodeDecision(i.decisionExpectedJson),
        notes: i.notes,
        infraction: d.InfractionRef.decode(i.infractionCode, i.infractionCustom, i.infractionLawRef),
      );

  // ───────────── Escritura ─────────────

  @override
  Future<void> appendClockEvent(String assessmentId, d.ClockEvent event, TimeSample at, AssessmentPhase phase) {
    final (type, payload) = encodeClockBody(event.body);
    return db.transaction(() async {
      await db.into(db.clockEvent).insert(ClockEventCompanion.insert(
            assessmentId: assessmentId,
            seq: event.seq,
            type: type,
            tSessionMs: event.t,
            bootId: at.bootId,
            monoMs: at.monoMs,
            wallUtc: _iso(at.wallUtc),
            payloadJson: Value(payload),
          ));
      await (db.update(db.assessment)..where((t) => t.id.equals(assessmentId))).write(AssessmentCompanion(
        status: Value(switch (phase) {
          AssessmentPhase.ready => 'READY',
          AssessmentPhase.live => 'LIVE',
          AssessmentPhase.postMatch => 'POST_MATCH',
        }),
        updatedAt: Value(_nowIso()),
      ));
    });
  }

  @override
  Future<void> insertIncident(d.Incident i) => db.into(db.incident).insert(IncidentCompanion.insert(
        id: i.id,
        assessmentId: i.assessmentId,
        seq: i.seq,
        tSessionMs: i.sessionMs,
        wallUtc: _iso(i.wallUtc),
        period: Value(i.matchTime.period == null ? null : encodePeriod(i.matchTime.period!)),
        phaseLabel: encodePhase(i.matchTime.phase),
        periodElapsedMs: i.matchTime.periodElapsedMs,
        matchClockMs: i.matchTime.matchClockMs,
        overtimeMs: Value(i.matchTime.overtimeMs),
        timeIntegrity: encodeIntegrity(i.matchTime.integrity),
        category: encodeCategory(i.category),
        criterionCode: i.criterionCode,
        polarity: encodePolarity(i.polarity),
        verdict: encodeVerdict(i.verdict),
        impact: encodeImpact(i.impact),
        impactConfirmed: i.impactConfirmed ? 1 : 0,
        source: 'ONE_TAP',
        status: encodeIncidentStatus(i.status),
        gamePhase: Value(i.gamePhase == null ? null : encodeGamePhase(i.gamePhase!)),
        fieldZone: Value(i.fieldZone == null ? null : encodeZone(i.fieldZone!)),
        decisionTakenJson: Value(encodeDecision(i.decisionTaken)),
        decisionExpectedJson: Value(encodeDecision(i.decisionExpected)),
        notes: Value(i.notes),
        updatedAt: _iso(i.wallUtc),
        infractionCode: Value(i.infraction?.code),
        infractionCustom: Value(i.infraction?.customText),
        infractionLawRef: Value(i.infraction?.customLawRef),
      ));

  @override
  Future<void> updateIncident(d.Incident i) async {
    // El trigger incident_audit guarda la versión anterior en incident_revision.
    final n = await (db.update(db.incident)..where((t) => t.id.equals(i.id))).write(IncidentCompanion(
      polarity: Value(encodePolarity(i.polarity)),
      verdict: Value(encodeVerdict(i.verdict)),
      impact: Value(encodeImpact(i.impact)),
      impactConfirmed: Value(i.impactConfirmed ? 1 : 0),
      status: Value(encodeIncidentStatus(i.status)),
      voidReason: Value(i.status == d.IncidentStatus.voided ? 'UNDO' : null),
      infractionCode: Value(i.infraction?.code),
      infractionCustom: Value(i.infraction?.customText),
      infractionLawRef: Value(i.infraction?.customLawRef),
      updatedAt: Value(_nowIso()),
    ));
    if (n != 1) throw StateError('INCIDENT_NOT_FOUND: ${i.id}');
  }

  // ───────────── Marcador y sanciones ─────────────

  /// Recalcula el resultado del partido a partir de los tantos activos (misma transacción).
  Future<void> _refreshFinalScore(String assessmentId) => db.customStatement(
        'UPDATE assessment SET '
        "final_score_home = (SELECT COALESCE(SUM(points), 0) FROM score_event WHERE assessment_id = ?1 AND team = 'HOME' AND status = 'ACTIVE'), "
        "final_score_away = (SELECT COALESCE(SUM(points), 0) FROM score_event WHERE assessment_id = ?1 AND team = 'AWAY' AND status = 'ACTIVE'), "
        'updated_at = ?2 WHERE id = ?1',
        [assessmentId, _nowIso()],
      );

  @override
  Future<void> insertScoreEvent(d.ScoreEvent e) => db.transaction(() async {
        await db.into(db.scoreEvent).insert(ScoreEventCompanion.insert(
              id: e.id,
              assessmentId: e.assessmentId,
              seq: e.seq,
              team: encodeTeam(e.team),
              kind: encodeScoreKind(e.kind),
              points: e.points,
              tSessionMs: e.sessionMs,
              wallUtc: _iso(e.wallUtc),
              period: Value(e.period == null ? null : encodePeriod(e.period!)),
              matchClockMs: e.matchClockMs,
              status: e.voided ? 'VOID' : 'ACTIVE',
            ));
        await _refreshFinalScore(e.assessmentId);
      });

  @override
  Future<void> voidScoreEvent(d.ScoreEvent e) => db.transaction(() async {
        final n = await (db.update(db.scoreEvent)..where((t) => t.id.equals(e.id)))
            .write(const ScoreEventCompanion(status: Value('VOID')));
        if (n != 1) throw StateError('SCORE_EVENT_NOT_FOUND: ${e.id}');
        await _refreshFinalScore(e.assessmentId);
      });

  @override
  Future<void> insertSanction(d.SanctionEvent e) => db.into(db.sanctionEvent).insert(SanctionEventCompanion.insert(
        id: e.id,
        assessmentId: e.assessmentId,
        seq: e.seq,
        team: encodeTeam(e.team),
        kind: encodeSanctionKind(e.kind),
        infractionCode: Value(e.infraction?.code),
        infractionCustom: Value(e.infraction?.customText),
        infractionLawRef: Value(e.infraction?.customLawRef),
        tSessionMs: e.sessionMs,
        wallUtc: _iso(e.wallUtc),
        period: Value(e.period == null ? null : encodePeriod(e.period!)),
        matchClockMs: e.matchClockMs,
        status: e.voided ? 'VOID' : 'ACTIVE',
      ));

  @override
  Future<void> updateSanction(d.SanctionEvent e) async {
    final n = await (db.update(db.sanctionEvent)..where((t) => t.id.equals(e.id))).write(SanctionEventCompanion(
      status: Value(e.voided ? 'VOID' : 'ACTIVE'),
      infractionCode: Value(e.infraction?.code),
      infractionCustom: Value(e.infraction?.customText),
      infractionLawRef: Value(e.infraction?.customLawRef),
    ));
    if (n != 1) throw StateError('SANCTION_NOT_FOUND: ${e.id}');
  }

  // ───────────── Revisión post-partido ─────────────

  @override
  Future<ReviewSnapshot> loadReview(String assessmentId) async {
    final snap = await load(assessmentId);
    return ReviewSnapshot(homeTeam: snap.homeTeam, awayTeam: snap.awayTeam, incidents: snap.incidents);
  }

  @override
  Future<void> saveEnrichment(d.Incident i) async {
    final notes = i.notes?.trim();
    final n = await (db.update(db.incident)..where((t) => t.id.equals(i.id))).write(IncidentCompanion(
      category: Value(encodeCategory(i.category)),
      criterionCode: Value(i.criterionCode),
      polarity: Value(encodePolarity(i.polarity)),
      verdict: Value(encodeVerdict(i.verdict)),
      impact: Value(encodeImpact(i.impact)),
      impactConfirmed: Value(i.impactConfirmed ? 1 : 0),
      gamePhase: Value(i.gamePhase == null ? null : encodeGamePhase(i.gamePhase!)),
      fieldZone: Value(i.fieldZone == null ? null : encodeZone(i.fieldZone!)),
      decisionTakenJson: Value(encodeDecision(i.decisionTaken)),
      decisionExpectedJson: Value(encodeDecision(i.decisionExpected)),
      notes: Value(notes == null || notes.isEmpty ? null : notes),
      status: Value(encodeIncidentStatus(i.status)),
      infractionCode: Value(i.infraction?.code),
      infractionCustom: Value(i.infraction?.customText),
      infractionLawRef: Value(i.infraction?.customLawRef),
      updatedAt: Value(_nowIso()),
    ));
    if (n != 1) throw StateError('INCIDENT_NOT_FOUND: ${i.id}');
  }

  @override
  Future<void> voidIncident(d.Incident i, String reason) async {
    final n = await (db.update(db.incident)..where((t) => t.id.equals(i.id))).write(IncidentCompanion(
      status: const Value('VOID'),
      voidReason: Value(reason),
      updatedAt: Value(_nowIso()),
    ));
    if (n != 1) throw StateError('INCIDENT_NOT_FOUND: ${i.id}');
  }

  // ───────────── Anclas de tiempo ─────────────

  @override
  Future<List<SessionAnchor>> loadAnchors(String assessmentId) async {
    final rows = await (db.select(db.sessionTimeAnchor)..where((t) => t.assessmentId.equals(assessmentId))).get();
    return [
      for (final r in rows)
        SessionAnchor(
          bootId: r.bootId,
          monoAtAnchor: r.monoAtAnchor,
          sessionAtAnchor: r.sessionAtAnchor,
          wallUtcAtAnchor: DateTime.parse(r.wallUtcAtAnchor),
          estimated: r.estimated == 1,
        ),
    ];
  }

  @override
  Future<TimePoint?> lastTimePoint(String assessmentId) async {
    final row = await db.customSelect(
      'SELECT t, w FROM ('
      ' SELECT t_session_ms AS t, wall_utc AS w FROM clock_event WHERE assessment_id = ?1'
      ' UNION ALL'
      ' SELECT t_session_ms AS t, wall_utc AS w FROM incident WHERE assessment_id = ?1'
      ' UNION ALL'
      ' SELECT t_session_ms AS t, wall_utc AS w FROM score_event WHERE assessment_id = ?1'
      ' UNION ALL'
      ' SELECT t_session_ms AS t, wall_utc AS w FROM sanction_event WHERE assessment_id = ?1'
      ') ORDER BY t DESC LIMIT 1',
      variables: [Variable.withString(assessmentId)],
      readsFrom: {db.clockEvent, db.incident, db.scoreEvent, db.sanctionEvent},
    ).getSingleOrNull();
    return row == null ? null : TimePoint(row.read<int>('t'), DateTime.parse(row.read<String>('w')));
  }

  @override
  Future<void> insertAnchor(String assessmentId, SessionAnchor a) =>
      db.into(db.sessionTimeAnchor).insert(SessionTimeAnchorCompanion.insert(
            assessmentId: assessmentId,
            bootId: a.bootId,
            monoAtAnchor: a.monoAtAnchor,
            sessionAtAnchor: a.sessionAtAnchor,
            wallUtcAtAnchor: _iso(a.wallUtcAtAnchor),
            estimated: a.estimated ? 1 : 0,
          ));
}

/// Alta de una evaluación con los datos de la pantalla de preparación del partido
/// (vía `DriftMatchRepository.createMatch`).
class AssessmentSetup {
  AssessmentSetup(this.db, this.ids);
  final AppDatabase db;
  final IdGenerator ids;

  /// Rúbrica v2.0.0 (rubric-default.ts). Se registra como referencia; la definición completa
  /// (pesos y bandas) se carga en la pantalla 3.
  static const rubricId = '01929d6e-0000-7000-8000-000000000001';

  Future<String> createLiveAssessment({
    required d.CategoryConfig category,
    required String competition,
    required String venue,
    required String homeTeam,
    required String awayTeam,
    required String refereeName,
    required String assessorName,
    required DateTime kickoffLocal,
    String kickoffTz = 'Europe/Madrid',
    String? round,
    String? ar1Name,
    String? ar2Name,
    String? difficulty, // LOW | MEDIUM | HIGH | VERY_HIGH (solo descriptiva)
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final id = ids.next();
    String? opt(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    return db.transaction(() async {
      await db.into(db.rubric).insert(
            RubricCompanion.insert(
              id: rubricId,
              code: 'RUGBY-XV-BASE',
              version: '2.0.0',
              status: 'PUBLISHED',
              definitionJson: '{"code":"RUGBY-XV-BASE","version":"2.0.0"}',
            ),
            mode: InsertMode.insertOrIgnore,
          );
      // El MISMO árbitro (y evaluador) se reutiliza entre partidos: de ello depende el
      // seguimiento de recomendaciones de un informe al siguiente (spec §1.4).
      final refereeId = await _officialIdFor(refereeName.trim(), now);
      final assessorId = await _assessorIdFor(assessorName.trim());
      final k = kickoffLocal;
      String two(int v) => v.toString().padLeft(2, '0');
      await db.into(db.assessment).insert(AssessmentCompanion.insert(
            id: id,
            status: 'READY',
            rubricId: rubricId,
            assessorId: assessorId,
            refereeId: refereeId,
            ar1Name: Value(opt(ar1Name)),
            ar2Name: Value(opt(ar2Name)),
            competition: competition.trim(),
            round: Value(opt(round)),
            kickoffLocal: '${k.year}-${two(k.month)}-${two(k.day)}T${two(k.hour)}:${two(k.minute)}',
            kickoffTz: kickoffTz,
            venue: venue.trim(),
            homeTeam: homeTeam.trim(),
            awayTeam: awayTeam.trim(),
            observationMode: 'LIVE',
            difficulty: Value(difficulty),
            categoryCode: category.code,
            categoryJson: encodeCategoryConfig(category),
            createdAt: now,
            updatedAt: now,
          ));
      return id;
    });
  }

  /// Igualdad de nombres sin distinguir mayúsculas, tildes ni espacios sobrantes.
  static String normalizeName(String v) => v
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp('[áàä]'), 'a')
      .replaceAll(RegExp('[éèë]'), 'e')
      .replaceAll(RegExp('[íìï]'), 'i')
      .replaceAll(RegExp('[óòö]'), 'o')
      .replaceAll(RegExp('[úùü]'), 'u');

  Future<String> _officialIdFor(String name, String now) async {
    final key = normalizeName(name);
    for (final o in await db.select(db.official).get()) {
      if (normalizeName(o.fullName) == key) return o.id;
    }
    final id = ids.next();
    await db.into(db.official).insert(OfficialCompanion.insert(id: id, fullName: name, createdAt: now, updatedAt: now));
    return id;
  }

  Future<String> _assessorIdFor(String name) async {
    final key = normalizeName(name);
    for (final a in await db.select(db.assessorProfile).get()) {
      if (normalizeName(a.fullName) == key) return a.id;
    }
    final id = ids.next();
    await db.into(db.assessorProfile).insert(AssessorProfileCompanion.insert(id: id, fullName: name));
    return id;
  }

  /// Evaluación sin cerrar más reciente (READY, LIVE o POST_MATCH), para reanudar tras un cierre
  /// de la app: también la que espera revisión y evaluación después del partido.
  Future<String?> latestOpenAssessment() async {
    final row = await (db.select(db.assessment)
          ..where((t) => t.status.isIn(['READY', 'LIVE', 'POST_MATCH']))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }
}
