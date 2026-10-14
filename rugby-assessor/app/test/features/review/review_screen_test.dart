import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/core/design_system/theme.dart';
import 'package:ref_assess/data/live_session_repository.dart';
import 'package:ref_assess/domain/category_presets.dart';
import 'package:ref_assess/domain/laws.dart';
import 'package:ref_assess/domain/model.dart';
import 'package:ref_assess/features/review/review_controller.dart';
import 'package:ref_assess/features/review/review_screen.dart';

const min = 60000;

Incident seedIncident(
  String id,
  int seq,
  int t,
  IncidentCategory c, {
  Verdict verdict = Verdict.pending,
  ImpactLevel impact = ImpactLevel.medium,
  bool confirmed = false,
  QuickPolarity polarity = QuickPolarity.review,
}) =>
    Incident(
      id: id,
      assessmentId: 'a1',
      seq: seq,
      sessionMs: t,
      wallUtc: DateTime.utc(2026, 10, 17, 15).add(Duration(milliseconds: t)),
      matchTime: MatchTimeStamp(
        period: t < 40 * min ? PeriodId.h1 : PeriodId.h2,
        phase: MatchPhaseLabel.inPlay,
        periodElapsedMs: t,
        matchClockMs: t,
        overtimeMs: 0,
        integrity: TimeIntegrity.ok,
      ),
      category: c,
      criterionCode: kCategoryToCriterion[c]!,
      polarity: polarity,
      verdict: verdict,
      impact: impact,
      impactConfirmed: confirmed,
      status: IncidentStatus.quick,
    );

class Harness {
  Harness([List<Incident>? incidents])
      : repo = InMemoryLiveSessionRepository(LiveSessionSnapshot(
          assessmentId: 'a1',
          category: categoryPreset('SM_DHCAT_1_2_3'),
          homeTeam: 'Club Local RC',
          awayTeam: 'Visitante RT',
          clockLog: const [],
          incidents: incidents ??
              [
                seedIncident('ruck', 1, 12 * min, IncidentCategory.ruck),
                seedIncident('scrum', 2, 30 * min, IncidentCategory.scrum, impact: ImpactLevel.high, confirmed: true),
                seedIncident('tackle', 3, 33 * min, IncidentCategory.tackle, verdict: Verdict.correct, impact: ImpactLevel.low, polarity: QuickPolarity.positive),
                seedIncident('offside', 4, 45 * min, IncidentCategory.offside, polarity: QuickPolarity.negative),
                seedIncident('card', 5, 60 * min, IncidentCategory.card, verdict: Verdict.correct, impact: ImpactLevel.high, confirmed: true),
              ],
        ));

  final InMemoryLiveSessionRepository repo;
  late final controller = ReviewController(assessmentId: 'a1', repository: repo);
  int continued = 0;

  Future<void> pump(WidgetTester tester, {Size size = const Size(390, 844), double textScale = 1, Brightness brightness = Brightness.light}) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildRefTheme(brightness),
      home: MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
        child: ReviewScreen(controller: controller, onContinueToRubric: () => continued++),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Incident stored(String id) => repo.incidents.firstWhere((i) => i.id == id);
}

Finder card(String id) => find.byKey(ValueKey('incident-$id'));

Future<void> tapVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('progreso y cola: solo las marcas sin veredicto, por impacto y minuto; lo recomendado, como sugerencia', (tester) async {
    final h = Harness();
    await h.pump(tester);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('de 5 resueltas'), findsOneWidget, reason: 'la tarjeta sin notas ya cuenta como resuelta');
    expect(find.text('Pendientes (3)'), findsOneWidget);
    final ys = [for (final id in ['scrum', 'ruck', 'offside']) tester.getTopLeft(card(id)).dy];
    expect(ys, orderedEquals([...ys]..sort()), reason: 'orden: scrum (alto) · ruck 12′ · offside 45′');
    expect(card('tackle'), findsNothing, reason: 'la resuelta no está en la cola');
    expect(card('card'), findsNothing, reason: 'con veredicto: las notas que faltan son solo recomendadas');
    expect(find.text('Recomendado: notas (impacto alto)'), findsOneWidget, reason: 'scrum: sugerencia, no error');
  });

  testWidgets('"Todas" muestra todo en orden cronológico', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.text('Todas (5)'));
    await tester.pumpAndSettle();
    expect(card('tackle'), findsOneWidget);
    expect(tester.getTopLeft(card('ruck')).dy, lessThan(tester.getTopLeft(card('scrum')).dy));
  });

  testWidgets('resolver un error: basta el veredicto; decisión esperada y notas son recomendadas', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(card('scrum'));
    await tester.pumpAndSettle();
    expect(find.text('30:00'), findsOneWidget);
    expect(find.text('Elige un veredicto.'), findsOneWidget, reason: 'lo único obligatorio');

    await tapVisible(tester, find.byKey(const ValueKey('verdict-incorrect')));
    expect(find.text('Elige un veredicto.'), findsNothing);
    expect(find.text('Lo que debía pitar según el reglamento (recomendado).'), findsOneWidget);
    expect(find.text('Recomendado en las de impacto alto o decisivo.'), findsOneWidget);
    expect(find.textContaining('Lista para el informe.'), findsOneWidget, reason: 'se puede guardar ya');

    await tester.tap(find.byKey(const ValueKey('save-incident')));
    await tester.pumpAndSettle();
    final saved = h.stored('scrum');
    expect((saved.verdict, saved.decisionExpected, saved.notes), (Verdict.incorrect, null, null));
    expect(find.text('12:00'), findsOneWidget, reason: 'abre la siguiente pendiente (ruck, 12:00)');
  });

  testWidgets('completar lo recomendado sigue funcionando: decisión esperada con ley y notas', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(card('scrum'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('verdict-incorrect')));
    await tapVisible(tester, find.byKey(const ValueKey('expected-penalty')));
    await tapVisible(tester, find.byKey(const ValueKey('expected-team-away')));
    await tester.enterText(find.byKey(const ValueKey('law-ref')), '19.10');
    await tester.ensureVisible(find.byKey(const ValueKey('notes')));
    await tester.enterText(find.byKey(const ValueKey('notes')), 'Colapso del pilar visitante no sancionado.');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-incident')));
    await tester.pumpAndSettle();
    final saved = h.stored('scrum');
    expect((saved.verdict, saved.polarity, saved.status), (Verdict.incorrect, QuickPolarity.negative, IncidentStatus.enriched));
    expect(saved.decisionExpected, const Decision(outcomes: [DecisionOutcome.penalty], againstTeam: TeamSide.away, lawRef: '19.10'));
    expect(saved.notes, 'Colapso del pilar visitante no sancionado.');
  });

  testWidgets('las decisiones poco frecuentes están plegadas hasta "Más decisiones"', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(card('ruck'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('verdict-missed')));
    expect(find.byKey(const ValueKey('expected-redCard20')), findsNothing);
    await tapVisible(tester, find.byKey(const ValueKey('expected-more')));
    await tapVisible(tester, find.byKey(const ValueKey('expected-redCard20')));
    expect(find.byKey(const ValueKey('expected-more')), findsNothing);
  });

  testWidgets('en un error se recomienda confirmar el impacto (no bloquea)', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(card('ruck'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('verdict-missed')));
    const hint = 'Recomendado en un error: confirma el impacto (por defecto, el del directo).';
    expect(find.text(hint), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('impact-low')));
    expect(find.text(hint), findsNothing);
  });

  testWidgets('reasignar el criterio de una marca', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(card('ruck'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('criterion-row')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('criterion-D2_POSITIONING')));
    expect(find.text('D2 · Posicionamiento'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('verdict-correct')));
    await tester.tap(find.byKey(const ValueKey('save-incident')));
    await tester.pumpAndSettle();
    expect(h.stored('ruck').criterionCode, 'D2_POSITIONING');
  });

  testWidgets('asignar la ley de una acción correcta y verla en la cola', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(card('ruck'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('verdict-correct')));
    await tapVisible(tester, find.byKey(const ValueKey('infraction-field')));
    expect(tester.getTopLeft(find.text('RUCK / SUELO')).dy, lessThan(tester.getTopLeft(find.text('FUERA DE JUEGO')).dy),
        reason: 'en una marca de ruck, primero las leyes del ruck');
    final opt = find.byKey(const ValueKey('infraction-SIDE_ENTRY'));
    await tester.scrollUntilVisible(opt, 200, scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(opt);
    await tester.pumpAndSettle();
    expect(find.text('Entrada lateral'), findsOneWidget);
    expect(find.text('Side entry · Ley 15'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('save-incident')));
    await tester.pumpAndSettle();
    expect(h.stored('ruck').infraction, InfractionRef.catalog('SIDE_ENTRY'));
    // "Guardar y siguiente" abrió la siguiente pendiente: se vuelve a la lista.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todas (5)'));
    await tester.pumpAndSettle();
    expect(find.text('Entrada lateral · Ley 15'), findsOneWidget, reason: 'la tarjeta de la cola muestra la ley');
  });

  testWidgets('quitar la ley de una marca', (tester) async {
    final h = Harness([
      seedIncident('ruck', 1, 12 * min, IncidentCategory.ruck, verdict: Verdict.correct, impact: ImpactLevel.low, polarity: QuickPolarity.positive)
          .copyWith(infraction: InfractionRef.catalog('HANDS_IN_RUCK')),
    ]);
    await h.pump(tester);
    await tester.tap(find.text('Todas (1)'));
    await tester.pumpAndSettle();
    await tester.tap(card('ruck'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('infraction-field')));
    await tester.tap(find.byKey(const ValueKey('infraction-clear')));
    await tester.pumpAndSettle();
    expect(find.text('Elegir ley o infracción'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('save-incident')));
    await tester.pumpAndSettle();
    expect(h.stored('ruck').infraction, isNull);
  });

  testWidgets('una sanción se pitó: su editor no ofrece "No pitada"; una marca normal sí', (tester) async {
    final h = Harness([
      seedIncident('ruck', 1, 12 * min, IncidentCategory.ruck),
      seedIncident('gc', 2, 20 * min, IncidentCategory.ruck).copyWith(
        decisionTaken: const Decision(outcomes: [DecisionOutcome.penalty], againstTeam: TeamSide.home),
        infraction: InfractionRef.catalog('SIDE_ENTRY'),
      ),
    ]);
    await h.pump(tester);
    await tester.tap(card('gc'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Golpe de castigo contra'), findsWidgets, reason: 'se titula por lo que se pitó');
    expect(find.text('Es una sanción: el árbitro la pitó. ¿Estuvo bien pitada?'), findsOneWidget);
    expect(find.byKey(const ValueKey('verdict-missed')), findsNothing);
    for (final v in ['correct', 'incorrect', 'debatable', 'notAssessable']) {
      expect(find.byKey(ValueKey('verdict-$v')), findsOneWidget, reason: v);
    }
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(card('ruck'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('verdict-missed')), findsOneWidget, reason: 'en las marcas individuales sigue existiendo');
  });

  testWidgets('salir con cambios sin guardar pide confirmación', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(card('ruck'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('verdict-correct')));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('¿Descartar los cambios?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-discard')));
    await tester.pumpAndSettle();
    expect(find.text('Pendientes (3)'), findsOneWidget);
    expect(h.stored('ruck').verdict, Verdict.pending);
  });

  testWidgets('anular desde la revisión: confirmación, VOID con motivo y sale de la cuenta', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(card('offside'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('void-incident')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-void')));
    await tester.pumpAndSettle();
    expect(h.stored('offside').status, IncidentStatus.voided);
    expect(h.repo.voidReasons['offside'], 'REVIEW');
    expect(find.text('de 4 resueltas'), findsOneWidget);
    expect(find.text('Pendientes (2)'), findsOneWidget);
  });

  testWidgets('fallo al guardar: aviso junto al botón y el borrador se conserva', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(card('ruck'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('verdict-correct')));
    h.repo.failWrites = true;
    await tester.tap(find.byKey(const ValueKey('save-incident')));
    await tester.pumpAndSettle();
    expect(find.textContaining('No se ha podido guardar'), findsOneWidget);
    expect(find.text('12:00'), findsOneWidget, reason: 'sigue en el editor');
    h.repo.failWrites = false;
    await tester.tap(find.byKey(const ValueKey('save-incident')));
    await tester.pumpAndSettle();
    expect(h.stored('ruck').verdict, Verdict.correct);
  });

  testWidgets('cola vacía: "Revisión completa" y paso a la pantalla 3', (tester) async {
    final h = Harness([
      seedIncident('a', 1, 5 * min, IncidentCategory.ruck),
      seedIncident('b', 2, 9 * min, IncidentCategory.tackle, verdict: Verdict.correct),
    ]);
    await h.pump(tester);
    await tester.tap(card('a'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('verdict-debatable')));
    expect(find.text('Guardar'), findsOneWidget, reason: 'no hay siguiente pendiente');
    await tester.tap(find.byKey(const ValueKey('save-incident')));
    await tester.pumpAndSettle();
    expect(find.text('Revisión completa'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('continue-to-rubric')));
    expect(h.continued, 1);
  });

  testWidgets('sin marcas: estado vacío propio', (tester) async {
    final h = Harness(const []);
    await h.pump(tester);
    expect(find.text('No hubo marcas en este partido'), findsOneWidget);
  });

  group('accesibilidad y ergonomía', () {
    for (final b in Brightness.values) {
      testWidgets('lista y editor: objetivos ≥ 48 dp, etiquetados, contraste (${b.name})', (tester) async {
        final handle = tester.ensureSemantics();
        final h = Harness();
        await h.pump(tester, brightness: b);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await tester.tap(card('scrum'));
        await tester.pumpAndSettle();
        await tapVisible(tester, find.byKey(const ValueKey('verdict-incorrect')));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }

    for (final (name, size) in [('360×640', const Size(360, 640)), ('horizontal 844×390', const Size(844, 390))]) {
      testWidgets('sin desbordes con texto ×1,6: $name', (tester) async {
        final h = Harness();
        await h.pump(tester, size: size, textScale: 1.6);
        expect(tester.takeException(), isNull);
        await tester.tap(card('scrum'));
        await tester.pumpAndSettle();
        await tapVisible(tester, find.byKey(const ValueKey('verdict-incorrect')));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
