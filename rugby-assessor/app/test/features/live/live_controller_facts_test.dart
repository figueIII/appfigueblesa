import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/data/live_session_repository.dart';
import 'package:ref_assess/domain/category_presets.dart';
import 'package:ref_assess/domain/clock.dart';
import 'package:ref_assess/domain/laws.dart';
import 'package:ref_assess/domain/match_facts.dart';
import 'package:ref_assess/domain/model.dart';
import 'package:ref_assess/features/live/live_controller.dart';

import 'live_screen_test.dart' show FakeClock, RecordingHaptics, SeqIds, min;

/// Un único generador para toda la prueba: como los UUID de la app, no repite ids al reabrir.
final _ids = SeqIds();

LiveController controllerFor(InMemoryLiveSessionRepository repo, FakeClock clock) => LiveController(
      assessmentId: 'a1',
      repository: repo,
      clock: clock,
      ids: _ids,
      haptics: RecordingHaptics(),
    );

void main() {
  test('recuperación: al reabrir el directo vuelven el marcador, la transformación pendiente y las sanciones', () async {
    final repo = InMemoryLiveSessionRepository(LiveSessionSnapshot(
      assessmentId: 'a1',
      category: categoryPreset('M16'),
      homeTeam: 'Local',
      awayTeam: 'Visitante',
      clockLog: const [ClockEvent(seq: 1, t: 0, body: PeriodStart(PeriodId.h1))],
      incidents: const [],
    ));
    final clock = FakeClock()..t = 20 * min;
    final first = controllerFor(repo, clock);
    await first.load();
    first.addScore(TeamSide.home, ScoreKind.penaltyGoal, t: clock.t);
    first.addScore(TeamSide.away, ScoreKind.tryScored, t: clock.t);
    first.logSanction(TeamSide.home, SanctionKind.penalty, t: clock.t, infraction: InfractionRef.catalog('SIDE_ENTRY'));
    first.logSanction(TeamSide.home, SanctionKind.yellowCard, t: clock.t);
    await first.flush();
    first.dispose();

    // La app se cierra y se vuelve a abrir.
    final again = controllerFor(repo, clock);
    await again.load();
    expect(again.scoreline, const Scoreline(3, 5));
    expect(again.canConvert(TeamSide.away), isTrue, reason: 'la transformación sigue pendiente tras reabrir');
    expect(again.sanctionTally.count(TeamSide.home, SanctionKind.penalty), 1);
    expect(again.cards(TeamSide.home).single.infraction, isNull);
    expect(again.breakdown(TeamSide.home).single.label, 'Entrada lateral');
    // Los números de orden continúan (no se repiten tras recargar).
    again.addScore(TeamSide.away, ScoreKind.conversion, t: clock.t);
    again.logSanction(TeamSide.away, SanctionKind.freeKick, t: clock.t);
    await again.flush();
    expect(repo.scores.map((e) => e.seq), [1, 2, 3]);
    expect(repo.sanctions.map((e) => e.seq), [1, 2, 3]);
  });

  test('si falla el guardado, tantos y sanciones esperan en la cola en orden y se escriben al reintentar', () async {
    final repo = InMemoryLiveSessionRepository(LiveSessionSnapshot(
      assessmentId: 'a1',
      category: categoryPreset('M16'),
      homeTeam: 'Local',
      awayTeam: 'Visitante',
      clockLog: const [],
      incidents: const [],
    ));
    final clock = FakeClock()..t = 5 * min;
    final c = controllerFor(repo, clock);
    await c.load();
    repo.failWrites = true;
    c.addScore(TeamSide.home, ScoreKind.tryScored, t: clock.t);
    c.addScore(TeamSide.home, ScoreKind.conversion, t: clock.t);
    c.logSanction(TeamSide.away, SanctionKind.penalty, t: clock.t);
    await c.flush();
    expect(c.saveFailed, isTrue);
    expect(c.scoreline, const Scoreline(7, 0), reason: 'en pantalla, el marcador ya está actualizado');
    expect(repo.scores, isEmpty);
    repo.failWrites = false;
    await c.retryPendingWrites();
    expect(repo.storedScore, const Scoreline(7, 0));
    expect(repo.sanctions.single.team, TeamSide.away);
    expect(c.saveFailed, isFalse);
  });
}
