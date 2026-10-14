// Exportación del informe cerrado a JSON y PDF, y envío por la hoja de compartir del sistema.
//
// Garantías antes de escribir un solo byte:
//   1. el informe está cerrado y su huella SHA-256 coincide con el JSON guardado (verifyIntegrity);
//   2. el documento JSON valida contra export/assessment-export.schema.json (copia en assets);
//   3. el PDF se genera a partir de ese mismo documento validado.
// Cada archivo se registra en export_log con su propio SHA-256.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:json_schema/json_schema.dart';
import 'package:share_plus/share_plus.dart';

import '../core/platform_ports.dart';
import '../data/drift_export_repository.dart';
import '../domain/rubric.dart';
import 'export_document.dart';
import 'report_pdf.dart';

enum ExportFormat { json, pdf }

class ExportedFile {
  const ExportedFile({required this.file, required this.format, required this.sha256, required this.reportHash});
  final File file;
  final ExportFormat format;

  /// SHA-256 del archivo exportado (registro y comprobación de transmisión).
  final String sha256;

  /// Huella del informe cerrado (la del pie del PDF y `integrity.contentHash` del JSON).
  final String reportHash;
}

/// Hoja de compartir del sistema (correo, mensajería, almacenamiento…).
abstract interface class FileSharer {
  Future<void> share(List<File> files, {required String subject, required String text});
}

class SystemFileSharer implements FileSharer {
  const SystemFileSharer();
  @override
  Future<void> share(List<File> files, {required String subject, required String text}) => SharePlus.instance.share(ShareParams(
        files: [for (final f in files) XFile(f.path, mimeType: f.path.endsWith('.pdf') ? 'application/pdf' : 'application/json')],
        subject: subject,
        text: text,
      ));
}

class ReportExporter {
  ReportExporter({
    required this.repository,
    required this.rubric,
    required this.schema,
    required this.fonts,
    required this.exportsDirectory,
    required this.ids,
    this.appVersion = '1.1.1', // = version de pubspec.yaml
    DateTime Function()? now,
  }) : _now = now ?? (() => DateTime.now().toUtc());

  final ExportRepository repository;
  final AssessmentRubric rubric;
  final JsonSchema schema;
  final Future<PdfFonts> Function() fonts;
  final Future<Directory> Function() exportsDirectory;
  final IdGenerator ids;
  final String appVersion;
  final DateTime Function() _now;

  /// Documento validado. Lanza [ExportException] si no está cerrado, si la huella no cuadra o si
  /// no cumple el esquema (con la ruta de cada error).
  Future<(ExportSource, Map<String, Object?>)> buildValidatedDocument(String assessmentId) async {
    final source = await repository.loadExportSource(assessmentId);
    final doc = buildExportDocument(source, rubric, exportedAt: _now(), appVersion: appVersion);
    // Ida y vuelta por JSON: se valida exactamente lo que se escribirá.
    final result = schema.validate(jsonDecode(jsonEncode(doc)));
    if (!result.isValid) {
      throw ExportException(ExportErrorCode.schemaInvalid, [for (final e in result.errors) '${e.instancePath}: ${e.message}']);
    }
    return (source, doc);
  }

  /// Genera el archivo en memoria (documento validado → JSON o PDF), sin escribir nada.
  Future<RenderedExport> render(String assessmentId, ExportFormat format, {bool includeIncidentAnnex = true}) async {
    final (source, doc) = await buildValidatedDocument(assessmentId);
    final Uint8List bytes = switch (format) {
      ExportFormat.json => Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(doc))),
      ExportFormat.pdf => await buildReportPdf(doc, rubric, await fonts(), includeIncidentAnnex: includeIncidentAnnex),
    };
    return RenderedExport(
      source: source,
      format: format,
      fileName: exportFileName(source, format == ExportFormat.json ? 'json' : 'pdf'),
      bytes: bytes,
      sha256: sha256.convert(bytes).toString(),
    );
  }

  Future<void> _log(RenderedExport r, String relativePath) => repository.logExport(
        id: ids.next(),
        assessmentId: r.source.assessmentId,
        version: r.source.reportVersion,
        format: r.format == ExportFormat.json ? 'JSON' : 'PDF',
        relativePath: relativePath,
        sha256: r.sha256,
      );

  /// Móvil: escribe el archivo en el almacenamiento privado de la app y lo registra.
  Future<ExportedFile> export(String assessmentId, ExportFormat format, {bool includeIncidentAnnex = true}) async {
    final r = await render(assessmentId, format, includeIncidentAnnex: includeIncidentAnnex);
    final dir = await exportsDirectory();
    await dir.create(recursive: true);
    // Escritura atómica: temporal + renombrado (un archivo a medias nunca se comparte).
    final tmp = File('${dir.path}/.${r.fileName}.tmp');
    await tmp.writeAsBytes(r.bytes, flush: true);
    final file = await tmp.rename('${dir.path}/${r.fileName}');
    await _log(r, 'exports/${r.fileName}');
    return ExportedFile(file: file, format: format, sha256: r.sha256, reportHash: r.source.contentHash!);
  }

  /// Versión HTML de pruebas: no hay sistema de archivos; se registra y se entrega en memoria
  /// (el navegador lo descarga).
  Future<RenderedExport> renderForDownload(String assessmentId, ExportFormat format, {bool includeIncidentAnnex = true}) async {
    final r = await render(assessmentId, format, includeIncidentAnnex: includeIncidentAnnex);
    await _log(r, 'download/${r.fileName}');
    return r;
  }
}

/// Archivo exportado en memoria.
class RenderedExport {
  const RenderedExport({required this.source, required this.format, required this.fileName, required this.bytes, required this.sha256});
  final ExportSource source;
  final ExportFormat format;
  final String fileName;
  final Uint8List bytes;
  final String sha256;
  String get reportHash => source.contentHash!;
  String get mimeType => format == ExportFormat.pdf ? 'application/pdf' : 'application/json';
}

/// Entrega de archivos en memoria (versión HTML: descarga del navegador).
abstract interface class BytesSharer {
  Future<void> shareBytes(List<RenderedExport> files);
}

/// Texto que acompaña al envío (asunto y cuerpo del correo o mensaje).
(String subject, String text) shareMessage(String home, String away, String reportHash, List<ExportFormat> formats) => (
      'Informe de evaluación arbitral · $home – $away',
      'Adjunto el informe de evaluación arbitral del partido $home – $away '
          '(${formats.map((f) => f == ExportFormat.pdf ? 'PDF' : 'JSON').join(' y ')}).\n'
          'Huella de integridad SHA-256 del informe: $reportHash',
    );
