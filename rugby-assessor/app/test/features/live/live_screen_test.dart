import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/core/design_system/theme.dart';
import 'package:ref_assess/core/platform_ports.dart';
import 'package:ref_assess/data/live_session_repository.dart';
import 'package:ref_assess/domain/category_presets.dart';
import 'package:ref_assess/domain/clock.dart';
import 'package:ref_assess/domain/model.dart';
import 'package:ref_assess/features/live/live_controller.dart';
import 'package:ref_assess/features/live/live_screen.dart';

const min = 60000;

class FakeClock implements SessionClock {
  int t = 0;
  @override
  int now() => t;
  @override
  DateTime wallUtc() => DateTime.utc(2026, 10, 17, 15).add(Duration(milliseconds: t));
  @override
  TimeSample sample() => TimeSample(sessionMs: t, monoMs: t, bootId: 'fake', wallUtc: wallUtc());
}

class SeqIds implements IdGenerator {
  int n = 0;
  @override
  String next() => 'id-${++n}';
}

class RecordingHaptics implements Haptics {
  final List<String> calls = [];
  @override
  void incidentLogged() => calls.add('logged');
  @override
  void refined() => calls.add('refined');
  @override
  void undone() => calls.add('undone');
  @override
  void clockChanged() => calls.add('clock');
  @override
  void warning() => calls.add('warning');
}

class FakeScreenAwake implements ScreenAwake {
  bool on = false;
  @override
  Future<void> enable() async => on = true;
  @override
  Future<void> disable() async => on = false;
}

class Harness {
  Harness({List<ClockEvent> clockLog = const []})
      : repo = InMemoryLiveSessionRepository(
          LiveSessionSnapshot(
            assessmentId: 'a1',
            category: categoryPreset('SM_DHCAT_1_2_3'),
            homeTeam: 'Club Local RC',
            awayTeam: 'Visitante RT',
            clockLog: clockLog,
            incidents: const [],
          ),
        );

  final InMemoryLiveSessionRepository repo;
  final clock = FakeClock();
  final haptics = RecordingHaptics();
  final awake = FakeScreenAwake();
  late final controller = LiveController(
    assessmentId: 'a1',
    repository: repo,
    clock: clock,
    ids: SeqIds(),
    haptics: haptics,
  );

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1.0,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildRefTheme(brightness),
        home: MediaQuery(
          data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
          child: LiveScreen(controller: controller, onGoToReview: () {}, screenAwake: awake),
        ),
      ),
    );
    await tester.pump();
  }

  /// Avanza el reloj falso y deja que los temporizadores de la UI repinten.
  Future<void> advance(WidgetTester tester, int ms) async {
    clock.t += ms;
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Finder tile(String category) => find.byKey(ValueKey('tag-$category'));

void main() {
  testWidgets('estado inicial: hint vacío, contador a cero y "Iniciar 1ª parte"; pantalla encendida', (tester) async {
    final h = Harness();
    await h.pump(tester);
    expect(find.textContaining('Toca una acción para marcarla'), findsOneWidget);
    expect(find.text('Sin marcas todavía'), findsOneWidget);
    expect(find.text('ANTES DEL INICIO'), findsOneWidget);
    expect(find.text('Iniciar\n1ª parte'), findsOneWidget);
    expect(h.awake.on, isTrue);
  });

  testWidgets('iniciar la 1ª parte registra el evento y cambia la acción a "Parar tiempo"', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
    await tester.pump();
    expect(h.repo.clockLog.single.body, isA<PeriodStart>());
    expect(find.text('1ª PARTE · EN JUEGO'), findsOneWidget);
    expect(find.text('Parar\ntiempo'), findsOneWidget);
    expect(h.haptics.calls, ['clock']);
  });

  testWidgets('un tap marca con el instante del PRIMER contacto, no el de levantar el dedo', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
    await h.advance(tester, 12 * min);

    final gesture = await tester.startGesture(tester.getCenter(tile('ruck')));
    await tester.pump();
    h.clock.t += 1500; // el dedo tarda 1,5 s en levantarse
    await gesture.up();
    await tester.pump();

    final i = h.repo.incidents.single;
    expect(i.sessionMs, 12 * min);
    expect(formatClock(i.matchTime.matchClockMs), '12:00');
    expect(i.category, IncidentCategory.ruck);
    expect(i.criterionCode, 'A3_TACKLE_RUCK');
    expect(i.verdict, Verdict.pending);
    expect(find.text('Marcado: Ruck · 12:00'), findsOneWidget);
    expect(find.text('1 marca · 1 por revisar'), findsOneWidget);
    expect(find.text('×1'), findsOneWidget);
    expect(h.haptics.calls.last, 'logged');
  });

  testWidgets('deslizar el dedo fuera de la tesela cancela la marca', (tester) async {
    final h = Harness();
    await h.pump(tester);
    final gesture = await tester.startGesture(tester.getCenter(tile('scrum')));
    await gesture.moveBy(const Offset(0, -400));
    await gesture.up();
    await tester.pump();
    expect(h.repo.incidents, isEmpty);
  });

  testWidgets('valorar ✓ Bien la convierte en acierto; ✗ Error la deja pendiente de clasificar', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(tile('tackle'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('refine-positive')));
    await tester.pump();
    var i = h.repo.incidents.single;
    expect((i.polarity, i.verdict, i.impact), (QuickPolarity.positive, Verdict.correct, ImpactLevel.low));
    expect(find.text('1 marca · 0 por revisar'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('refine-negative')));
    await tester.pump();
    i = h.repo.incidents.single;
    expect((i.polarity, i.verdict, i.impact), (QuickPolarity.negative, Verdict.pending, ImpactLevel.medium));
    expect(h.haptics.calls, ['logged', 'refined', 'refined']);
  });

  testWidgets('Deshacer anula (VOID lógico, no borra) y descuenta la marca', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(tile('offside'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('refine-undo')));
    await tester.pump();
    expect(h.repo.incidents.single.status, IncidentStatus.voided);
    expect(find.text('Sin marcas todavía'), findsOneWidget);
    expect(find.textContaining('Anulada: Fuera de juego'), findsOneWidget);
    expect(find.text('×1'), findsNothing);
  });

  testWidgets('pasados 10 s, la tira pasa a resumen y ya no se puede valorar', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(tile('maul'));
    await tester.pump();
    await h.advance(tester, 10001);
    expect(find.byKey(const ValueKey('refine-positive')), findsNothing);
    expect(find.text('Última: Maul · 00:00 · Por revisar'), findsOneWidget);
  });

  testWidgets('"Más…" congela el minuto del tap aunque se tarde en elegir', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
    await h.advance(tester, 30 * min);
    await tester.tap(tile('more'));
    await tester.pumpAndSettle();
    expect(find.text('Marcar a las 30:00'), findsOneWidget);
    h.clock.t += 20000;
    await tester.tap(find.byKey(const ValueKey('more-communication')));
    await tester.pumpAndSettle();
    final i = h.repo.incidents.single;
    expect(i.category, IncidentCategory.communication);
    expect(i.sessionMs, 30 * min);
    expect(find.text('Marcar a las 30:00'), findsNothing);
  });

  testWidgets('tiempo cumplido: aparece el aviso con el exceso', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
    await h.advance(tester, 41 * min + 23000);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Tiempo cumplido +01:23'), findsOneWidget);
    expect(find.text('41:23'), findsOneWidget);
  });

  testWidgets('fin de la 1ª parte exige mantener pulsado; un toque corto no basta', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
    await h.advance(tester, 40 * min);
    await tester.tap(find.byKey(const ValueKey('clock-menu')));
    await tester.pumpAndSettle();

    final end = find.byKey(const ValueKey('end-interval'));
    await tester.tap(end); // toque corto
    await tester.pumpAndSettle();
    expect(h.controller.clockState.status, ClockStatus.running);

    final gesture = await tester.startGesture(tester.getCenter(end));
    // Mantener 1,2 s (umbral: 0,9 s), en fotogramas de 100 ms.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(h.controller.clockState.status, ClockStatus.interval);
    expect(find.text('DESCANSO'), findsOneWidget);
    expect(find.text('Iniciar\n2ª parte'), findsOneWidget);
  });

  testWidgets('ajuste fino ±10 s desde el menú del reloj', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
    await h.advance(tester, 5 * min);
    await tester.tap(find.byKey(const ValueKey('clock-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('adjust-10000')));
    await tester.pump();
    expect(h.controller.matchTimeAt(h.clock.t).periodElapsedMs, 5 * min + 10000);
    expect(h.repo.clockLog.last.body, isA<Adjust>());
  });

  testWidgets('fallo de guardado: aviso con pendientes, la captura sigue y Reintentar vacía la cola', (tester) async {
    final h = Harness();
    await h.pump(tester);
    h.repo.failWrites = true;
    await tester.tap(tile('card'));
    await tester.pump();
    expect(find.textContaining('No se ha podido guardar (1 pendiente)'), findsOneWidget);
    expect(h.repo.incidents, isEmpty);
    expect(h.haptics.calls, ['logged', 'warning']);
    expect(find.text('×1'), findsOneWidget, reason: 'la marca sigue visible y contada');

    h.repo.failWrites = false;
    await tester.tap(find.byKey(const ValueKey('retry-save')));
    await tester.pump();
    expect(find.textContaining('No se ha podido guardar'), findsNothing);
    expect(h.repo.incidents.single.category, IncidentCategory.card);
  });

  testWidgets('recupera un partido en curso desde el almacenamiento', (tester) async {
    final cat = categoryPreset('SM_DHCAT_1_2_3');
    final log = appendClockEvent(const [], const PeriodStart(PeriodId.h1), 0, cat);
    final h = Harness(clockLog: log);
    h.clock.t = 25 * min;
    await h.pump(tester);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Parar\ntiempo'), findsOneWidget);
  });

  group('accesibilidad y ergonomía (UI-UX-Pro-Max · prioridad 1 y 2)', () {
    for (final brightness in Brightness.values) {
      testWidgets('objetivos táctiles ≥ 48 dp, etiquetados y contraste de texto (${brightness.name})', (tester) async {
        final handle = tester.ensureSemantics();
        final h = Harness();
        await h.pump(tester, brightness: brightness);
        await tester.tap(tile('ruck'));
        await tester.pump();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }

    testWidgets('las teselas de la rejilla miden ≥ 88 dp de alto en un móvil normal', (tester) async {
      final h = Harness();
      await h.pump(tester);
      for (final name in ['tackle', 'ruck', 'offside', 'scrum', 'more']) {
        expect(tester.getSize(tile(name)).height, greaterThanOrEqualTo(88), reason: name);
      }
    });

    const layouts = {
      'móvil pequeño 360×640': Size(360, 640),
      'horizontal 844×390': Size(844, 390),
      'tableta 800×1280': Size(800, 1280),
    };
    for (final MapEntry(key: name, value: size) in layouts.entries) {
      for (final scale in [1.0, 1.6]) {
        testWidgets('sin desbordes: $name, texto ×$scale', (tester) async {
          final h = Harness();
          await h.pump(tester, size: size, textScale: scale);
          await tester.tap(tile('ruck'));
          await tester.pump();
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
