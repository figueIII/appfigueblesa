// Escenarios de campo de extremo a extremo: controlador real + Drift sobre archivo + reloj anclado.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/core/platform_ports.dart';
import 'package:ref_assess/data/db/app_database.dart';
import 'package:ref_assess/data/drift_live_session_repository.dart';
import 'package:ref_assess/data/session_time.dart';
import 'package:ref_assess/domain/category_presets.dart';
import 'package:ref_assess/domain/clock.dart';
import 'package:ref_assess/domain/model.dart';
import 'package:ref_assess/features/live/live_controller.dart';

const min = 60000;

class FakeMono implements MonotonicSource {
  FakeMono(this.ms, this.boot);
  int ms;
  String boot;
  @override
  int nowMs() => ms;
  @override
  String bootId() => boot;
}

class SeqIds implements IdGenerator {
  SeqIds(this.prefix);
  final String prefix;
  int n = 0;
  @override
  String next() => '$prefix-${++n}';
}

class NoHaptics implements Haptics {
  @override
  void clockChanged() {}
  @override
  void incidentLogged() {}
  @override
  void refined() {}
  @override
  void undone() {}
  @override
  void warning() {}
}

/// Simula un arranque de la app: abre el archivo, recupera el reloj y carga la sesión.
class AppRun {
  AppRun._(this.db, this.controller, this.recovery);
  final AppDatabase db;
  final LiveController controller;
  final AnchorResolution recovery;

  /// `wallAtStart` es la hora de pared al arrancar; después avanza con la fuente monotónica.
  static Future<AppRun> start(File file, String assessmentId, FakeMono mono, DateTime wallAtStart, String idPrefix) async {
    final monoAtStart = mono.ms;
    DateTime wallNow() => wallAtStart.add(Duration(milliseconds: mono.ms - monoAtStart));
    final db = AppDatabase(NativeDatabase(file));
    final repo = DriftLiveSessionRepository(db);
    final (clock, recovery) = await openSessionClock(assessmentId: assessmentId, store: repo, mono: mono, wallNow: wallNow);
    final controller = LiveController(
      assessmentId: assessmentId,
      repository: repo,
      clock: clock,
      ids: SeqIds(idPrefix),
      haptics: NoHaptics(),
      clockRecovery: recovery,
    );
    await controller.load();
    return AppRun._(db, controller, recovery);
  }

  /// Cierre "brusco": se vacía lo que estaba en curso y se suelta el archivo, sin más.
  Future<void> kill() async {
    await controller.flush();
    controller.dispose();
    await db.close();
  }
}

void main() {
  late Directory tmp;
  late File file;
  late String assessmentId;
  final wall0 = DateTime.utc(2026, 10, 17, 15);

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('refassess_rec_');
    file = File('${tmp.path}/refassess.sqlite');
    final db = AppDatabase(NativeDatabase(file));
    assessmentId = await AssessmentSetup(db, SeqIds('setup')).createLiveAssessment(
      category: categoryPreset('SM_DHCAT_1_2_3'),
      competition: 'DHCAT', venue: 'Campo', homeTeam: 'Local', awayTeam: 'Visitante',
      refereeName: 'Árbitro', assessorName: 'Evaluador', kickoffLocal: DateTime(2026, 10, 17, 17),
    );
    await db.close();
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  test('el sistema mata la app en plena 1ª parte: al volver, reloj EXACTO y marcas intactas', () async {
    final mono = FakeMono(3600000, 'boot-A'); // el móvil lleva 1 h encendido
    final run1 = await AppRun.start(file, assessmentId, mono, wall0, 'r1');
    expect(run1.recovery.isNew, isTrue);
    run1.controller.applyClock(const PeriodStart(PeriodId.h1));
    mono.ms += 12 * min;
    run1.controller.logIncident(IncidentCategory.ruck, t: run1.controller.now());
    mono.ms += 3 * min;
    run1.controller.logIncident(IncidentCategory.scrum, t: run1.controller.now());
    run1.controller.refineLast(QuickPolarity.negative);
    await run1.kill();

    mono.ms += 7 * min; // 7 minutos con la app muerta (el partido sigue)
    final run2 = await AppRun.start(file, assessmentId, mono, wall0.add(const Duration(minutes: 22)), 'r2');
    final c = run2.controller;
    expect(run2.recovery.isNew, isFalse, reason: 'mismo arranque: se reutiliza el ancla');
    expect(c.clockState.status, ClockStatus.running);
    expect(c.clockState.integrity, TimeIntegrity.ok);
    expect(formatClock(c.matchTimeAt(c.now()).matchClockMs), '22:00');
    expect(c.incidents.map((i) => (i.category, formatClock(i.matchTime.matchClockMs), i.polarity)).toList(), [
      (IncidentCategory.ruck, '12:00', QuickPolarity.review),
      (IncidentCategory.scrum, '15:00', QuickPolarity.negative),
    ]);
    // Se puede seguir marcando: la secuencia continúa sin colisiones.
    c.logIncident(IncidentCategory.tackle, t: c.now());
    await run2.kill();
    final run3 = await AppRun.start(file, assessmentId, mono, wall0.add(const Duration(minutes: 22)), 'r3');
    expect(run3.controller.incidents.map((i) => i.seq), [1, 2, 3]);
    await run3.kill();
  });

  test('reinicio del móvil con el reloj en marcha: tiempo estimado, INTEGRITY_LOST y ajuste lo resuelve', () async {
    final mono = FakeMono(500000, 'boot-A');
    final run1 = await AppRun.start(file, assessmentId, mono, wall0, 'r1');
    run1.controller.applyClock(const PeriodStart(PeriodId.h1));
    mono.ms += 20 * min;
    run1.controller.logIncident(IncidentCategory.offside, t: run1.controller.now()); // 20:00, a las 15:20 de pared
    await run1.kill();

    // Se apaga y reinicia: la fuente monotónica vuelve a ~0 y el arranque cambia.
    final mono2 = FakeMono(40000, 'boot-B');
    final run2 = await AppRun.start(file, assessmentId, mono2, wall0.add(const Duration(minutes: 24)), 'r2');
    final c = run2.controller;
    expect((run2.recovery.isNew, run2.recovery.estimated, run2.recovery.estimatedGapMs), (true, true, 4 * min));
    expect(c.clockState.integrity, TimeIntegrity.degraded);
    expect(formatClock(c.matchTimeAt(c.now()).matchClockMs), '24:00', reason: '20:00 + 4 min de pared');
    final lost = c.clockLog.last.body;
    expect(lost, isA<IntegrityLost>());

    // Las marcas mientras está degradado lo indican; el ajuste con el reloj oficial lo limpia.
    c.logIncident(IncidentCategory.ruck, t: c.now());
    expect(c.incidents.last.matchTime.integrity, TimeIntegrity.degraded);
    c.applyClock(const Adjust(-10000));
    expect(c.clockState.integrity, TimeIntegrity.ok);
    expect(formatClock(c.matchTimeAt(c.now()).matchClockMs), '23:50');
    await run2.kill();

    // Y todo eso también sobrevive a otro cierre.
    mono2.ms += 60000;
    final run3 = await AppRun.start(file, assessmentId, mono2, wall0.add(const Duration(minutes: 25)), 'r3');
    expect(run3.recovery.isNew, isFalse);
    expect(formatClock(run3.controller.matchTimeAt(run3.controller.now()).matchClockMs), '24:50');
    expect(run3.controller.clockState.integrity, TimeIntegrity.ok);
    await run3.kill();
  });

  test('reinicio en el descanso: no hay tiempo de partido en juego, no se marca integridad', () async {
    final mono = FakeMono(0, 'boot-A');
    final run1 = await AppRun.start(file, assessmentId, mono, wall0, 'r1');
    run1.controller.applyClock(const PeriodStart(PeriodId.h1));
    mono.ms += 41 * min;
    run1.controller.applyClock(const PeriodEnd(PeriodEndNext.interval));
    await run1.kill();
    final run2 = await AppRun.start(file, assessmentId, FakeMono(1000, 'boot-B'), wall0.add(const Duration(minutes: 50)), 'r2');
    expect(run2.recovery.estimated, isTrue);
    expect(run2.controller.clockState.status, ClockStatus.interval);
    expect(run2.controller.clockState.integrity, TimeIntegrity.ok);
    expect(run2.controller.clockLog.last.body, isA<PeriodEnd>());
    await run2.kill();
  });

  test('cada tap llega a disco en una transacción propia, en orden y en milisegundos', () async {
    final mono = FakeMono(0, 'boot-A');
    final run = await AppRun.start(file, assessmentId, mono, wall0, 'r1');
    final c = run.controller;
    c.applyClock(const PeriodStart(PeriodId.h1));
    final sw = Stopwatch()..start();
    for (var i = 0; i < 40; i++) {
      mono.ms += 1000;
      c.logIncident(IncidentCategory.values[i % IncidentCategory.values.length], t: c.now());
    }
    await c.flush();
    sw.stop();
    final rows = await (run.db.select(run.db.incident)).get();
    expect(rows.map((r) => r.seq).toList(), List.generate(40, (i) => i + 1));
    // ignore: avoid_print
    print('40 taps confirmados en disco (synchronous=FULL) en ${sw.elapsedMilliseconds} ms '
        '(${(sw.elapsedMicroseconds / 40 / 1000).toStringAsFixed(2)} ms/tap)');
    await run.kill();
  });
}
