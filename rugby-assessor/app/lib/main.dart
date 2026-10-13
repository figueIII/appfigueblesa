import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_schema/json_schema.dart';
import 'package:path_provider/path_provider.dart';

import 'core/design_system/theme.dart';
import 'core/platform_ports.dart';
import 'data/db/app_database.dart';
import 'data/drift_evaluation_repository.dart';
import 'data/drift_export_repository.dart';
import 'data/drift_live_session_repository.dart';
import 'data/evaluation_repository.dart';
import 'data/live_session_repository.dart';
import 'data/session_time.dart';
import 'domain/category_presets.dart';
import 'domain/rubric_default.dart';
import 'features/evaluation/evaluation_controller.dart';
import 'features/evaluation/evaluation_screen.dart';
import 'features/evaluation/export_controller.dart';
import 'export/report_exporter.dart';
import 'export/report_pdf.dart';
import 'features/live/live_controller.dart';
import 'features/live/live_screen.dart';
import 'features/review/review_controller.dart';
import 'features/review/review_screen.dart';

/// Arranque de producción: base de datos Drift en el dispositivo + reloj de sesión anclado.
/// Reanuda la evaluación abierta más reciente; si no hay ninguna, crea un partido de ejemplo
/// (la pantalla de preparación del partido sustituirá a este alta automática).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.onDevice();
  final ids = UuidV7Generator();
  final setup = AssessmentSetup(db, ids);
  final assessmentId =
      await setup.latestOpenAssessment() ??
      await setup.createLiveAssessment(
        category: categoryPreset('SM_DHCAT_1_2_3'),
        competition: 'DHCAT',
        venue: 'Campo Municipal',
        homeTeam: 'Club Local RC',
        awayTeam: 'Visitante RT',
        refereeName: 'Árbitro de ejemplo',
        assessorName: 'Evaluador',
        kickoffLocal: DateTime.now(),
      );
  final repo = DriftLiveSessionRepository(db);
  final (clock, recovery) = await openSessionClock(assessmentId: assessmentId, store: repo, mono: NativeMonotonicSource());
  final controller = LiveController(
    assessmentId: assessmentId,
    repository: repo,
    clock: clock,
    ids: ids,
    haptics: const SystemHaptics(),
    clockRecovery: recovery,
  );
  final exporter = ReportExporter(
    repository: DriftExportRepository(db),
    rubric: kDefaultRubric,
    // Esquema y fuentes van empaquetados: la exportación funciona sin conexión.
    schema: JsonSchema.create(await rootBundle.loadString('assets/export/assessment-export.schema.json')),
    fonts: () async => PdfFonts.fromBytes(
      regular: await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
      medium: await rootBundle.load('assets/fonts/Roboto-Medium.ttf'),
      bold: await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
      italic: await rootBundle.load('assets/fonts/Roboto-Italic.ttf'),
    ),
    exportsDirectory: () async => Directory('${(await getApplicationDocumentsDirectory()).path}/exports'),
    ids: ids,
  );
  runApp(
    RefAssessApp(
      controller: controller,
      reviewRepository: repo,
      evaluationRepository: DriftEvaluationRepository(db),
      ids: ids,
      exporter: exporter,
    ),
  );
}

class RefAssessApp extends StatelessWidget {
  const RefAssessApp({
    super.key,
    required this.controller,
    required this.reviewRepository,
    required this.evaluationRepository,
    required this.ids,
    required this.exporter,
  });
  final LiveController controller;
  final ReviewRepository reviewRepository;
  final EvaluationRepository evaluationRepository;
  final IdGenerator ids;
  final ReportExporter exporter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RefAssess',
      debugShowCheckedModeBanner: false,
      theme: buildRefTheme(Brightness.light),
      darkTheme: buildRefTheme(Brightness.dark),
      home: Builder(
        builder: (context) => LiveScreen(
          controller: controller,
          onGoToReview: () async {
            // Lo que quede en la cola del directo se escribe antes de leer para la revisión.
            await controller.flush();
            if (!context.mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (routeContext) => ReviewScreen(
                  controller: ReviewController(assessmentId: controller.assessmentId, repository: reviewRepository),
                  onContinueToRubric: () => Navigator.of(routeContext).push(
                    MaterialPageRoute<void>(
                      builder: (evalContext) => EvaluationScreen(
                        controller: EvaluationController(
                          assessmentId: controller.assessmentId,
                          repository: evaluationRepository,
                          rubric: kDefaultRubric,
                          ids: ids,
                        ),
                        // Desde la evaluación, "ir a la revisión" vuelve a la pantalla anterior.
                        onOpenReview: () => Navigator.of(evalContext).pop(),
                        createExport: (home, away) => ExportController(
                          assessmentId: controller.assessmentId,
                          exporter: exporter,
                          sharer: const SystemFileSharer(),
                          homeTeam: home,
                          awayTeam: away,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            // Al volver, el directo recarga: la revisión puede haber anulado o editado marcas.
            await controller.load();
          },
        ),
      ),
    );
  }
}
