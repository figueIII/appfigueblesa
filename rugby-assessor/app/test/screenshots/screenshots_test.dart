// Genera capturas de referencia de la pantalla 1 con fuentes reales (Roboto + Material Icons).
// Uso: flutter test test/screenshots --update-goldens  →  test/screenshots/goldens/*.png
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/domain/model.dart';
import 'package:ref_assess/domain/rubric.dart';

import '../features/live/live_screen_test.dart' show Harness, tile;
import '../features/review/review_screen_test.dart' as review;
import '../features/evaluation/evaluation_screen_test.dart' as evaluation;
import '../export/fixture.dart' as exportfx;
import '../export/export_ui_test.dart' show FakeSharer;
import '../features/home/home_screen_test.dart' show ListRepository, summary;
import '../features/setup/match_setup_screen_test.dart' show FakeMatchRepository;
import 'package:ref_assess/features/home/home_screen.dart';
import 'package:ref_assess/features/setup/match_setup_screen.dart';
import 'package:ref_assess/core/design_system/theme.dart';
import 'package:ref_assess/data/drift_evaluation_repository.dart';
import 'package:ref_assess/domain/rubric_default.dart';
import 'package:ref_assess/features/evaluation/evaluation_controller.dart';
import 'package:ref_assess/features/evaluation/evaluation_screen.dart';
import 'package:ref_assess/features/evaluation/export_controller.dart';

const min = 60000;

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'] ?? '/home/user/sdk/flutter';
  final dir = '$root/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final w in ['Regular', 'Medium', 'Bold', 'Black']) {
    roboto.addFont(Future.value(ByteData.sublistView(File('$dir/Roboto-$w.ttf').readAsBytesSync())));
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(File('$dir/MaterialIcons-Regular.otf').readAsBytesSync())));
  await icons.load();
}

void main() {
  setUpAll(_loadFonts);

  for (final b in Brightness.values) {
    testWidgets('previa (${b.name})', (tester) async {
      final h = Harness();
      await h.pump(tester, brightness: b);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/01_previa_${b.name}.png'));
    });

    testWidgets('marca recién hecha (${b.name})', (tester) async {
      final h = Harness();
      await h.pump(tester, brightness: b);
      await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
      await h.advance(tester, 23 * min + 41000);
      for (final t in ['tackle', 'ruck', 'ruck', 'scrum']) {
        await tester.tap(tile(t));
        await h.advance(tester, 20000);
      }
      await tester.tap(tile('offside'));
      await h.advance(tester, 2500);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/02_marca_${b.name}.png'));
    });

    testWidgets('tiempo cumplido y tiempo parado (${b.name})', (tester) async {
      final h = Harness();
      await h.pump(tester, brightness: b);
      await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
      await h.advance(tester, 41 * min + 7000);
      await tester.pump(const Duration(seconds: 1));
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/03_tiempo_cumplido_${b.name}.png'));
      await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
      await h.advance(tester, 15000);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/04_tiempo_parado_${b.name}.png'));
    });
  }

  testWidgets('menú del reloj (light)', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
    await h.advance(tester, 40 * min + 30000);
    await tester.tap(find.byKey(const ValueKey('clock-menu')));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/05_menu_reloj_light.png'));
  });

  testWidgets('hoja Más (light)', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
    await h.advance(tester, 64 * min);
    await tester.tap(tile('more'));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/06_mas_light.png'));
  });

  testWidgets('horizontal (light)', (tester) async {
    final h = Harness();
    await h.pump(tester, size: const Size(844, 390));
    await tester.tap(find.byKey(const ValueKey('primary-clock-action')));
    await h.advance(tester, 12 * min);
    await tester.tap(tile('ruck'));
    await h.advance(tester, 1000);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/07_horizontal_light.png'));
  });

  for (final b in Brightness.values) {
    testWidgets('revisión: cola (${b.name})', (tester) async {
      final h = review.Harness();
      await h.pump(tester, brightness: b);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/10_revision_cola_${b.name}.png'));
    });
  }

  testWidgets('revisión: editor con error a medio completar (light)', (tester) async {
    final h = review.Harness();
    await h.pump(tester);
    await tester.tap(review.card('scrum'));
    await tester.pumpAndSettle();
    await review.tapVisible(tester, find.byKey(const ValueKey('verdict-incorrect')));
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, 600));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/11_revision_editor_light.png'));
    await review.tapVisible(tester, find.byKey(const ValueKey('expected-penalty')));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/12_revision_editor_decision_light.png'));
  });

  testWidgets('revisión: completa (light)', (tester) async {
    final h = review.Harness([review.seedIncident('a', 1, 5 * min, IncidentCategory.ruck, verdict: Verdict.correct)]);
    await h.pump(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/13_revision_completa_light.png'));
  });

  for (final b in Brightness.values) {
    testWidgets('evaluación: área A con tope y banda contraria a la sugerencia (${b.name})', (tester) async {
      final h = evaluation.Harness();
      await h.pump(tester, brightness: b);
      await evaluation.tapVisible(tester, find.byKey(const ValueKey('band-A1_SCRUM-above')));
      await tester.enterText(find.byKey(const ValueKey('justification-A1_SCRUM')), 'Visto en vídeo.');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('suggested-A1_SCRUM')));
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/20_evaluacion_area_${b.name}.png'));
    });
  }

  testWidgets('evaluación: cierre con pendientes (light)', (tester) async {
    final h = evaluation.Harness();
    await h.pump(tester);
    for (final c in evaluation.rubric.criteria.take(9)) {
      h.controller.setBand(c.code, h.controller.suggestions[c.code]!.suggestedBand ?? BandCode.at);
    }
    await tester.pumpAndSettle();
    await evaluation.openTab(tester, 'close');
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/21_evaluacion_cierre_light.png'));
  });

  testWidgets('evaluación: informe cerrado (light)', (tester) async {
    final h = evaluation.Harness();
    await h.pump(tester);
    h.completeAll();
    await tester.pumpAndSettle();
    await evaluation.openTab(tester, 'close');
    await h.controller.finalize();
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/22_evaluacion_cerrado_light.png'));
  });

  testWidgets('exportación del informe cerrado (light)', (tester) async {
    late exportfx.ExportFixture f;
    late EvaluationController c;
    await tester.runAsync(() async {
      f = await exportfx.ExportFixture.create();
      c = EvaluationController(assessmentId: f.firstId, repository: DriftEvaluationRepository(f.db), rubric: kDefaultRubric, ids: exportfx.SeqIds('s'));
      await c.load();
    });
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildRefTheme(Brightness.light),
      home: EvaluationScreen(
        controller: c,
        onOpenReview: () {},
        createExport: (h, a) => ExportController(assessmentId: f.firstId, exporter: f.exporter(), sharer: FakeSharer(), homeTeam: h, awayTeam: a),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tab-close')));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/23_exportacion_light.png'));
    await tester.runAsync(() => f.dispose());
  });

  Future<void> phone(WidgetTester tester, Brightness b, Widget home) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(debugShowCheckedModeBanner: false, theme: buildRefTheme(b), home: home));
    await tester.pumpAndSettle();
  }

  for (final b in Brightness.values) {
    testWidgets('inicio: lista de partidos (${b.name})', (tester) async {
      await phone(
        tester,
        b,
        HomeScreen(
          repository: ListRepository([
            summary('live', 'LIVE', marks: 7),
            summary('review', 'POST_MATCH', marks: 14, home: 'CR Sant Cugat'),
            summary('done', 'FINALIZED', marks: 12, band: BandCode.at, home: 'UE Santboiana'),
          ]),
          rubric: kDefaultRubric,
          onNewMatch: () async {},
          onOpenMatch: (_) async {},
        ),
      );
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/30_inicio_${b.name}.png'));
    });

    testWidgets('preparación del partido (${b.name})', (tester) async {
      await phone(
        tester,
        b,
        MatchSetupScreen(
          repository: FakeMatchRepository(lastAssessor: 'Evaluadora Ejemplo'),
          onStart: (_) {},
          now: () => DateTime(2026, 10, 17, 16, 52),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('preset-SM_DHCAT_1_2_3')));
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/31_preparacion_${b.name}.png'));
    });
  }

  testWidgets('preparación: errores al comenzar con datos incompletos (light)', (tester) async {
    await phone(tester, Brightness.light, MatchSetupScreen(repository: FakeMatchRepository(), onStart: (_) {}, now: () => DateTime(2026, 10, 17, 16, 52)));
    await tester.tap(find.byKey(const ValueKey('start-match')));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/32_preparacion_errores_light.png'));
  });

  testWidgets('inicio vacío (light)', (tester) async {
    await phone(
      tester,
      Brightness.light,
      HomeScreen(repository: ListRepository(const []), rubric: kDefaultRubric, onNewMatch: () async {}, onOpenMatch: (_) async {}),
    );
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/33_inicio_vacio_light.png'));
  });
}
