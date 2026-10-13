import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/core/design_system/theme.dart';
import 'package:ref_assess/core/platform_ports.dart';
import 'package:ref_assess/data/evaluation_repository.dart';
import 'package:ref_assess/domain/model.dart';
import 'package:ref_assess/domain/report.dart';
import 'package:ref_assess/domain/rubric.dart';
import 'package:ref_assess/domain/rubric_default.dart';
import 'package:ref_assess/features/evaluation/evaluation_controller.dart';
import 'package:ref_assess/features/evaluation/evaluation_screen.dart';

const min = 60000;
final rubric = kDefaultRubric;

Incident seed(String id, int t, IncidentCategory c, Verdict v, ImpactLevel impact, {String? notes}) => Incident(
      id: id,
      assessmentId: 'a1',
      seq: t ~/ 1000,
      sessionMs: t,
      wallUtc: DateTime.utc(2026, 10, 17, 15),
      matchTime: MatchTimeStamp(period: PeriodId.h1, phase: MatchPhaseLabel.inPlay, periodElapsedMs: t, matchClockMs: t, overtimeMs: 0, integrity: TimeIntegrity.ok),
      category: c,
      criterionCode: kCategoryToCriterion[c]!,
      polarity: QuickPolarity.review,
      verdict: v,
      impact: impact,
      impactConfirmed: true,
      status: IncidentStatus.enriched,
      notes: notes ?? 'nota',
      decisionExpected: const Decision(outcomes: [DecisionOutcome.penalty]),
    );

final defaultIncidents = [
  seed('scrum', 30 * min, IncidentCategory.scrum, Verdict.missed, ImpactLevel.matchDefining), // A1: tope
  seed('tackle', 12 * min, IncidentCategory.tackle, Verdict.correct, ImpactLevel.medium), // A3: En el nivel
  seed('ko1', 20 * min, IncidentCategory.knockOnForwardPass, Verdict.incorrect, ImpactLevel.high), // C1: dos HIGH
  seed('ko2', 50 * min, IncidentCategory.otherLaw, Verdict.incorrect, ImpactLevel.high),
  seed('adv', 55 * min, IncidentCategory.advantage, Verdict.correct, ImpactLevel.low), // B4: En el nivel
];

class SeqIds implements IdGenerator {
  int n = 0;
  @override
  String next() => 'id-${++n}';
}

class Harness {
  Harness({List<Incident>? incidents, List<PreviousActionPoint> previous = const []})
      : repo = InMemoryEvaluationRepository(EvaluationSnapshot(
          assessmentId: 'a1',
          refereeName: 'Árbitro Ejemplo',
          homeTeam: 'Local',
          awayTeam: 'Visitante',
          incidents: incidents ?? defaultIncidents,
          evaluations: const {},
          summary: '',
          findings: const [],
          actionPoints: const [],
          openPrevious: previous,
          previousReviews: const {},
        ));

  final InMemoryEvaluationRepository repo;
  int openedReview = 0;
  late final controller = EvaluationController(
    assessmentId: 'a1',
    repository: repo,
    rubric: rubric,
    ids: SeqIds(),
    now: () => DateTime.utc(2026, 10, 18, 9, 12),
    textDebounce: const Duration(milliseconds: 100),
  );

  Future<void> pump(WidgetTester tester, {Size size = const Size(390, 844), double textScale = 1, Brightness brightness = Brightness.light}) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildRefTheme(brightness),
      home: MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
        child: EvaluationScreen(controller: controller, onOpenReview: () => openedReview++),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// Rellena todo por el controlador (para probar el cierre sin repetir 14 tarjetas).
  void completeAll({String justification = 'Acorde a lo observado.'}) {
    for (final c in rubric.criteria) {
      final s = controller.suggestions[c.code]!;
      controller.setBand(c.code, s.suggestedBand ?? BandCode.at);
      controller.setJustification(c.code, justification);
    }
    controller.setSummary('Partido exigente bien gestionado; el reglamento en reinicios es la prioridad.');
    final st = controller.addFinding(FindingKind.strength)!;
    controller.updateFinding(st.id, text: 'Ventaja bien leída.');
    final dv = controller.addFinding(FindingKind.development)!;
    controller.updateFinding(dv.id, text: 'Opciones tras un saque de centro incorrecto.');
    final ap = controller.addActionPoint()!;
    controller.updateActionPoint(ap.id, text: 'Repasar la ley 12.', successIndicator: 'Reinicios resueltos con las opciones correctas.');
  }
}

Future<void> tapVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> openTab(WidgetTester tester, String letter) async {
  await tester.tap(find.byKey(ValueKey('tab-$letter')));
  await tester.pumpAndSettle();
}

/// Ninguna cifra decimal, porcentaje ni "x/10" en pantalla: la evaluación es solo por bandas.
void expectNoScores(WidgetTester tester) {
  final texts = <String>[
    for (final w in tester.widgetList<Text>(find.byType(Text))) w.data ?? w.textSpan?.toPlainText() ?? '',
    for (final w in tester.widgetList<RichText>(find.byType(RichText))) w.text.toPlainText(),
  ];
  for (final t in texts) {
    expect(t, isNot(matches(RegExp(r'\d+[.,]\d+'))), reason: 'cifra decimal visible: "$t"');
    expect(t, isNot(contains('%')), reason: 'porcentaje visible: "$t"');
    // "x/10" aislado (una fecha como 18/10/2026 no cuenta).
    expect(t, isNot(matches(RegExp(r'(?<![\d/])\d+\s*/\s*10(?![\d/])'))), reason: 'nota sobre 10 visible: "$t"');
  }
}

void main() {
  testWidgets('área A: sugerencias en bandas, tope visible en A1 y ninguna puntuación en pantalla', (tester) async {
    final h = Harness();
    await h.pump(tester);
    expect(find.text('A · Gestión de fases de juego'), findsOneWidget);
    expect(find.byKey(const ValueKey('suggested-A1_SCRUM')), findsOneWidget);
    expect(
      find.descendant(of: find.byKey(const ValueKey('suggested-A1_SCRUM')), matching: find.text('Por debajo del nivel')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('cap-A1_SCRUM')), findsOneWidget);
    expect(find.textContaining('Scrum 30:00 · no pitada · decisivo'), findsOneWidget, reason: 'la marca que provoca el tope');
    expect(
      find.descendant(of: find.byKey(const ValueKey('suggested-A3_TACKLE_RUCK')), matching: find.text('En el nivel')),
      findsOneWidget,
    );
    expect(find.textContaining('sin marcas valoradas'), findsNWidgets(2), reason: 'A2 y A4 sin evidencia');
    expectNoScores(tester);
    for (final l in ['B', 'C', 'D', 'close']) {
      await openTab(tester, l);
      expectNoScores(tester);
    }
  });

  testWidgets('dos errores HIGH en C1 fuerzan la sugerencia "Por debajo" con tope', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await openTab(tester, 'C');
    expect(
      find.descendant(of: find.byKey(const ValueKey('suggested-C1_LAW_ACCURACY')), matching: find.text('Por debajo del nivel')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('cap-C1_LAW_ACCURACY')), findsOneWidget);
  });

  testWidgets('seguir la sugerencia: basta una justificación breve', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tapVisible(tester, find.byKey(const ValueKey('band-A3_TACKLE_RUCK-at')));
    expect(h.controller.issuesFor('A3_TACKLE_RUCK').single.code, CloseIssueCode.criterionJustificationRequired);
    await tester.enterText(find.byKey(const ValueKey('justification-A3_TACKLE_RUCK')), 'Buen breakdown.');
    await tester.pumpAndSettle();
    expect(h.controller.isComplete('A3_TACKLE_RUCK'), isTrue);
    expect(find.text('Criterio completo'), findsOneWidget);
  });

  testWidgets('contradecir la sugerencia o superar el tope exige 40 caracteres antes de validar', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tapVisible(tester, find.byKey(const ValueKey('band-A1_SCRUM-above')));
    final field = find.byKey(const ValueKey('justification-A1_SCRUM'));
    await tester.ensureVisible(field);
    await tester.enterText(field, 'Visto en vídeo.');
    await tester.pumpAndSettle();
    expect(h.controller.issuesFor('A1_SCRUM').single.code, CloseIssueCode.capOverrideJustificationTooShort);
    expect(find.textContaining('faltan 25 caracteres'), findsOneWidget);
    expect(find.textContaining('justifica por qué superas el tope'), findsOneWidget);

    await tester.enterText(field, 'Visto en vídeo: el colapso lo provocó el pilar local.');
    await tester.pumpAndSettle();
    expect(h.controller.isComplete('A1_SCRUM'), isTrue);
    expect(find.text('Justificación suficiente.'), findsOneWidget);

    // Volver a la banda sugerida ya no exige el mínimo largo.
    await tapVisible(tester, find.byKey(const ValueKey('band-A1_SCRUM-below')));
    expect(find.text('Qué viste para valorarlo así.'), findsWidgets);
  });

  testWidgets('"No se observó": sin banda, sigue pidiendo justificación', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tapVisible(tester, find.byKey(const ValueKey('not-observed-A2_LINEOUT_MAUL')));
    expect(h.controller.evaluationOf('A2_LINEOUT_MAUL')!.notObserved, isTrue);
    expect(h.controller.issuesFor('A2_LINEOUT_MAUL').single.code, CloseIssueCode.criterionJustificationRequired);
    await tester.enterText(find.byKey(const ValueKey('justification-A2_LINEOUT_MAUL')), 'Sin touchs disputadas.');
    await tester.pumpAndSettle();
    expect(h.controller.isComplete('A2_LINEOUT_MAUL'), isTrue);
  });

  testWidgets('la banda del área y la global se recalculan al elegir', (tester) async {
    final h = Harness();
    await h.pump(tester);
    expect(find.descendant(of: find.byKey(const ValueKey('area-band-PHASES')), matching: find.text('Sin banda todavía')), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('band-A1_SCRUM-below')));
    await tester.ensureVisible(find.byKey(const ValueKey('area-band-PHASES')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('area-band-PHASES')), matching: find.text('Por debajo del nivel')), findsOneWidget);
    await openTab(tester, 'close');
    expect(find.descendant(of: find.byKey(const ValueKey('global-band')), matching: find.text('Por debajo del nivel')), findsOneWidget);
    expect(find.text('Provisional: hay criterios sin completar.'), findsOneWidget);
  });

  testWidgets('la justificación se guarda sola (sin botón) tras dejar de escribir', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tapVisible(tester, find.byKey(const ValueKey('band-A3_TACKLE_RUCK-at')));
    await tester.enterText(find.byKey(const ValueKey('justification-A3_TACKLE_RUCK')), 'Buen breakdown.');
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(h.repo.evaluations['A3_TACKLE_RUCK']!.justification, 'Buen breakdown.');
    expect(h.repo.evaluations['A3_TACKLE_RUCK']!.finalBand, BandCode.at);
  });

  testWidgets('cierre bloqueado hasta completar; cada pendiente lleva a su sitio', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await openTab(tester, 'close');
    final close = find.byKey(const ValueKey('close-report'));
    await tester.ensureVisible(close);
    await tester.pumpAndSettle();
    expect(tester.widget<ButtonStyleButton>(close).onPressed, isNull);
    expect(find.text('Se activará cuando no quede nada pendiente.'), findsOneWidget);

    final issue = find.byKey(const ValueKey('issue-criterionBandMissing-C2_FOUL_PLAY'));
    await tester.ensureVisible(issue);
    await tester.pumpAndSettle();
    await tester.tap(issue);
    await tester.pumpAndSettle();
    expect(find.text('C · Aplicación de leyes y consistencia disciplinaria'), findsOneWidget);
    expect(find.byKey(const ValueKey('band-C2_FOUL_PLAY-at')).hitTestable(), findsOneWidget, reason: 'desplazado hasta la tarjeta');
  });

  testWidgets('las marcas sin revisar bloquean el cierre y llevan a la revisión', (tester) async {
    final h = Harness(incidents: [...defaultIncidents, seed('p', 70 * min, IncidentCategory.ruck, Verdict.pending, ImpactLevel.medium)]);
    await h.pump(tester);
    h.completeAll();
    await tester.pumpAndSettle();
    await openTab(tester, 'close');
    final issue = find.text('Quedan marcas por revisar (ir a la revisión)');
    await tester.ensureVisible(issue);
    await tester.tap(issue);
    expect(h.openedReview, 1);
  });

  testWidgets('cierre completo: confirmación, hash, informe bloqueado y sin puntuaciones', (tester) async {
    final h = Harness();
    await h.pump(tester);
    h.completeAll();
    await tester.pumpAndSettle();
    await openTab(tester, 'close');
    expect(find.text('Todo listo para cerrar.'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('close-report')));
    await tester.tap(find.byKey(const ValueKey('confirm-close')));
    await tester.pumpAndSettle();

    final data = h.repo.finalizedWith!;
    expect(data.contentHash, contentHash(data.signedReport));
    expect(data.signedReport['band'], isNotNull);
    expect(data.signedReport.containsKey('status'), isFalse, reason: 'el hash no cubre el estado');
    expect((data.signedReport['criterionScores'] as List).length, 14);
    expect(h.controller.isFinalized, isTrue);
    await tester.ensureVisible(find.byKey(const ValueKey('finalized-banner')));
    await tester.pumpAndSettle();
    expect(find.textContaining('huella ${data.contentHash.substring(0, 12)}'), findsOneWidget);
    expect(find.byKey(const ValueKey('close-report')), findsNothing);
    expectNoScores(tester);

    await openTab(tester, 'A');
    final tf = tester.widget<TextField>(find.byKey(const ValueKey('justification-A1_SCRUM')));
    expect(tf.enabled, isFalse, reason: 'informe cerrado: solo lectura');
    h.controller.setBand('A1_SCRUM', BandCode.above);
    expect(h.controller.evaluationOf('A1_SCRUM')!.finalBand, BandCode.below, reason: 'el controlador ignora cambios tras el cierre');
  });

  testWidgets('recomendaciones del informe anterior: hay que revisarlas para cerrar', (tester) async {
    final h = Harness(previous: const [
      PreviousActionPoint(id: 'prev1', criterionCode: 'D2_POSITIONING', text: 'Ver el ruck desde el lado defensor', successIndicator: '80 % de rucks'),
    ]);
    await h.pump(tester);
    h.completeAll();
    await tester.pumpAndSettle();
    await openTab(tester, 'close');
    expect(h.controller.closeIssues.single.code, CloseIssueCode.previousActionPointNotReviewed);
    await tapVisible(tester, find.byKey(const ValueKey('prev-prev1-achieved')));
    expect(h.controller.closeIssues, isEmpty);
  });

  group('accesibilidad y ergonomía', () {
    for (final b in Brightness.values) {
      testWidgets('objetivos, etiquetas y contraste (${b.name})', (tester) async {
        final handle = tester.ensureSemantics();
        final h = Harness();
        await h.pump(tester, brightness: b);
        await tapVisible(tester, find.byKey(const ValueKey('band-A1_SCRUM-above')));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await openTab(tester, 'close');
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }

    for (final (name, size) in [('360×640', const Size(360, 640)), ('horizontal 844×390', const Size(844, 390))]) {
      testWidgets('sin desbordes con texto ×1,6: $name', (tester) async {
        final h = Harness();
        await h.pump(tester, size: size, textScale: 1.6);
        await tapVisible(tester, find.byKey(const ValueKey('band-A1_SCRUM-above')));
        expect(tester.takeException(), isNull);
        await openTab(tester, 'close');
        expect(tester.takeException(), isNull);
      });
    }
  });
}
