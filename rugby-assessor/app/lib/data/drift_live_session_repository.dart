// Implementación Drift de la persistencia de la captura en directo y de las anclas de tiempo.
// Cada operación es UNA transacción SQLite; con synchronous=FULL (app_database.dart), cuando el
// Future completa, el dato ya está en disco.

import 'package:drift/drift.dart';

import '../core/platform_ports.dart';
import '../domain/clock.dart' as d;
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

    return LiveSessionSnapshot(
      assessmentId: a.id,
      category: decodeCategoryConfig(a.categoryJson),
      homeTeam: a.homeTeam,
      awayTeam: a.awayTeam,
      clockLog: [
        for (final e in events) d.ClockEvent(seq: e.seq, t: e.tSessionMs, body: decodeClockBody(e.type, e.payloadJson)),
      ],
      incidents: [for (final i in incidents) _toIncident(i)],
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
      updatedAt: Value(_nowIso()),
    ));
    if (n != 1) throw StateError('INCIDENT_NOT_FOUND: ${i.id}');
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
      ') ORDER BY t DESC LIMIT 1',
      variables: [Variable.withString(assessmentId)],
      readsFrom: {db.clockEvent, db.incident},
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

/// Alta mínima de una evaluación para la captura en directo. La pantalla de preparación del
/// partido (fuera de esta entrega) usará este mismo servicio con los datos del formulario.
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
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final id = ids.next(), refereeId = ids.next(), assessorId = ids.next();
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
      await db.into(db.assessorProfile).insert(AssessorProfileCompanion.insert(id: assessorId, fullName: assessorName));
      await db.into(db.official).insert(OfficialCompanion.insert(id: refereeId, fullName: refereeName, createdAt: now, updatedAt: now));
      final k = kickoffLocal;
      String two(int v) => v.toString().padLeft(2, '0');
      await db.into(db.assessment).insert(AssessmentCompanion.insert(
            id: id,
            status: 'READY',
            rubricId: rubricId,
            assessorId: assessorId,
            refereeId: refereeId,
            competition: competition,
            kickoffLocal: '${k.year}-${two(k.month)}-${two(k.day)}T${two(k.hour)}:${two(k.minute)}',
            kickoffTz: kickoffTz,
            venue: venue,
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            observationMode: 'LIVE',
            categoryCode: category.code,
            categoryJson: encodeCategoryConfig(category),
            createdAt: now,
            updatedAt: now,
          ));
      return id;
    });
  }

  /// Evaluación en curso más reciente (READY o LIVE), para reanudar tras un cierre.
  Future<String?> latestOpenAssessment() async {
    final row = await (db.select(db.assessment)
          ..where((t) => t.status.isIn(['READY', 'LIVE']))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }
}
