import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/data/db/app_database.dart';
import 'package:ref_assess/data/drift_live_session_repository.dart';
import 'package:ref_assess/data/match_repository.dart';
import 'package:ref_assess/domain/category_presets.dart';
import 'package:ref_assess/domain/model.dart' as d;
import 'package:ref_assess/domain/rubric.dart';

import '../export/fixture.dart';
import 'drift_repository_test.dart' show incident;

MatchSetupInput input({
  String home = 'Club Local RC',
  String away = 'Visitante RT',
  String referee = 'Ana Árbitro',
  String assessor = 'Evaluadora',
  DateTime? kickoff,
  String competition = '',
  String? ar1,
  String? difficulty,
}) =>
    MatchSetupInput(
      category: categoryPreset('M16'),
      homeTeam: home,
      awayTeam: away,
      refereeName: referee,
      assessorName: assessor,
      kickoffLocal: kickoff ?? DateTime(2026, 10, 24, 12, 30),
      venue: '  Campo Municipal ',
      competition: competition,
      ar1Name: ar1,
      difficulty: difficulty,
    );

void main() {
  group('alta desde la preparación', () {
    late AppDatabase db;
    late DriftMatchRepository repo;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftMatchRepository(db, AssessmentSetup(db, SeqIds('t')));
    });
    tearDown(() => db.close());

    test('crea la evaluación READY con preset, asistentes, dificultad y textos sin espacios sobrantes', () async {
      final id = await repo.createMatch(input(ar1: ' Juez Uno ', difficulty: 'HIGH'));
      final row = await (db.select(db.assessment)..where((t) => t.id.equals(id))).getSingle();
      expect(row.status, 'READY');
      expect(row.categoryCode, 'M16');
      expect(row.kickoffLocal, '2026-10-24T12:30');
      expect(row.venue, 'Campo Municipal');
      expect(row.ar1Name, 'Juez Uno');
      expect(row.ar2Name, isNull, reason: 'asistente vacío → sin dato');
      expect(row.difficulty, 'HIGH');
      expect(row.competition, 'M16', reason: 'sin competición se usa el nombre de la categoría');
      expect(row.observationMode, 'LIVE');
    });

    test('el mismo árbitro (y evaluador) se reutiliza aunque cambien mayúsculas, tildes o espacios', () async {
      final a = await repo.createMatch(input());
      final b = await repo.createMatch(input(referee: '  ana   ARBITRO ', assessor: 'evaluadora'));
      final c = await repo.createMatch(input(referee: 'Otro Árbitro'));
      final rows = {for (final r in await db.select(db.assessment).get()) r.id: r};
      expect(rows[a]!.refereeId, rows[b]!.refereeId, reason: 'el seguimiento de recomendaciones depende de ello');
      expect(rows[a]!.assessorId, rows[b]!.assessorId);
      expect(rows[c]!.refereeId, isNot(rows[a]!.refereeId));
      expect(await repo.knownRefereeNames(), ['Ana Árbitro', 'Otro Árbitro'], reason: 'se conserva la primera grafía');
      expect(await repo.knownAssessorNames(), ['Evaluadora']);
    });

    test('lastAssessorName: el del último partido creado; null sin partidos', () async {
      expect(await repo.lastAssessorName(), isNull);
      await repo.createMatch(input(assessor: 'Primero'));
      await Future<void>.delayed(const Duration(milliseconds: 2)); // created_at distinto
      await repo.createMatch(input(assessor: 'Segunda'));
      expect(await repo.lastAssessorName(), 'Segunda');
    });
  });

  group('listado de la pantalla de inicio', () {
    late ExportFixture f;
    setUp(() async => f = await ExportFixture.create());
    tearDown(() => f.dispose());

    test('etapas, marcas, banda del informe cerrado y orden por saque (más reciente primero)', () async {
      final repo = DriftMatchRepository(f.db, AssessmentSetup(f.db, SeqIds('n')));
      final ready = await repo.createMatch(input(kickoff: DateTime(2026, 10, 25, 11)));
      final review = await repo.createMatch(input(home: 'Otro Local', kickoff: DateTime(2026, 10, 24, 18)));
      await f.db.customStatement("UPDATE assessment SET status = 'POST_MATCH' WHERE id = '$review'");

      final list = await repo.listMatches();
      expect(list.map((m) => m.id).take(2), [ready, review]);
      final byId = {for (final m in list) m.id: m};
      expect(byId[ready]!.stage, MatchStage.inProgress);
      expect(byId[ready]!.markCount, 0);
      expect(byId[ready]!.band, isNull);
      expect(byId[ready]!.categoryName, 'M16');
      expect(byId[ready]!.refereeName, 'Ana Árbitro');
      expect(byId[review]!.stage, MatchStage.pendingReview);

      final closed = byId[f.firstId]!;
      expect(closed.stage, MatchStage.finalized);
      expect(closed.markCount, 13, reason: '4 marcas + 9 sanciones, que también son marcas');
      expect(closed.band, isA<BandCode>(), reason: 'banda global del informe cerrado');
      expect(closed.refereeName, 'Árbitro Ejemplo');
      expect(closed.homeTeam, 'Club Local RC');
    });

    test('las marcas anuladas no cuentan', () async {
      final repo = DriftMatchRepository(f.db, AssessmentSetup(f.db, SeqIds('n')));
      final id = await repo.createMatch(input());
      final live = DriftLiveSessionRepository(f.db);
      final kept = incident(id, 1, 60000, d.IncidentCategory.scrum);
      final voided = incident(id, 2, 120000, d.IncidentCategory.tackle);
      await live.insertIncident(kept);
      await live.insertIncident(voided);
      await live.voidIncident(voided, 'marca por error');
      expect((await repo.listMatches()).firstWhere((m) => m.id == id).markCount, 1);
    });
  });

  test('stageFor: READY/LIVE en curso, POST_MATCH pendiente, FINALIZED/ARCHIVED finalizado', () {
    expect(stageFor('READY'), MatchStage.inProgress);
    expect(stageFor('LIVE'), MatchStage.inProgress);
    expect(stageFor('POST_MATCH'), MatchStage.pendingReview);
    expect(stageFor('FINALIZED'), MatchStage.finalized);
    expect(stageFor('ARCHIVED'), MatchStage.finalized);
  });
}
