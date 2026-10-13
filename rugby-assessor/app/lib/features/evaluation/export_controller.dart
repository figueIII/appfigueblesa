// Estado de la exportación del informe cerrado: genera, valida y abre la hoja de compartir.

import 'package:flutter/foundation.dart';

import '../../export/export_document.dart';
import '../../export/report_exporter.dart';

class ExportController extends ChangeNotifier {
  ExportController({
    required this.assessmentId,
    required this.exporter,
    required this.sharer,
    required this.homeTeam,
    required this.awayTeam,
  });

  final String assessmentId;
  final ReportExporter exporter;
  final FileSharer sharer;
  final String homeTeam;
  final String awayTeam;

  bool includeIncidentAnnex = true;

  /// Formatos en curso (null = nada en curso).
  List<ExportFormat>? busy;
  String? error;
  List<ExportedFile> lastShared = const [];
  bool _disposed = false;

  void setIncludeAnnex(bool v) {
    includeIncidentAnnex = v;
    _notify();
  }

  Future<void> share(List<ExportFormat> formats) async {
    if (busy != null) return;
    busy = formats;
    error = null;
    _notify();
    try {
      final files = [for (final f in formats) await exporter.export(assessmentId, f, includeIncidentAnnex: includeIncidentAnnex)];
      final (subject, text) = shareMessage(homeTeam, awayTeam, files.first.reportHash, formats);
      await sharer.share([for (final f in files) f.file], subject: subject, text: text);
      lastShared = files;
    } on ExportException catch (e) {
      error = switch (e.code) {
        ExportErrorCode.integrityMismatch =>
          'La huella del informe no coincide con lo guardado al cerrar: no se exporta. El almacenamiento podría estar alterado.',
        ExportErrorCode.notFinalized => 'El informe aún no está cerrado.',
        ExportErrorCode.schemaInvalid => 'El documento no cumple el formato de exportación: ${e.details.take(2).join('; ')}',
      };
    } catch (_) {
      error = 'No se ha podido preparar o compartir el archivo. Vuelve a intentarlo.';
    } finally {
      busy = null;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
