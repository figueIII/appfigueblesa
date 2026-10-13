import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/core/design_system/theme.dart';
import 'package:ref_assess/data/match_repository.dart';
import 'package:ref_assess/domain/rubric.dart';
import 'package:ref_assess/domain/rubric_default.dart';
import 'package:ref_assess/features/home/home_screen.dart';

import '../setup/match_setup_screen_test.dart' show FakeMatchRepository;

MatchSummary summary(String id, String status, {int marks = 0, BandCode? band, String home = 'Club Local RC'}) => MatchSummary(
      id: id,
      status: status,
      homeTeam: home,
      awayTeam: 'Visitante RT',
      competition: 'Liga',
      categoryName: 'M16',
      kickoffLocal: '2026-10-17T17:00',
      venue: 'Campo Municipal',
      refereeName: 'Ana Árbitro',
      markCount: marks,
      band: band,
    );

class ListRepository extends FakeMatchRepository {
  ListRepository(this.matches);
  List<MatchSummary> matches;
  int loads = 0;
  @override
  Future<List<MatchSummary>> listMatches() async {
    loads++;
    return matches;
  }
}

void main() {
  late ListRepository repo;
  late List<String> opened;
  late int newMatches;

  Future<void> pump(WidgetTester tester, List<MatchSummary> matches, {double textScale = 1, Brightness brightness = Brightness.light, double height = 844}) async {
    repo = ListRepository(matches);
    opened = [];
    newMatches = 0;
    tester.view.physicalSize = Size(390, height) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildRefTheme(brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: HomeScreen(
        repository: repo,
        rubric: kDefaultRubric,
        onNewMatch: () async => newMatches++,
        onOpenMatch: (m) async => opened.add(m.id),
      ),
    ));
    await tester.pumpAndSettle();
  }

  final mixed = [
    summary('live', 'LIVE', marks: 7),
    summary('ready', 'READY', home: 'Otro Local'),
    summary('review', 'POST_MATCH', marks: 1),
    summary('done', 'FINALIZED', marks: 12, band: BandCode.above),
  ];

  testWidgets('sin partidos: estado vacío y "Nuevo partido" siempre visible', (tester) async {
    await pump(tester, const []);
    expect(find.byKey(const ValueKey('home-empty')), findsOneWidget);
    expect(find.text('Aún no hay partidos'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('new-match')));
    await tester.pumpAndSettle();
    expect(newMatches, 1);
    expect(repo.loads, 2, reason: 'al volver de la preparación la lista se recarga');
  });

  testWidgets('agrupa por lo que queda por hacer: en curso, pendientes de revisión y finalizados', (tester) async {
    // Pantalla alta: la lista es perezosa y aquí interesa verla entera.
    await pump(tester, mixed, height: 2000);
    expect(find.text('En curso · 2'), findsOneWidget);
    expect(find.text('Pendientes de revisión · 1'), findsOneWidget);
    expect(find.text('Finalizados · 1'), findsOneWidget);
    final y = [
      for (final k in ['section-inProgress', 'section-pendingReview', 'section-finalized']) tester.getTopLeft(find.byKey(ValueKey(k))).dy,
    ];
    expect(y, orderedEquals([...y]..sort()));

    expect(find.text('En directo · 7 marcas'), findsOneWidget);
    expect(find.text('Sin empezar'), findsOneWidget);
    expect(find.text('Terminado · 1 marca'), findsOneWidget);
    expect(find.text('Por encima del nivel'), findsOneWidget, reason: 'banda del informe cerrado, sin cifras');
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Empezar'), findsOneWidget);
    expect(find.text('Revisar'), findsOneWidget);
    expect(find.text('Ver y exportar'), findsOneWidget);
    expect(find.text('17/10/2026 · 17:00 · M16'), findsNWidgets(4));
  });

  testWidgets('al tocar un partido se abre y, al volver, la lista se recarga', (tester) async {
    await pump(tester, mixed);
    final review = find.byKey(const ValueKey('match-review'));
    await tester.ensureVisible(review);
    await tester.pumpAndSettle();
    await tester.tap(review);
    await tester.pumpAndSettle();
    final done = find.byKey(const ValueKey('match-done'));
    await tester.scrollUntilVisible(done, 200, scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(done);
    await tester.pumpAndSettle();
    await tester.tap(done);
    await tester.pumpAndSettle();
    expect(opened, ['review', 'done']);
    expect(repo.loads, 3);
  });

  testWidgets('las secciones vacías no se muestran', (tester) async {
    await pump(tester, [summary('done', 'FINALIZED', band: BandCode.below)]);
    expect(find.text('Finalizados · 1'), findsOneWidget);
    expect(find.textContaining('En curso'), findsNothing);
    expect(find.textContaining('Pendientes'), findsNothing);
    expect(find.text('Por debajo del nivel'), findsOneWidget);
  });

  test('formatKickoff', () {
    expect(formatKickoff('2026-10-17T09:05'), '17/10/2026 · 09:05');
    expect(formatKickoff('raro'), 'raro');
  });

  for (final brightness in Brightness.values) {
    testWidgets('accesibilidad (${brightness.name}): objetivos táctiles, etiquetas y contraste', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, mixed, brightness: brightness);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  }

  testWidgets('texto ×1.6: tarjetas sin desbordes', (tester) async {
    await pump(tester, mixed, textScale: 1.6);
    expect(tester.takeException(), isNull);
  });
}
