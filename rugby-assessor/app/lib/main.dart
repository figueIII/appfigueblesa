import 'package:flutter/material.dart';

import 'app/app_services.dart';
import 'app/ref_assess_app.dart';

/// Arranque de producción: base de datos Drift en el dispositivo y pantalla de inicio con la
/// lista de partidos (nuevo, en curso, pendientes de revisión y finalizados).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RefAssessApp(services: await AppServices.onDevice()));
}
