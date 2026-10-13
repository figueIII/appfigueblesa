// Genera capturas de referencia de la pantalla 1 con fuentes reales (Roboto + Material Icons).
// Uso: flutter test test/screenshots --update-goldens  →  test/screenshots/goldens/*.png
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/live/live_screen_test.dart' show Harness, tile;

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
}
