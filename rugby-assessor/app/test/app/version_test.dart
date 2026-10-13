import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/data/db/app_database.dart';
import 'package:ref_assess/data/drift_export_repository.dart';
import 'package:ref_assess/domain/rubric_default.dart';
import 'package:ref_assess/export/report_exporter.dart';

import '../export/fixture.dart' show SeqIds, exportSchema, testFonts;

void main() {
  test('la versión que figura en los informes exportados es la de pubspec.yaml', () async {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*([0-9.]+)\+', multiLine: true).firstMatch(pubspec)![1];
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final exporter = ReportExporter(
      repository: DriftExportRepository(db),
      rubric: kDefaultRubric,
      schema: exportSchema(),
      fonts: testFonts,
      exportsDirectory: () async => Directory.systemTemp,
      ids: SeqIds('v'),
    );
    expect(exporter.appVersion, version);
  });
}
