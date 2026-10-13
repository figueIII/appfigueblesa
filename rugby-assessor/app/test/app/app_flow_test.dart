import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/app/app_services.dart';
import 'package:ref_assess/app/ref_assess_app.dart';
import 'package:ref_assess/core/platform_ports.dart';
import 'package:ref_assess/data/db/app_database.dart';
import 'package:ref_assess/data/drift_export_repository.dart';
import 'package:ref_assess/data/session_time.dart';
import 'package:ref_assess/domain/rubric_default.dart';
import 'package:ref_assess/export/report_exporter.dart';
import 'package:ref_assess/features/live/live_screen.dart';

import 'package:ref_assess/features/evaluation/evaluation_screen.dart';

import '../export/fixture.dart' show ExportFixture, SeqIds, exportSchema, testFonts;

class FakeMono implements MonotonicSource {
  int ms = 50000;
  @override
  int nowMs() => ms;
  @override
  String bootId() => 'boot-test';
}

class NoHaptics implements Haptics {
  @override
  void incidentLogged() {}
  @override
  void refined() {}
  @override
  void undone() {}
  @override
  void clockChanged() {}
  @override
  void warning() {}
}

class FakeScreenAwake implements ScreenAwake {
  bool on = false;
  @override
  Future<void> enable() async => on = true;
  @override
  Future<void> disable() async => on = false;
}

void main() {
  late AppDatabase db;
  late AppServices services;
  late FakeScreenAwake awake;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final ids = SeqIds('app');
    awake = FakeScreenAwake();
    services = AppServices(
      db: db,
      ids: ids,
      mono: FakeMono(),
      haptics: NoHaptics(),
      screenAwake: awake,
      wallNow: () => DateTime.utc(2026, 10, 17, 15),
      exporter: ReportExporter(
        repository: DriftExportRepository(db),
        rubric: kDefaultRubric,
        schema: exportSchema(),
        fonts: testFonts,
        exportsDirectory: () async => Directory.systemTemp.createTempSync('refassess_app_'),
        ids: ids,
      ),
    );
  });
  tearDown(() => db.close());

  /// La base de datos es real: se deja correr el bucle de eventos hasta que aparezca [f].
  Future<void> pumpUntil(WidgetTester tester, Finder f) async {
    for (var i = 0; i < 100 && f.evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(f, findsWidgets);
  }

  Future<void> enter(WidgetTester tester, String key, String text) async {
    final f = find.byKey(ValueKey(key));
    await tester.ensureVisible(f);
    await tester.enterText(f, text);
    await tester.pump();
  }

  testWidgets('inicio → nuevo partido → Comenzar partido → directo en ANTES DEL INICIO, 00:00 → inicio lo lista en curso', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(RefAssessApp(services: services, now: () => DateTime(2026, 10, 17, 16, 52)));
    await pumpUntil(tester, find.text('Aún no hay partidos'));

    await tester.tap(find.byKey(const ValueKey('new-match')));
    await tester.pumpAndSettle();
    expect(find.text('Nuevo partido'), findsOneWidget);

    final preset = find.byKey(const ValueKey('preset-M14'));
    await tester.ensureVisible(preset);
    await tester.tap(preset);
    await tester.pump();
    await enter(tester, 'home-team', 'Club Local RC');
    await enter(tester, 'away-team', 'Visitante RT');
    await enter(tester, 'referee', 'Ana Árbitro');
    await enter(tester, 'assessor', 'Evaluadora');
    await enter(tester, 'venue', 'Campo Municipal');
    await tester.tap(find.byKey(const ValueKey('start-match')));
    await pumpUntil(tester, find.byType(LiveScreen));
    await tester.pumpAndSettle();

    expect(find.text('ANTES DEL INICIO'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(awake.on, isTrue, reason: 'pantalla siempre encendida durante el directo');

    final row = await tester.runAsync(() => db.select(db.assessment).getSingle());
    expect(row!.status, 'READY');
    expect(row.categoryCode, 'M14');
    expect(row.homeTeam, 'Club Local RC');
    expect(row.kickoffLocal, '2026-10-17T16:55');
    final clockEvents = await tester.runAsync(() => db.select(db.clockEvent).get());
    expect(clockEvents, isEmpty, reason: 'el reloj no arranca solo: lo inicia el evaluador');

    // Atrás desde el directo (sin reloj en marcha) → inicio, no la preparación.
    await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
    await tester.pumpAndSettle();
    await pumpUntil(tester, find.text('En curso · 1'));
    expect(find.text('Nuevo partido'), findsOneWidget, reason: 'solo el botón: la preparación ya no está en la pila');
    expect(find.text('Sin empezar'), findsOneWidget);
    expect(awake.on, isFalse);

    // Continuar: vuelve al mismo partido, todavía a 00:00.
    await tester.tap(find.byKey(ValueKey('match-${row.id}')));
    await pumpUntil(tester, find.byType(LiveScreen));
    await tester.pumpAndSettle();
    expect(find.text('ANTES DEL INICIO'), findsOneWidget);
    expect(tester.widget<LiveScreen>(find.byType(LiveScreen)).controller.assessmentId, row.id);
  });

  testWidgets('informe finalizado: desde el inicio se abre el informe con la sección de exportación', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final f = (await tester.runAsync(ExportFixture.create))!;
    addTearDown(() => tester.runAsync(f.dispose));
    final closed = AppServices(
      db: f.db,
      ids: SeqIds('app'),
      mono: FakeMono(),
      haptics: NoHaptics(),
      screenAwake: awake,
      exporter: f.exporter(),
    );

    await tester.pumpWidget(RefAssessApp(services: closed));
    await pumpUntil(tester, find.text('Finalizados · 2'));
    await tester.tap(find.byKey(ValueKey('match-${f.secondId}')));
    await pumpUntil(tester, find.byType(EvaluationScreen));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tab-close')));
    await tester.pumpAndSettle();
    expect(find.text('Exportar y enviar al comité'), findsOneWidget);
    expect(find.byKey(const ValueKey('share-pdf')), findsOneWidget);
  });
}
