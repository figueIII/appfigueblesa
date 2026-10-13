import 'package:flutter/material.dart';

import 'core/design_system/theme.dart';
import 'core/platform_ports.dart';
import 'data/db/app_database.dart';
import 'data/drift_live_session_repository.dart';
import 'data/live_session_repository.dart';
import 'data/session_time.dart';
import 'domain/category_presets.dart';
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
  final assessmentId = await setup.latestOpenAssessment() ??
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
  final (clock, recovery) = await openSessionClock(
    assessmentId: assessmentId,
    store: repo,
    mono: NativeMonotonicSource(),
  );
  final controller = LiveController(
    assessmentId: assessmentId,
    repository: repo,
    clock: clock,
    ids: ids,
    haptics: const SystemHaptics(),
    clockRecovery: recovery,
  );
  runApp(RefAssessApp(controller: controller, reviewRepository: repo));
}

class RefAssessApp extends StatelessWidget {
  const RefAssessApp({super.key, required this.controller, required this.reviewRepository});
  final LiveController controller;
  final ReviewRepository reviewRepository;

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
            await Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (routeContext) => ReviewScreen(
                controller: ReviewController(assessmentId: controller.assessmentId, repository: reviewRepository),
                onContinueToRubric: () => ScaffoldMessenger.of(routeContext).showSnackBar(
                  const SnackBar(content: Text('La evaluación por criterios es la pantalla 3.')),
                ),
              ),
            ));
            // Al volver, el directo recarga: la revisión puede haber anulado o editado marcas.
            await controller.load();
          },
        ),
      ),
    );
  }
}
