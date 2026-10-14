import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/core/design_system/theme.dart';
import 'package:ref_assess/core/i18n.dart';
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
  seed('scrum', 30 * min, IncidentCategory.scrum, Verdict.missed, ImpactLevel.matchDefining), // D2: U con tope
  seed('tackle', 12 * min, IncidentCategory.tackle, Verdict.correct, ImpactLevel.medium), // E2: C
  seed('ko1', 20 * min, IncidentCategory.knockOnForwardPass, Verdict.incorrect, ImpactLevel.high), // C2: dos HIGH
  seed('ko2', 50 * min, IncidentCategory.otherLaw, Verdict.incorrect, ImpactLevel.high),
  seed('adv', 55 * min, IncidentCategory.advantage, Verdict.correct, ImpactLevel.low), // C3: C
];

class SeqIds implements IdGenerator {
  int n = 0;
  @override
  String next() => 'id-${++n}';
}

class Harness {
  Harness({List<Incident>? incidents, List<PreviousActionPoint> previous = const [], this.onFinalized})
      : repo = InMemoryEvaluationRepository(EvaluationSnapshot(
          assessmentId: 'a1',
          refereeName: 'Árbitro Ejemplo',
          homeTeam: 'Local',
          awayTeam: 'Visitante',
          incidents: incidents ?? defaultIncidents,
          estimatedDifficulty: 'HIGH',
          evaluations: const {},
          summary: '',
          findings: const [],
          actionPoints: const [],
          openPrevious: previous,
          previousReviews: const {},
        ));

  final InMemoryEvaluationRepository repo;
  final VoidCallback? onFinalized;
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
        child: EvaluationScreen(controller: controller, onOpenReview: () => openedReview++, onFinalized: onFinalized),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// Valora todo por el controlador (para probar el cierre sin repetir 25 tarjetas).
  void completeAll() {
    for (final c in rubric.criteria) {
      final s = controller.suggestions[c.code]!;
      controller.setBand(c.code, s.suggestedBand ?? BandCode.competent);
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
  tearDown(() => appLanguage.value = AppLanguage.es);

  testWidgets('seis áreas A–F; sugerencias E/C/N/U con tope visible y ninguna puntuación en pantalla', (tester) async {
    final h = Harness();
    await h.pump(tester);
    expect(find.text('A · Colocación'), findsOneWidget);
    expect(find.textContaining('sin marcas valoradas'), findsNWidgets(6), reason: 'colocación: sin marcas');
    expect(find.byKey(const ValueKey('level-A1_STATIC_START')), findsOneWidget);
    expect(find.text('A1 · El punto de partida en las fases estáticas es adecuado para seguir el juego'), findsOneWidget);
    expectNoScores(tester);
    await openTab(tester, 'D');
    expect(find.text('D · Fases estáticas'), findsOneWidget);
    expect(
      find.descendant(of: find.byKey(const ValueKey('suggested-D2_SCRUM_SEQUENCE_SAFETY')), matching: find.text('U · Revisión urgente')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('cap-D2_SCRUM_SEQUENCE_SAFETY')), findsOneWidget);
    expect(find.textContaining('Scrum 30:00 · no pitada · decisivo'), findsOneWidget, reason: 'la marca que provoca el tope');
    await openTab(tester, 'E');
    expect(
      find.descendant(of: find.byKey(const ValueKey('suggested-E2_TACKLER_TACKLED')), matching: find.text('C · Competente')),
      findsOneWidget,
    );
    for (final l in ['B', 'C', 'D', 'E', 'F', 'close']) {
      await openTab(tester, l);
      expectNoScores(tester);
    }
  });

  testWidgets('dos errores HIGH en C2 fuerzan la sugerencia U con tope', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await openTab(tester, 'C');
    expect(
      find.descendant(of: find.byKey(const ValueKey('suggested-C2_MATERIAL_EFFECT')), matching: find.text('U · Revisión urgente')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('cap-C2_MATERIAL_EFFECT')), findsOneWidget);
  });

  testWidgets('valorar no exige justificación; tocar otra vez la banda la quita', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await openTab(tester, 'E');
    final band = find.byKey(const ValueKey('band-E2_TACKLER_TACKLED-competent'));
    await tapVisible(tester, band);
    expect(h.controller.evaluationOf('E2_TACKLER_TACKLED')!.finalBand, BandCode.competent);
    expect(h.controller.isComplete('E2_TACKLER_TACKLED'), isTrue, reason: 'sin justificación');
    expect(find.text('Justificación · opcional'), findsWidgets);
    await tapVisible(tester, band);
    expect(h.controller.evaluationOf('E2_TACKLER_TACKLED')!.finalBand, isNull);
    expect(h.controller.isComplete('E2_TACKLER_TACKLED'), isFalse);
  });

  testWidgets('contradecir la sugerencia o superar el tope solo aconseja justificar', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await openTab(tester, 'D');
    await tapVisible(tester, find.byKey(const ValueKey('band-D2_SCRUM_SEQUENCE_SAFETY-excellent')));
    expect(h.controller.isComplete('D2_SCRUM_SEQUENCE_SAFETY'), isTrue);
    expect(find.textContaining('conviene explicar por qué'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('band-D2_SCRUM_SEQUENCE_SAFETY-urgent')));
    expect(find.textContaining('conviene explicar por qué'), findsNothing);
  });

  testWidgets('"No se observó": valorada sin banda y sin justificación', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await openTab(tester, 'D');
    await tapVisible(tester, find.byKey(const ValueKey('not-observed-D4_FAIR_CONTEST')));
    expect(h.controller.evaluationOf('D4_FAIR_CONTEST')!.notObserved, isTrue);
    expect(h.controller.isComplete('D4_FAIR_CONTEST'), isTrue);
  });

  testWidgets('la valoración del área y la global se recalculan al elegir', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await openTab(tester, 'D');
    expect(find.descendant(of: find.byKey(const ValueKey('area-band-SET_PIECE')), matching: find.text('Sin valorar')), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('band-D2_SCRUM_SEQUENCE_SAFETY-urgent')));
    await tester.ensureVisible(find.byKey(const ValueKey('area-band-SET_PIECE')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('area-band-SET_PIECE')), matching: find.text('U · Revisión urgente')), findsOneWidget);
    await openTab(tester, 'close');
    expect(find.descendant(of: find.byKey(const ValueKey('global-band')), matching: find.text('U · Revisión urgente')), findsOneWidget);
    expect(find.text('Las competencias sin valorar no cuentan.'), findsOneWidget);
  });

  testWidgets('la justificación se guarda sola (sin botón) tras dejar de escribir', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await openTab(tester, 'E');
    await tapVisible(tester, find.byKey(const ValueKey('band-E2_TACKLER_TACKLED-competent')));
    await tester.enterText(find.byKey(const ValueKey('justification-E2_TACKLER_TACKLED')), 'Buen breakdown.');
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(h.repo.evaluations['E2_TACKLER_TACKLED']!.justification, 'Buen breakdown.');
    expect(h.repo.evaluations['E2_TACKLER_TACKLED']!.finalBand, BandCode.competent);
  });

  testWidgets('el cierre nunca se bloquea: los avisos llevan a lo que falta', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await openTab(tester, 'close');
    final close = find.byKey(const ValueKey('close-report'));
    await tester.ensureVisible(close);
    await tester.pumpAndSettle();
    expect(tester.widget<ButtonStyleButton>(close).onPressed, isNotNull, reason: 'todo es opcional');
    expect(find.text('25 competencias sin valorar: no cuentan'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('issue-criterionBandMissing')));
    await tester.pumpAndSettle();
    expect(find.text('A · Colocación'), findsOneWidget);
    expect(find.byKey(const ValueKey('band-A1_STATIC_START-competent')).hitTestable(), findsOneWidget, reason: 'desplazado hasta la tarjeta');
  });

  testWidgets('las marcas sin valorar se avisan y llevan a la revisión', (tester) async {
    final h = Harness(incidents: [...defaultIncidents, seed('p', 70 * min, IncidentCategory.ruck, Verdict.pending, ImpactLevel.medium)]);
    await h.pump(tester);
    h.completeAll();
    await tester.pumpAndSettle();
    await openTab(tester, 'close');
    final issue = find.text('1 marca sin valorar: no cuenta (ir a la revisión)');
    await tester.ensureVisible(issue);
    await tester.tap(issue);
    expect(h.openedReview, 1);
  });

  testWidgets('cerrar sin rellenar nada: aviso en la confirmación, hash, solo lectura y vuelta arriba', (tester) async {
    var finalizedCalls = 0;
    final h = Harness(onFinalized: () => finalizedCalls++);
    await h.pump(tester);
    await openTab(tester, 'close');
    await tapVisible(tester, find.byKey(const ValueKey('close-report')));
    expect(find.textContaining('Hay 1 aviso sin resolver: no impide cerrar'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-close')));
    await tester.pumpAndSettle();

    final data = h.repo.finalizedWith!;
    expect(data.contentHash, contentHash(data.signedReport));
    expect(data.signedReport['band'], isNull, reason: 'nada valorado: sin valoración global');
    expect(data.signedReport.containsKey('status'), isFalse, reason: 'el hash no cubre el estado');
    expect((data.signedReport['criterionScores'] as List).length, 25);
    expect(h.controller.isFinalized, isTrue);
    expect(finalizedCalls, 1, reason: 'la app pasa al resumen del partido');
    // Lo nuevo aparece arriba y se ve SIN desplazarse (antes quedaba fuera de la vista).
    expect(find.byKey(const ValueKey('finalized-banner')).hitTestable(), findsOneWidget);
    expect(find.byKey(const ValueKey('close-report')), findsNothing);
    expectNoScores(tester);

    await openTab(tester, 'A');
    final tf = tester.widget<TextField>(find.byKey(const ValueKey('justification-A1_STATIC_START')));
    expect(tf.enabled, isFalse, reason: 'informe cerrado: solo lectura');
    h.controller.setBand('A1_STATIC_START', BandCode.excellent);
    expect(h.controller.evaluationOf('A1_STATIC_START'), isNull, reason: 'el controlador ignora cambios tras el cierre');
  });

  testWidgets('cierre: dificultad real y recomendación de nivel (opcionales) entran en el informe firmado', (tester) async {
    final h = Harness();
    await h.pump(tester);
    h.completeAll();
    await tester.pumpAndSettle();
    await openTab(tester, 'close');
    expect(find.textContaining('Estimada al preparar el partido: Alta'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('actual-difficulty-VERY_HIGH')));
    await tapVisible(tester, find.byKey(const ValueKey('level-rec-up')));
    expect((h.controller.actualDifficulty, h.controller.levelRecommendation), ('VERY_HIGH', LevelRecommendation.up));
    expect((h.repo.actualDifficulty, h.repo.levelRecommendation), ('VERY_HIGH', LevelRecommendation.up));
    // Tocar otra vez la quita.
    await tapVisible(tester, find.byKey(const ValueKey('level-rec-up')));
    expect(h.controller.levelRecommendation, isNull);
    await tapVisible(tester, find.byKey(const ValueKey('level-rec-same')));
    expect(find.text('Todo valorado.'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('close-report')));
    await tester.tap(find.byKey(const ValueKey('confirm-close')));
    await tester.pumpAndSettle();
    final signed = h.repo.finalizedWith!.signedReport;
    expect((signed['actualDifficulty'], signed['levelRecommendation']), ('VERY_HIGH', 'SAME'));
    expect(signed['band'], 'C');
    expect((signed['strengths'] as List).length, 1);
  });

  testWidgets('recomendaciones del informe anterior: se avisan, pero no impiden cerrar', (tester) async {
    final h = Harness(previous: const [
      PreviousActionPoint(id: 'prev1', criterionCode: 'A3_SEES_PLAY', text: 'Ver el ruck desde el lado defensor', successIndicator: ''),
    ]);
    await h.pump(tester);
    h.completeAll();
    await tester.pumpAndSettle();
    await openTab(tester, 'close');
    expect(h.controller.closeWarningsList.single.code, CloseIssueCode.previousActionPointNotReviewed);
    await tapVisible(tester, find.byKey(const ValueKey('prev-prev1-achieved')));
    expect(h.controller.closeWarningsList, isEmpty);
  });

  testWidgets('en catalán: áreas, competencias y escala del CARC', (tester) async {
    appLanguage.value = AppLanguage.ca;
    final h = Harness();
    await h.pump(tester);
    expect(find.text('A · Col·locació'), findsOneWidget);
    expect(find.text('A1 · El punt de partida en les fases estàtiques és adequat per seguir el joc'), findsOneWidget);
    await openTab(tester, 'E');
    expect(find.text('E · Fases dinàmiques'), findsOneWidget);
    expect(find.text('E6 · Coneix i aplica les accions del jugador pescador'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('suggested-E2_TACKLER_TACKLED')), matching: find.text('C · Competent')), findsOneWidget);
    await openTab(tester, 'close');
    expect(find.text('Dificultat real del partit'), findsOneWidget);
    expect(find.text("=  Mantenir en partits similars"), findsOneWidget);
  });

  group('accesibilidad y ergonomía', () {
    for (final b in Brightness.values) {
      testWidgets('objetivos, etiquetas y contraste (${b.name})', (tester) async {
        final handle = tester.ensureSemantics();
        final h = Harness();
        await h.pump(tester, brightness: b);
        for (final band in ['excellent', 'competent', 'notYet', 'urgent']) {
          await tapVisible(tester, find.byKey(ValueKey('band-A1_STATIC_START-$band')));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        }
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
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
        await tapVisible(tester, find.byKey(const ValueKey('band-A1_STATIC_START-notYet')));
        expect(tester.takeException(), isNull);
        await openTab(tester, 'close');
        expect(tester.takeException(), isNull);
      });
    }
  });
}
