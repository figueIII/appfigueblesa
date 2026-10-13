import 'package:flutter/material.dart';

import 'core/design_system/theme.dart';
import 'core/platform_ports.dart';
import 'data/live_session_repository.dart';
import 'domain/category_presets.dart';
import 'features/live/live_controller.dart';
import 'features/live/live_screen.dart';

/// Arranque de demostración: un partido DHCAT en memoria. La capa Drift sustituirá a
/// InMemoryLiveSessionRepository sin tocar la UI.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const assessmentId = 'demo';
  final controller = LiveController(
    assessmentId: assessmentId,
    repository: InMemoryLiveSessionRepository(
      LiveSessionSnapshot(
        assessmentId: assessmentId,
        category: categoryPreset('SM_DHCAT_1_2_3'),
        homeTeam: 'Club Local RC',
        awayTeam: 'Visitante RT',
        clockLog: const [],
        incidents: const [],
      ),
    ),
    clock: StopwatchSessionClock(),
    ids: UuidV7Generator(),
    haptics: const SystemHaptics(),
  );
  runApp(RefAssessApp(controller: controller));
}

class RefAssessApp extends StatelessWidget {
  const RefAssessApp({super.key, required this.controller});
  final LiveController controller;

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
          onGoToReview: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La revisión post-partido es la pantalla 2.')),
          ),
        ),
      ),
    );
  }
}
