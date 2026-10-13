import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/core/design_system/theme.dart';
import 'package:ref_assess/data/drift_evaluation_repository.dart';
import 'package:ref_assess/domain/rubric_default.dart';
import 'package:ref_assess/export/report_exporter.dart';
import 'package:ref_assess/features/evaluation/evaluation_controller.dart';
import 'package:ref_assess/features/evaluation/evaluation_screen.dart';
import 'package:ref_assess/features/evaluation/export_controller.dart';

import 'fixture.dart';

class FakeSharer implements FileSharer {
  final List<(List<File>, String, String)> calls = [];
  @override
  Future<void> share(List<File> files, {required String subject, required String text}) async => calls.add((files, subject, text));
}

void main() {
  late ExportFixture f;
  late FakeSharer sharer;
  late EvaluationController evaluation;
  ExportController? export;

  Future<void> pumpScreen(WidgetTester tester, {Brightness brightness = Brightness.light}) async {
    await tester.runAsync(() async {
      f = await ExportFixture.create();
      evaluation = EvaluationController(
        assessmentId: f.firstId,
        repository: DriftEvaluationRepository(f.db),
        rubric: kDefaultRubric,
        ids: SeqIds('ui'),
      );
      await evaluation.load();
    });
    sharer = FakeSharer();
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildRefTheme(brightness),
      home: EvaluationScreen(
        controller: evaluation,
        onOpenReview: () {},
        createExport: (home, away) => export = ExportController(
          assessmentId: f.firstId,
          exporter: f.exporter(),
          sharer: sharer,
          homeTeam: home,
          awayTeam: away,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tab-close')));
    await tester.pumpAndSettle();
  }

  /// La exportación hace E/S real (archivos): se deja avanzar el bucle de eventos real.
  Future<void> settleExport(WidgetTester tester) async {
    for (var i = 0; i < 200 && export!.busy != null; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    expect(export!.busy, isNull, reason: 'la exportación no terminó');
    await tester.pumpAndSettle();
  }

  tearDown(() async => f.dispose());

  testWidgets('informe cerrado: compartir PDF abre la hoja del sistema con asunto y huella', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Exportar y enviar al comité'), findsOneWidget);
    final pdfButton = find.byKey(const ValueKey('share-pdf'));
    await tester.ensureVisible(pdfButton);
    await tester.tap(pdfButton);
    await tester.pump();
    expect(export!.busy, isNotNull, reason: 'el botón dispara la exportación');
    await settleExport(tester);

    final (files, subject, text) = sharer.calls.single;
    expect(files.single.path, endsWith('.pdf'));
    expect(String.fromCharCodes(files.single.readAsBytesSync().take(5)), '%PDF-');
    expect(subject, 'Informe de evaluación arbitral · Club Local RC – Visitante RT');
    expect(text, contains(evaluation.finalized!.contentHash));
    expect(find.textContaining('Preparado: informe_2026-10-17_club-local-rc-visitante-rt_v1.pdf'), findsOneWidget);
  });

  testWidgets('PDF + JSON en un solo envío; el anexo se puede desactivar', (tester) async {
    await pumpScreen(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('export-annex')));
    await tester.tap(find.byKey(const ValueKey('export-annex')));
    await tester.pumpAndSettle();
    expect(export!.includeIncidentAnnex, isFalse);
    await tester.ensureVisible(find.byKey(const ValueKey('share-both')));
    await tester.tap(find.byKey(const ValueKey('share-both')));
    await tester.pump();
    await settleExport(tester);
    final (files, _, text) = sharer.calls.single;
    expect(files.map((f) => f.path.split('.').last), ['pdf', 'json']);
    expect(text, contains('(PDF y JSON)'));
  });

  testWidgets('huella alterada: no se comparte nada y se explica por qué', (tester) async {
    await pumpScreen(tester);
    await tester.runAsync(() async {
      await f.db.customStatement('DROP TRIGGER report_finalized_immutable');
      await f.db.customStatement("UPDATE report SET canonical_json = replace(canonical_json, 'Partido', 'PARTIDO')");
    });
    await tester.ensureVisible(find.byKey(const ValueKey('share-json')));
    await tester.tap(find.byKey(const ValueKey('share-json')));
    await tester.pump();
    await settleExport(tester);
    expect(sharer.calls, isEmpty);
    expect(find.textContaining('La huella del informe no coincide'), findsOneWidget);
  });

  testWidgets('accesibilidad de la sección de exportación (claro y oscuro)', (tester) async {
    for (final b in Brightness.values) {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, brightness: b);
      await tester.ensureVisible(find.byKey(const ValueKey('share-pdf')));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
      if (b == Brightness.light) await tester.runAsync(() => f.dispose());
    }
  });
}
