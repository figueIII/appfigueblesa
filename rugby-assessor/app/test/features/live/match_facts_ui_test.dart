import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/domain/clock.dart';
import 'package:ref_assess/domain/laws.dart';
import 'package:ref_assess/domain/match_facts.dart';
import 'package:ref_assess/domain/model.dart';

import 'live_screen_test.dart' show Harness, min, tile;

Finder key(String k) => find.byKey(ValueKey(k));

/// Con la 1ª parte en marcha y en el minuto [minute].
Future<Harness> playing(WidgetTester tester, {int minute = 10, double textScale = 1, Brightness brightness = Brightness.light, bool withEditing = false}) async {
  final h = Harness(clockLog: const [ClockEvent(seq: 1, t: 0, body: PeriodStart(PeriodId.h1))]);
  h.clock.t = minute * min;
  await h.pump(tester, textScale: textScale, brightness: brightness, withEditing: withEditing);
  return h;
}

Future<void> tapIn(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Elige una opción del selector de leyes (es una lista larga: se desplaza hasta ella).
Future<void> pick(WidgetTester tester, String option) async {
  final f = key('infraction-$option');
  await tester.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).last);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Desplaza la hoja abierta hasta [f] (sus listas se construyen bajo demanda).
Future<void> seeInSheet(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(f, 150, scrollable: find.byType(Scrollable).last);
  await tester.pumpAndSettle();
}

String scoreText(WidgetTester tester) => tester.widget<Text>(key('scoreboard-score')).data!;

void main() {
  group('marcador', () {
    testWidgets('anotar desde la hoja: ensayo, transformación tras el ensayo, golpe a palos y deshacer', (tester) async {
      final h = await playing(tester);
      expect(scoreText(tester), '0 – 0');
      await tapIn(tester, key('scoreboard'));
      expect(find.text('Marcador'), findsOneWidget);

      FilledButton btn(String k) => tester.widget<FilledButton>(key(k));
      expect(btn('score-home-conversion').onPressed, isNull, reason: 'sin ensayo no hay transformación');
      expect(find.text('Tras un ensayo'), findsNWidgets(2));

      await tapIn(tester, key('score-home-tryScored'));
      expect(btn('score-home-conversion').onPressed, isNotNull, reason: 'el local acaba de marcar ensayo');
      expect(btn('score-away-conversion').onPressed, isNull);
      await tapIn(tester, key('score-home-conversion'));
      expect(btn('score-home-conversion').onPressed, isNull, reason: 'ya transformado');
      h.clock.t += 5 * min;
      await tapIn(tester, key('score-away-penaltyGoal'));
      expect(tester.widget<Text>(key('score-sheet-score')).data, '7 – 3');
      expect(find.text('Deshacer: Golpe a palos · Visitante RT · 15:00'), findsOneWidget);

      await tapIn(tester, key('score-undo'));
      expect(tester.widget<Text>(key('score-sheet-score')).data, '7 – 0');
      expect(h.haptics.calls.where((c) => c == 'logged').length, 3);
      expect(h.haptics.calls.last, 'undone');

      // Al cerrar la hoja, el marcador de la cabecera refleja lo mismo y está guardado.
      await tester.tapAt(const Offset(195, 40));
      await tester.pumpAndSettle();
      expect(scoreText(tester), '7 – 0');
      await h.controller.flush();
      expect(h.repo.storedScore, const Scoreline(7, 0));
      expect(h.repo.scores.map((e) => (e.kind, e.voided)), [
        (ScoreKind.tryScored, false),
        (ScoreKind.conversion, false),
        (ScoreKind.penaltyGoal, true),
      ]);
      expect(h.repo.scores.first.matchClockMs, 10 * min, reason: 'minuto del partido al tocar');
    });

    testWidgets('si se falla la transformación, el siguiente tanto cierra la opción', (tester) async {
      final h = await playing(tester);
      await tapIn(tester, key('scoreboard'));
      await tapIn(tester, key('score-away-tryScored'));
      await tapIn(tester, key('score-home-dropGoal'));
      expect(tester.widget<FilledButton>(key('score-away-conversion')).onPressed, isNull);
      expect(h.controller.addScore(TeamSide.away, ScoreKind.conversion, t: h.clock.t), ScoreRuleError.conversionWithoutTry);
      expect(h.controller.scoreline, const Scoreline(3, 5));
    });
  });

  group('sanciones', () {
    /// Abre el panel, elige el equipo infractor y registra la sanción (el panel se cierra solo).
    Future<void> registerSanction(WidgetTester tester, TeamSide team, SanctionKind kind, String option) async {
      await tapIn(tester, key('discipline-bar'));
      await tapIn(tester, key('sanction-team-${team.name}'));
      await tapIn(tester, key('sanction-add-${kind.name}'));
      await pick(tester, option);
    }

    Future<void> closeSheet(WidgetTester tester) async {
      await tester.tapAt(const Offset(195, 20));
      await tester.pumpAndSettle();
    }

    testWidgets('una sanción es una marca: el panel se cierra y se valora al momento con Bien / Error', (tester) async {
      final h = await playing(tester);
      await registerSanction(tester, TeamSide.home, SanctionKind.penalty, 'SIDE_ENTRY');
      expect(find.text('Sanciones del árbitro'), findsNothing, reason: 'el panel se cierra para valorar');
      expect(find.text('Marcado: Golpe de castigo contra Club Local RC · 10:00'), findsOneWidget);
      await tester.tap(key('refine-positive'));
      await tester.pump();
      final mark = h.controller.incidents.single;
      expect(mark.verdict, Verdict.correct, reason: 'bien pitado');
      expect(mark.category, IncidentCategory.ruck, reason: 'cuenta en el criterio de su fase');
      expect(mark.decisionTaken, const Decision(outcomes: [DecisionOutcome.penalty], againstTeam: TeamSide.home));
      expect(tester.widget<Text>(key('tally-home-penalty')).data, '1');

      await registerSanction(tester, TeamSide.away, SanctionKind.freeKick, 'SCRUM_EARLY_ENGAGEMENT');
      await tester.tap(key('refine-negative'));
      await tester.pump();
      expect(h.controller.incidents.last.polarity, QuickPolarity.negative, reason: 'mal pitado: queda para revisar');
      expect(find.textContaining('2 marcas · 1 por revisar'), findsOneWidget);
      await h.controller.flush();
      expect(h.repo.incidents.length, 2, reason: 'las sanciones se guardan como marcas');
    });

    testWidgets('contador por equipo y desglose acumulado por motivo', (tester) async {
      final h = await playing(tester);
      for (final (kind, option) in const [
        (SanctionKind.penalty, 'OFFSIDE_RUCK_MAUL'),
        (SanctionKind.penalty, 'SIDE_ENTRY'),
        (SanctionKind.freeKick, 'OFFSIDE_RUCK_MAUL'),
        (SanctionKind.penalty, 'OFFSIDE_RUCK_MAUL'),
        (SanctionKind.penalty, 'unspecified'),
      ]) {
        await registerSanction(tester, TeamSide.home, kind, option);
      }
      await registerSanction(tester, TeamSide.away, SanctionKind.penalty, 'HANDS_IN_RUCK');
      expect(tester.widget<Text>(key('tally-home-penalty')).data, '4');
      expect(tester.widget<Text>(key('tally-home-freeKick')).data, '1');
      expect(tester.widget<Text>(key('tally-away-penalty')).data, '1');

      await tapIn(tester, key('discipline-bar'));
      expect(find.text('GC 4  ·  GF 1  ·  TA 0  ·  TR 0'), findsOneWidget);
      expect(find.text('3× Fuera de juego en ruck / maul'), findsOneWidget);
      expect(find.text('GC 2 · GF 1 · Leyes 15 y 16'), findsOneWidget);
      expect(find.text('1× Entrada lateral'), findsOneWidget);
      await seeInSheet(tester, find.text('1× Sin especificar'));
      expect(find.text('1× Sin especificar'), findsOneWidget);
      final y = [
        for (final t in ['3× Fuera de juego en ruck / maul', '1× Entrada lateral', '1× Sin especificar']) tester.getTopLeft(find.text(t)).dy,
      ];
      expect(y, orderedEquals([...y]..sort()), reason: 'de más a menos frecuente; sin especificar al final');
      await tapIn(tester, key('sanction-team-away'));
      expect(find.text('GC 1  ·  GF 0  ·  TA 0  ·  TR 0'), findsOneWidget, reason: 'cada equipo, su contador');
      await closeSheet(tester);
      await h.controller.flush();
      expect(sanctionsOf(h.repo.incidents).length, 6);
    });

    testWidgets('el minuto es el del toque en "+ GC", aunque se tarde en elegir el motivo', (tester) async {
      final h = await playing(tester, minute: 20);
      await tapIn(tester, key('discipline-bar'));
      await tapIn(tester, key('sanction-add-penalty'));
      h.clock.t += 40000; // 40 s eligiendo
      await pick(tester, 'NOT_RELEASING');
      expect(h.controller.sanctions.single.matchClockMs, 20 * min);
      expect(h.controller.sanctions.single.infraction, InfractionRef.catalog('NOT_RELEASING'));
    });

    testWidgets('cerrar el selector sin elegir no registra nada', (tester) async {
      final h = await playing(tester);
      await tapIn(tester, key('discipline-bar'));
      await tapIn(tester, key('sanction-add-freeKick'));
      await tester.tapAt(const Offset(195, 10)); // fuera de la hoja del selector
      await tester.pumpAndSettle();
      expect(h.controller.sanctions, isEmpty);
      expect(h.controller.incidents, isEmpty);
    });

    testWidgets('tarjetas: con motivo, en su lista y en el contador; "Otra infracción" personalizada', (tester) async {
      final h = await playing(tester);
      await registerSanction(tester, TeamSide.away, SanctionKind.yellowCard, 'HIGH_TACKLE');
      expect(find.text('Marcado: Amarilla contra Visitante RT · 10:00'), findsOneWidget);
      expect(h.controller.incidents.single.category, IncidentCategory.card);

      await tapIn(tester, key('discipline-bar'));
      await tapIn(tester, key('sanction-add-penalty')); // equipo: el último elegido no se recuerda → local
      await tester.tapAt(const Offset(195, 10));
      await tester.pumpAndSettle();
      await tapIn(tester, key('sanction-team-away'));
      expect(find.text('10:00 · Placaje alto / contacto con la cabeza'), findsOneWidget);
      expect(find.text('Sin golpes registrados contra Visitante RT.'), findsOneWidget, reason: 'las tarjetas no cuentan como golpes');
      await tapIn(tester, key('sanction-add-penalty'));
      await pick(tester, 'custom');
      await tester.enterText(key('custom-infraction-text'), 'Avance intencionado');
      await tester.enterText(key('custom-infraction-law'), 'Ley 11');
      await tester.pump();
      await tapIn(tester, key('custom-infraction-ok'));

      await tapIn(tester, key('discipline-bar'));
      await tapIn(tester, key('sanction-team-away'));
      expect(find.text('1× Avance intencionado'), findsOneWidget);
      expect(find.text('GC 1 · Ley 11'), findsOneWidget);
      expect(find.text('GC 1  ·  GF 0  ·  TA 1  ·  TR 0'), findsOneWidget);
      expect(h.controller.sanctionTally.count(TeamSide.away, SanctionKind.yellowCard), 1);
    });

    testWidgets('completar después el motivo de un golpe "sin especificar"', (tester) async {
      final h = await playing(tester);
      await registerSanction(tester, TeamSide.home, SanctionKind.penalty, 'unspecified');
      await tapIn(tester, key('discipline-bar'));
      await tapIn(tester, find.text('Completar'));
      await pick(tester, 'OFF_FEET_SEALING');
      expect(find.text('1× Tirarse sobre el ruck / sellar'), findsOneWidget);
      expect(find.text('1× Sin especificar'), findsNothing);
      await h.controller.flush();
      expect(h.repo.incidents.single.infraction!.code, 'OFF_FEET_SEALING');
    });

    testWidgets('deshacer anula la última sanción (es anular su marca, no borrarla)', (tester) async {
      final h = await playing(tester);
      await registerSanction(tester, TeamSide.home, SanctionKind.redCard, 'TIP_TACKLE');
      await tapIn(tester, key('discipline-bar'));
      await seeInSheet(tester, key('sanction-undo'));
      expect(find.text('Deshacer: TR · Club Local RC · 10:00'), findsOneWidget);
      await tapIn(tester, key('sanction-undo'));
      expect(find.text('Sin tarjetas.'), findsOneWidget);
      await h.controller.flush();
      expect(h.repo.incidents.single.isVoid, isTrue);
      expect(tester.widget<Text>(key('tally-home-redCard')).data, '0');
    });
  });

  group('ley de una marca', () {
    testWidgets('"Ley" en la tira: grupos según la categoría y se guarda en la marca', (tester) async {
      final h = await playing(tester);
      await tester.tap(tile('ruck'));
      await tester.pump();
      await tapIn(tester, key('refine-law'));
      final ruck = tester.getTopLeft(find.text('RUCK / SUELO')).dy;
      final offside = tester.getTopLeft(find.text('FUERA DE JUEGO')).dy;
      expect(ruck, lessThan(offside), reason: 'en un ruck, primero las leyes del ruck');
      await pick(tester, 'HANDS_IN_RUCK');
      await h.controller.flush();
      expect(h.repo.incidents.single.infraction, InfractionRef.catalog('HANDS_IN_RUCK'));
      expect(h.repo.incidents.single.polarity, QuickPolarity.review, reason: 'la ley no cambia la valoración');
    });

    testWidgets('se puede asignar aunque la ventana de 10 s termine mientras se elige', (tester) async {
      final h = await playing(tester);
      await tester.tap(tile('scrum'));
      await tester.pump();
      await tapIn(tester, key('refine-law'));
      h.clock.t += 15000;
      await pick(tester, 'SCRUM_COLLAPSING');
      await tester.pump(const Duration(milliseconds: 300));
      expect(h.controller.incidents.single.infraction!.code, 'SCRUM_COLLAPSING');
      expect(find.textContaining('Derrumbar la melé'), findsOneWidget, reason: 'el resumen de la última marca la muestra');
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('accesibilidad de las hojas de marcador y sanciones (${brightness.name})', (tester) async {
      final handle = tester.ensureSemantics();
      await playing(tester, brightness: brightness);
      await tapIn(tester, key('scoreboard'));
      await tapIn(tester, key('score-home-tryScored'));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await tester.tapAt(const Offset(195, 20));
      await tester.pumpAndSettle();
      await tapIn(tester, key('discipline-bar'));
      await tapIn(tester, key('sanction-add-penalty'));
      await pick(tester, 'SIDE_ENTRY');
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  }

  testWidgets('texto ×1.6: cabecera, hojas y selector sin desbordes', (tester) async {
    await playing(tester, textScale: 1.6);
    expect(tester.takeException(), isNull);
    await tapIn(tester, key('scoreboard'));
    await tapIn(tester, key('score-home-tryScored'));
    expect(tester.takeException(), isNull);
    await tester.tapAt(const Offset(195, 20));
    await tester.pumpAndSettle();
    await tapIn(tester, key('discipline-bar'));
    await tapIn(tester, key('sanction-add-yellowCard'));
    await pick(tester, 'DISSENT');
    expect(tester.takeException(), isNull);
  });

  group('editar durante el partido', () {
    testWidgets('"Editar" en la tira (también pasada la ventana de 10 s) y la lista de marcas con su insignia', (tester) async {
      final h = await playing(tester, withEditing: true);
      expect(key('open-marks'), findsOneWidget);
      await tester.tap(tile('scrum'));
      await tester.pump();
      await tapIn(tester, key('edit-last'));
      expect(h.edited, [h.controller.incidents.single.id]);
      h.clock.t += 15000;
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Última: Scrum'), findsOneWidget);
      await tapIn(tester, key('edit-last'));
      expect(h.edited.length, 2, reason: 'se puede editar cuando se quiera');
      await tapIn(tester, key('open-marks'));
      expect(h.openedMarks, 1);
      expect(find.bySemanticsLabel('Ver y editar las marcas: 1, 1 por revisar'), findsOneWidget);
    });

    testWidgets('sin acceso al editor (p. ej. en las pruebas antiguas), no aparecen los botones', (tester) async {
      await playing(tester);
      await tester.tap(tile('scrum'));
      await tester.pump();
      expect(key('edit-last'), findsNothing);
      expect(key('open-marks'), findsNothing);
    });

    for (final brightness in Brightness.values) {
      testWidgets('accesibilidad con "Editar" y la lista de marcas (${brightness.name})', (tester) async {
        final handle = tester.ensureSemantics();
        await playing(tester, withEditing: true, brightness: brightness);
        await tester.tap(tile('ruck'));
        await tester.pump();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  });
}
