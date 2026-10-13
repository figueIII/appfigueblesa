import 'dart:io';

import 'package:flutter/services.dart';
import 'package:json_schema/json_schema.dart';
import 'package:path_provider/path_provider.dart';

import '../core/platform_ports.dart';
import '../data/db/app_database.dart';
import '../data/drift_evaluation_repository.dart';
import '../data/drift_export_repository.dart';
import '../data/drift_live_session_repository.dart';
import '../data/evaluation_repository.dart';
import '../data/match_repository.dart';
import '../data/session_time.dart';
import '../domain/rubric.dart';
import '../domain/rubric_default.dart';
import '../export/report_exporter.dart';
import '../export/report_pdf.dart';

/// Todo lo que la app necesita, construido una vez al arrancar. Los tests montan la misma
/// navegación con una base de datos en memoria y dobles de los puertos de plataforma.
class AppServices {
  AppServices({
    required this.db,
    required this.ids,
    required this.mono,
    required this.exporter,
    AssessmentRubric? rubric,
    this.haptics = const SystemHaptics(),
    this.screenAwake = const WakelockScreenAwake(),
    this.sharer = const SystemFileSharer(),
    this.wallNow,
  })  : rubric = rubric ?? kDefaultRubric,
        live = DriftLiveSessionRepository(db),
        evaluation = DriftEvaluationRepository(db),
        matches = DriftMatchRepository(db, AssessmentSetup(db, ids));

  final AppDatabase db;
  final IdGenerator ids;
  final MonotonicSource mono;
  final ReportExporter exporter;
  final AssessmentRubric rubric;
  final Haptics haptics;
  final ScreenAwake screenAwake;
  final FileSharer sharer;

  /// Reloj de pared (solo se sustituye en tests).
  final DateTime Function()? wallNow;

  final DriftLiveSessionRepository live;
  final EvaluationRepository evaluation;
  final MatchRepository matches;

  /// Arranque de producción: SQLite en el almacenamiento privado, reloj de arranque del sistema,
  /// esquema de exportación y fuentes empaquetados (la exportación funciona sin conexión).
  static Future<AppServices> onDevice() async {
    final db = AppDatabase.onDevice();
    final ids = UuidV7Generator();
    final schema = JsonSchema.create(await rootBundle.loadString('assets/export/assessment-export.schema.json'));
    return AppServices(
      db: db,
      ids: ids,
      mono: NativeMonotonicSource(),
      exporter: ReportExporter(
        repository: DriftExportRepository(db),
        rubric: kDefaultRubric,
        schema: schema,
        fonts: () async => PdfFonts.fromBytes(
          regular: await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
          medium: await rootBundle.load('assets/fonts/Roboto-Medium.ttf'),
          bold: await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
          italic: await rootBundle.load('assets/fonts/Roboto-Italic.ttf'),
        ),
        exportsDirectory: () async => Directory('${(await getApplicationDocumentsDirectory()).path}/exports'),
        ids: ids,
      ),
    );
  }
}
