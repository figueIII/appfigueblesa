import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/core/design_system/theme.dart';
import 'package:ref_assess/data/match_repository.dart';
import 'package:ref_assess/features/setup/match_setup_screen.dart';

class FakeMatchRepository implements MatchRepository {
  FakeMatchRepository({this.referees = const [], this.assessors = const [], this.lastAssessor, this.fail = false});
  final List<String> referees;
  final List<String> assessors;
  final String? lastAssessor;
  final bool fail;
  final List<MatchSetupInput> created = [];

  @override
  Future<String> createMatch(MatchSetupInput input) async {
    if (fail) throw StateError('disco lleno');
    created.add(input);
    return 'match-${created.length}';
  }

  @override
  Future<List<MatchSummary>> listMatches() async => const [];
  @override
  Future<List<String>> knownRefereeNames() async => referees;
  @override
  Future<List<String>> knownAssessorNames() async => assessors;
  @override
  Future<String?> lastAssessorName() async => lastAssessor;
}

void main() {
  late FakeMatchRepository repo;
  late List<String> started;

  Future<void> pump(WidgetTester tester, {FakeMatchRepository? repository, double textScale = 1, Brightness brightness = Brightness.light}) async {
    repo = repository ?? FakeMatchRepository();
    started = [];
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildRefTheme(brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: MatchSetupScreen(
        repository: repo,
        onStart: started.add,
        now: () => DateTime(2026, 10, 17, 16, 52),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(ValueKey(key));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String key, String text) async {
    final f = find.byKey(ValueKey(key));
    await tester.ensureVisible(f);
    await tester.enterText(f, text);
    await tester.pumpAndSettle();
  }

  /// Tras crear, el botón queda con su indicador de progreso hasta que el directo sustituye a la
  /// pantalla: no hay "settle" posible.
  Future<void> submitOk(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('start-match')));
    await tester.pump();
    await tester.pump();
  }

  Future<void> fillRequired(WidgetTester tester) async {
    await tapKey(tester, 'preset-SM_DHCAT_1_2_3');
    await enter(tester, 'home-team', '  Club Local RC ');
    await enter(tester, 'away-team', 'Visitante RT');
    await enter(tester, 'referee', 'Ana Árbitro');
    await enter(tester, 'assessor', 'Evaluadora');
    await enter(tester, 'venue', 'Campo Municipal');
  }

  testWidgets('los 8 presets muestran duración de las partes y del sin-bin', (tester) async {
    await pump(tester);
    for (final hint in ['2 × 40 min · sin-bin 10 min', '2 × 35 min · sin-bin 10 min', '2 × 35 min · sin-bin 5 min', '2 × 30 min · sin-bin 5 min', '2 × 7 min · sin-bin 2 min']) {
      expect(find.text(hint), findsWidgets, reason: hint);
    }
    for (final code in ['SM_DHCAT_1_2_3', 'SM_3AB_4', 'SF_DHCAT_1', 'SF_ABC_2', 'M18', 'M16', 'M14', 'SEVENS']) {
      expect(find.byKey(ValueKey('preset-$code')), findsOneWidget, reason: code);
    }
  });

  testWidgets('hora por defecto: la actual redondeada a los 5 minutos siguientes (24 h)', (tester) async {
    await pump(tester);
    expect(find.text('17/10/2026'), findsOneWidget);
    expect(find.text('16:55'), findsOneWidget);
  });

  testWidgets('sin datos: no crea nada, marca cada campo obligatorio y cuenta los que faltan', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('start-match')));
    await tester.pumpAndSettle();
    expect(repo.created, isEmpty);
    expect(started, isEmpty);
    expect(find.text('Faltan 6 datos obligatorios.'), findsOneWidget, reason: 'la fecha y la hora ya vienen rellenas');
    expect(find.text('Elige la categoría del partido.'), findsOneWidget);
    expect(find.text('El árbitro principal es obligatorio.'), findsOneWidget);
    expect(find.text('Indica quién evalúa.'), findsOneWidget);

    // Al escribir, el error del campo desaparece y el contador baja.
    await enter(tester, 'referee', 'Ana Árbitro');
    expect(find.text('El árbitro principal es obligatorio.'), findsNothing);
    expect(find.text('Faltan 5 datos obligatorios.'), findsOneWidget);
  });

  testWidgets('el mismo equipo como local y visitante no se acepta', (tester) async {
    await pump(tester);
    await fillRequired(tester);
    await enter(tester, 'away-team', 'club local rc');
    await tester.tap(find.byKey(const ValueKey('start-match')));
    await tester.pumpAndSettle();
    expect(find.text('Local y visitante no pueden ser el mismo equipo.'), findsOneWidget);
    expect(repo.created, isEmpty);
  });

  testWidgets('Comenzar partido: crea el registro con el preset y los datos limpios, y abre el directo', (tester) async {
    await pump(tester);
    await fillRequired(tester);
    await enter(tester, 'ar1', 'Juez Uno');
    await enter(tester, 'competition', 'Liga DHCAT · J5');
    await tapKey(tester, 'difficulty-VERY_HIGH');
    await submitOk(tester);

    expect(started, ['match-1']);
    expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: 'sin doble alta mientras se abre el directo');
    expect(tester.widget<FilledButton>(find.byKey(const ValueKey('start-match'))).onPressed, isNull);
    final i = repo.created.single;
    expect(i.category.code, 'SM_DHCAT_1_2_3');
    expect(i.category.periodLengthMin, 40);
    expect(i.category.sinBinMin, 10);
    expect(i.homeTeam, 'Club Local RC');
    expect(i.awayTeam, 'Visitante RT');
    expect(i.refereeName, 'Ana Árbitro');
    expect(i.ar1Name, 'Juez Uno');
    expect(i.ar2Name, isNull);
    expect(i.assessorName, 'Evaluadora');
    expect(i.venue, 'Campo Municipal');
    expect(i.competition, 'Liga DHCAT · J5');
    expect(i.kickoffLocal, DateTime(2026, 10, 17, 16, 55));
    expect(i.difficulty, 'VERY_HIGH');
  });

  testWidgets('la dificultad es opcional y se desmarca al volver a pulsarla', (tester) async {
    await pump(tester);
    await fillRequired(tester);
    await tapKey(tester, 'difficulty-HIGH');
    await tapKey(tester, 'difficulty-HIGH');
    await submitOk(tester);
    expect(repo.created.single.difficulty, isNull);
  });

  testWidgets('evaluador: se rellena con el del último partido; árbitro: sugiere nombres ya usados', (tester) async {
    await pump(tester, repository: FakeMatchRepository(referees: ['Ana Árbitro', 'Bruno Bermejo'], lastAssessor: 'Evaluadora'));
    expect(find.text('Evaluadora'), findsOneWidget);

    await enter(tester, 'referee', 'ana');
    expect(find.byKey(const ValueKey('suggestion-Ana Árbitro')), findsOneWidget);
    expect(find.byKey(const ValueKey('suggestion-Bruno Bermejo')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('suggestion-Ana Árbitro')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const ValueKey('referee'))).controller!.text, 'Ana Árbitro');
  });

  testWidgets('cambiar la hora con el selector (formato 24 h)', (tester) async {
    await pump(tester);
    await tapKey(tester, 'pick-time');
    expect(find.text('Hora del saque inicial'), findsWidgets);
    // Modo de entrada por teclado del selector.
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(fields.evaluate().length - 2), '18');
    await tester.enterText(fields.last, '30');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('18:30'), findsOneWidget);
  });

  testWidgets('si falla el guardado: aviso y el botón vuelve a estar disponible', (tester) async {
    await pump(tester, repository: FakeMatchRepository(fail: true));
    await fillRequired(tester);
    await tester.tap(find.byKey(const ValueKey('start-match')));
    await tester.pumpAndSettle();
    expect(started, isEmpty);
    expect(find.text('No se ha podido crear el partido. Vuelve a intentarlo.'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const ValueKey('start-match'))).onPressed, isNotNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets('accesibilidad (${brightness.name}): objetivos táctiles, etiquetas y contraste', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, brightness: brightness);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  }

  testWidgets('texto ×1.6: el formulario se recorre entero sin desbordes', (tester) async {
    await pump(tester, textScale: 1.6);
    await fillRequired(tester);
    await tapKey(tester, 'difficulty-LOW');
    await submitOk(tester);
    expect(tester.takeException(), isNull);
    expect(started, ['match-1']);
  });
}
