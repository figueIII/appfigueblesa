// Escribe un PDF y un JSON de muestra en ../export/samples/ (solo con REFASSESS_WRITE_SAMPLES=1).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/export/report_exporter.dart';

import 'fixture.dart';

void main() {
  test('muestras de exportación', () async {
    final f = await ExportFixture.create();
    try {
      final e = f.exporter();
      final pdf = await e.export(f.secondId, ExportFormat.pdf);
      final json = await e.export(f.secondId, ExportFormat.json);
      final out = Directory('../export/samples')..createSync(recursive: true);
      pdf.file.copySync('${out.path}/informe-ejemplo.pdf');
      json.file.copySync('${out.path}/informe-ejemplo.json');
    } finally {
      await f.dispose();
    }
  }, skip: Platform.environment['REFASSESS_WRITE_SAMPLES'] != '1');
}
