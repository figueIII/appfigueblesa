import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/data/drift_export_repository.dart';
import 'package:ref_assess/domain/rubric_default.dart';
import 'package:ref_assess/export/export_document.dart';
import 'package:ref_assess/export/report_exporter.dart';
import 'package:ref_assess/features/evaluation/export_controller.dart';

import 'fixture.dart';

final _hasPdftotext = File('/usr/bin/pdftotext').existsSync();

String pdfText(File pdf) {
  final r = Process.runSync('pdftotext', ['-layout', pdf.path, '-']);
  return r.stdout as String;
}

int pdfPages(File pdf) {
  final r = Process.runSync('pdfinfo', [pdf.path]);
  return int.parse(RegExp(r'Pages:\s+(\d+)').firstMatch(r.stdout as String)!.group(1)!);
}

void main() {
  late ExportFixture f;
  setUp(() async => f = await ExportFixture.create());
  tearDown(() => f.dispose());

  test('la copia del esquema en assets es idéntica a export/assessment-export.schema.json', () {
    expect(File('assets/export/assessment-export.schema.json').readAsStringSync(), File('../export/assessment-export.schema.json').readAsStringSync());
  });

  group('JSON', () {
    test('valida contra el esquema y lleva la huella calculada al cerrar', () async {
      final out = await f.exporter().export(f.secondId, ExportFormat.json);
      final doc = jsonDecode(out.file.readAsStringSync()) as Map<String, dynamic>;
      expect(exportSchema().validate(doc).isValid, isTrue);

      final stored = await (f.db.select(f.db.report)..where((t) => t.assessmentId.equals(f.secondId))).getSingle();
      expect(doc['integrity']['contentHash'], stored.contentHash);
      expect(out.reportHash, stored.contentHash);
      // Verificación independiente: quitar "status" del informe exportado y recalcular la huella.
      final signed = Map<String, Object?>.from(doc['report'] as Map)..remove('status');
      expect(sha256.convert(utf8.encode(_canonical(signed))).toString(), stored.contentHash, reason: 'cualquiera puede verificar el informe con el JSON');

      expect(doc['report']['status'], 'FINALIZED');
      expect(doc['match']['difficulty'], 'HIGH');
      expect(doc['match']['assistants'], {'ar1': 'Asistente Uno', 'ar2': 'Asistente Dos'});
      expect(doc['match']['finalScore'], {'home': 24, 'away': 19});
      expect((doc['incidents'] as List).map((i) => i['matchClock']), ['12:00', '30:00', '52:00', '65:00'], reason: 'orden cronológico');
      expect((doc['report']['previousActionPointReviews'] as List).single['status'], 'PARTIAL');
      expect(out.sha256, sha256.convert(out.file.readAsBytesSync()).toString());
    });

    test('validación cruzada con el validador de referencia en Python (jsonschema)', () async {
      final out = await f.exporter().export(f.firstId, ExportFormat.json);
      final r = Process.runSync('python3', [
        '-I', '-c',
        'import json,sys,jsonschema;s=json.load(open(sys.argv[1]));d=json.load(open(sys.argv[2]));'
            'jsonschema.Draft202012Validator(s).validate(d);print("OK")',
        File('../export/assessment-export.schema.json').absolute.path,
        out.file.path,
      ]);
      expect(r.stdout.toString().trim(), 'OK', reason: '${r.stderr}');
    }, skip: Process.runSync('python3', ['-I', '-c', 'import jsonschema']).exitCode != 0 ? 'sin jsonschema en Python' : false);

    test('formato 2.1: marcador, sanciones con desglose e infracción de cada incidencia', () async {
      final out = await f.exporter().export(f.firstId, ExportFormat.json);
      final doc = jsonDecode(out.file.readAsStringSync()) as Map<String, dynamic>;
      expect(doc['formatVersion'], '2.1');
      final stats = doc['matchStats'] as Map;
      final score = stats['score'] as Map;
      expect([score['home'], score['away']], [24, 19]);
      expect(doc['match']['finalScore'], {'home': 24, 'away': 19}, reason: 'el resultado del partido es el del marcador en directo');
      expect((score['events'] as List).length, 12, reason: 'el drop anulado no se exporta');
      expect((score['events'] as List).first, {'seq': 1, 'team': 'HOME', 'kind': 'TRY', 'points': 5, 'matchClock': '08:00', 'period': 'H1'});

      final sanctions = stats['sanctions'] as Map;
      expect(sanctions['totals'], {
        'home': {'PENALTY': 5, 'FREE_KICK': 1, 'YELLOW_CARD': 0, 'RED_CARD': 0},
        'away': {'PENALTY': 2, 'FREE_KICK': 1, 'YELLOW_CARD': 1, 'RED_CARD': 0},
      });
      final home = (sanctions['breakdown'] as Map)['home'] as List;
      expect([for (final r in home) '${r['penalties'] + r['freeKicks']}× ${r['label']}'],
          ['3× Fuera de juego en ruck / maul', '2× Entrada lateral', '1× Sin especificar']);
      expect(home.first, {'label': 'Fuera de juego en ruck / maul', 'code': 'OFFSIDE_RUCK_MAUL', 'lawRef': 'Leyes 15 y 16', 'penalties': 2, 'freeKicks': 1});
      final away = (sanctions['breakdown'] as Map)['away'] as List;
      expect(away.last, {'label': 'Avance intencionado', 'code': 'CUSTOM', 'lawRef': 'Ley 11', 'penalties': 1, 'freeKicks': 0});
      expect(((sanctions['events'] as List).firstWhere((e) => e['kind'] == 'YELLOW_CARD') as Map)['infraction']['code'], 'HIGH_TACKLE');

      final byClock = {for (final i in doc['incidents'] as List) i['matchClock']: i};
      expect(byClock['30:00']['infraction'], {'code': 'SCRUM_COLLAPSING', 'label': 'Derrumbar la melé', 'lawRef': 'Ley 19'});
      expect(byClock['12:00']['infraction']['code'], 'HIGH_TACKLE', reason: 'también en las acciones correctas');
      expect(byClock['52:00'].containsKey('infraction'), isFalse);
      expect(exportSchema().validate(doc).isValid, isTrue);
    });

    test('sin registros de marcador ni sanciones, no se exporta matchStats (un 0 afirmaría algo no anotado)', () async {
      final src = await DriftExportRepository(f.db).loadExportSource(f.firstId);
      final bare = ExportSource(
        assessmentId: src.assessmentId, competition: src.competition, category: src.category, kickoffLocal: src.kickoffLocal,
        kickoffTz: src.kickoffTz, venue: src.venue, homeTeam: src.homeTeam, awayTeam: src.awayTeam, observationMode: src.observationMode,
        refereeId: src.refereeId, refereeName: src.refereeName, assessorId: src.assessorId, assessorName: src.assessorName,
        reportVersion: src.reportVersion, reportStatus: src.reportStatus, canonicalJson: src.canonicalJson, contentHash: src.contentHash,
        incidents: src.incidents,
      );
      final doc = buildExportDocument(bare, kDefaultRubric, exportedAt: DateTime.utc(2026), appVersion: 't');
      expect(doc.containsKey('matchStats'), isFalse);
      final onlySanctions = buildMatchStats(ExportSource(
        assessmentId: src.assessmentId, competition: src.competition, category: src.category, kickoffLocal: src.kickoffLocal,
        kickoffTz: src.kickoffTz, venue: src.venue, homeTeam: src.homeTeam, awayTeam: src.awayTeam, observationMode: src.observationMode,
        refereeId: src.refereeId, refereeName: src.refereeName, assessorId: src.assessorId, assessorName: src.assessorName,
        reportVersion: 1, reportStatus: 'FINALIZED', canonicalJson: src.canonicalJson, contentHash: src.contentHash,
        incidents: const [], sanctions: src.sanctions,
      ))!;
      expect(onlySanctions.keys, ['sanctions']);
      expect(exportSchema().validate(jsonDecode(jsonEncode(doc))).isValid, isTrue);
    });

    test('un documento 2.0 (sin marcador ni infracciones) sigue siendo válido', () {
      final doc = jsonDecode(File('../export/example-export.json').readAsStringSync()) as Map<String, dynamic>;
      expect(doc['formatVersion'], '2.0');
      expect(exportSchema().validate(doc).isValid, isTrue);
    });

    test('un documento que no cumple el esquema no se exporta', () async {
      final (source, doc) = await f.exporter().buildValidatedDocument(f.firstId);
      (doc['report'] as Map)['band'] = 'STANDARD';
      expect(exportSchema().validate(jsonDecode(jsonEncode(doc))).isValid, isFalse);
      expect(source.reportStatus, 'FINALIZED');
    });
  });

  group('integridad', () {
    test('si el JSON guardado se altera, la exportación se niega', () async {
      await f.db.customStatement('DROP TRIGGER report_finalized_immutable'); // simula corrupción del almacenamiento
      await f.db.customStatement("UPDATE report SET canonical_json = replace(canonical_json, 'Ventaja territorial', 'Ventaja TERRITORIAL') WHERE assessment_id = '${f.firstId}'");
      await expectLater(
        f.exporter().export(f.firstId, ExportFormat.pdf),
        throwsA(isA<ExportException>().having((e) => e.code, 'code', ExportErrorCode.integrityMismatch)),
      );
      expect(Directory('${f.dir.path}/exports').existsSync() ? Directory('${f.dir.path}/exports').listSync() : const [], isEmpty);
    });

    test('un informe sin cerrar no se exporta', () async {
      await f.db.customStatement("UPDATE assessment SET status = 'POST_MATCH' WHERE id = '${f.firstId}'");
      final src = await DriftExportRepository(f.db).loadExportSource(f.firstId);
      final draft = ExportSource(
        assessmentId: src.assessmentId, competition: src.competition, category: src.category, kickoffLocal: src.kickoffLocal,
        kickoffTz: src.kickoffTz, venue: src.venue, homeTeam: src.homeTeam, awayTeam: src.awayTeam, observationMode: src.observationMode,
        refereeId: src.refereeId, refereeName: src.refereeName, assessorId: src.assessorId, assessorName: src.assessorName,
        reportVersion: 1, reportStatus: 'DRAFT', canonicalJson: null, contentHash: null, incidents: src.incidents,
      );
      expect(() => buildExportDocument(draft, kDefaultRubric, exportedAt: DateTime.utc(2026), appVersion: 't'),
          throwsA(isA<ExportException>().having((e) => e.code, 'code', ExportErrorCode.notFinalized)));
    });
  });

  group('PDF', () {
    test('A4, estructura completa, fuentes incrustadas y pie con huella y páginas', () async {
      final out = await f.exporter().export(f.secondId, ExportFormat.pdf);
      final bytes = out.file.readAsBytesSync();
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(out.file.path, endsWith('informe_2026-10-17_club-local-rc-visitante-rt_v1.pdf'));
      final info = Process.runSync('pdfinfo', [out.file.path]).stdout as String;
      expect(info, matches(RegExp(r'Page size:\s+595\.\d+ x 841\.\d+ pts \(A4\)')));
      final fonts = Process.runSync('pdffonts', [out.file.path]).stdout as String;
      expect(fonts, contains('Roboto'));
      // Columnas de pdffonts: … emb sub uni object ID. Todas las fuentes deben estar incrustadas.
      final rows = fonts.split('\n').skip(2).where((l) => l.trim().isNotEmpty).toList();
      expect(rows, isNotEmpty);
      for (final row in rows) {
        expect(RegExp(r'\s(yes)\s+(yes|no)\s+(yes|no)\s+\d+\s+\d+\s*$').hasMatch(row), isTrue, reason: 'fuente no incrustada: $row');
      }

      final text = pdfText(out.file);
      final pages = pdfPages(out.file);
      for (final s in [
        // Cabecera
        'INFORME DE EVALUACIÓN ARBITRAL', 'Club Local RC – Visitante RT', 'Liga DHCAT · J5', 'Árbitro Ejemplo', 'Asistente Uno, Asistente Dos',
        'Evaluadora Ejemplo', '17/10/2026 · 17:00', 'Campo Municipal de La Foixarda', 'Alta (descriptiva: no modifica la evaluación)',
        // Resumen ejecutivo
        'RESUMEN EJECUTIVO', 'Banda global del partido', 'Decisiones clave acertadas: 1 de 2',
        // Desglose
        'DESGLOSE POR ÁREAS Y CRITERIOS', 'A · Gestión de fases de juego', 'D · Condición física, posicionamiento y líneas de carrera',
        'No observado', 'Sin touchs disputadas', 'Tope automático por error grave', 'Sugerencia de la app: En el nivel',
        // Hallazgos y recomendaciones
        'FORTALEZAS', 'Ventaja territorial bien leída.', 'ÁREAS DE MEJORA', 'RECOMENDACIONES PARA EL PRÓXIMO INFORME', 'Indicador de logro:',
        'SEGUIMIENTO DE RECOMENDACIONES ANTERIORES', 'Parcial',
        // Anexo e integridad
        'ANEXO · CRONOLOGÍA DE INCIDENCIAS CLAVE', 'Golpe de castigo +', 'Amarilla (contra', 'ley 19.10', 'No pitada',
        'INTEGRIDAD DEL INFORME', out.reportHash,
        // Marcador y disciplina
        'MARCADOR Y DISCIPLINA', 'Marcador: Club Local RC 24 – 19 Visitante RT', 'Transformaciones', 'Golpes de castigo',
        'Golpes de Club Local RC: 3× Fuera de juego en ruck / maul (Leyes 15 y 16) · 2× Entrada lateral (Ley 15) · 1× Sin especificar',
        'Amarilla · 12:00 · Visitante RT · Placaje alto / contacto con la cabeza',
        'Derrumbar la melé', // ley de la incidencia en el anexo (la columna estrecha parte la línea)
        // Pie
        'Informe v1 · Rúbrica RUGBY-XV-BASE 2.0.0 · SHA-256 ${out.reportHash.substring(0, 8)}…${out.reportHash.substring(56)}',
        'Página 1 de $pages', 'Página $pages de $pages',
      ]) {
        expect(text.replaceAll(RegExp(r'\s+'), ' '), contains(s), reason: 'falta en el PDF: "$s"');
      }
      expect(pages, greaterThanOrEqualTo(3));
      expect(RegExp(r'Informe v1 · Rúbrica').allMatches(text).length, pages, reason: 'pie en todas las páginas');
    }, skip: !_hasPdftotext);

    test('cero notas numéricas: no aparece ningún valor interno del informe', () async {
      final out = await f.exporter().export(f.firstId, ExportFormat.pdf);
      final doc = jsonDecode((await f.exporter().export(f.firstId, ExportFormat.json)).file.readAsStringSync()) as Map;
      final report = doc['report'] as Map;
      final internal = <String>{
        '${report['overallScore']}',
        for (final a in report['areaScores'] as List) '${a['score']}',
        for (final s in report['criterionScores'] as List) if (s['suggested'] != null) '${s['suggested']}',
      }..removeWhere((v) => v == 'null' || !v.contains('.')); // los enteros 5/7/9 se confundirían con fechas: los cubre la regla de decimales
      expect(internal, isNotEmpty, reason: 'el informe de prueba tiene medias no enteras');
      final text = pdfText(out.file).replaceAll('RUGBY-XV-BASE 2.0.0', '');
      for (final v in internal) {
        expect(text, isNot(contains(v)), reason: 'valor interno visible: $v');
      }
      expect(RegExp(r'\d+[.,]\d+').hasMatch(text.replaceAll(RegExp(r'ley \d+\.\d+', caseSensitive: false), '')), isFalse, reason: 'ninguna cifra decimal');
      expect(text, isNot(contains('%')));
    }, skip: !_hasPdftotext);

    test('sin anexo cuando el evaluador lo desactiva', () async {
      final out = await f.exporter().export(f.firstId, ExportFormat.pdf, includeIncidentAnnex: false);
      expect(pdfText(out.file), isNot(contains('ANEXO')));
    }, skip: !_hasPdftotext);

    test('cada exportación queda registrada en export_log con el SHA-256 del archivo', () async {
      final e = f.exporter();
      final a = await e.export(f.firstId, ExportFormat.pdf);
      final b = await e.export(f.firstId, ExportFormat.json);
      final rows = await f.db.select(f.db.exportLog).get();
      expect(rows.map((r) => (r.format, r.sha256, r.version)).toList(), [('PDF', a.sha256, 1), ('JSON', b.sha256, 1)]);
      expect(rows.first.relativePath, 'exports/informe_2026-10-17_club-local-rc-visitante-rt_v1.pdf');
    });
  });

  test('mensaje de envío con la huella del informe', () {
    final (subject, text) = shareMessage('Local', 'Visitante', 'abc123', [ExportFormat.pdf, ExportFormat.json]);
    expect(subject, 'Informe de evaluación arbitral · Local – Visitante');
    expect(text, contains('(PDF y JSON)'));
    expect(text, contains('SHA-256 del informe: abc123'));
  });

  group('versión HTML (descarga en lugar de compartir)', () {
    test('render no escribe en disco; renderForDownload lo registra en export_log como descarga', () async {
      final r = await f.exporter().render(f.firstId, ExportFormat.pdf);
      expect(String.fromCharCodes(r.bytes.take(5)), '%PDF-');
      expect(r.fileName, endsWith('_v1.pdf'));
      expect(r.mimeType, 'application/pdf');
      expect(r.sha256, sha256.convert(r.bytes).toString());
      expect(Directory('${f.dir.path}/exports').existsSync(), isFalse, reason: 'nada escrito en disco');
      final d = await f.exporter().renderForDownload(f.firstId, ExportFormat.json);
      final log = await (f.db.select(f.db.exportLog)..where((t) => t.assessmentId.equals(f.firstId))).get();
      expect(log.single.relativePath, 'download/${d.fileName}');
      expect(log.single.sha256, d.sha256);
    });

    test('el controlador entrega PDF + JSON en memoria y muestra sus nombres', () async {
      final sink = _MemorySharer();
      final c = ExportController(
        assessmentId: f.firstId,
        exporter: f.exporter(),
        sharer: const SystemFileSharer(), // no debe usarse
        bytesSharer: sink,
        homeTeam: 'Club Local RC',
        awayTeam: 'Visitante RT',
      );
      await c.share(const [ExportFormat.pdf, ExportFormat.json]);
      expect(c.error, isNull);
      expect(sink.files.map((r) => r.format), [ExportFormat.pdf, ExportFormat.json]);
      expect(c.lastSharedNames, [for (final r in sink.files) r.fileName]);
      expect(jsonDecode(utf8.decode(sink.files.last.bytes))['formatVersion'], '2.1');
      c.dispose();
    });
  });
}

String _canonical(Object? v) {
  if (v == null || v is bool || v is String) return jsonEncode(v);
  if (v is num) return v is double && v == v.truncateToDouble() ? v.toInt().toString() : jsonEncode(v);
  if (v is List) return '[${v.map(_canonical).join(',')}]';
  final m = v as Map;
  final keys = m.keys.cast<String>().toList()..sort();
  return '{${keys.map((k) => '${jsonEncode(k)}:${_canonical(m[k])}').join(',')}}';
}

class _MemorySharer implements BytesSharer {
  final List<RenderedExport> files = [];
  @override
  Future<void> shareBytes(List<RenderedExport> files) async => this.files.addAll(files);
}
