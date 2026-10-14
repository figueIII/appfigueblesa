// PDF del informe cerrado (A4, paquete `pdf`). Se genera a partir del documento de exportación
// (export_document.dart): lo que se imprime es exactamente lo firmado. PURO salvo las fuentes, que
// llegan ya cargadas (assets incrustados: funciona sin conexión).
//
// Reglas de contenido (resolución R2): ninguna nota numérica. Las bandas (E / C / N / U del CARC) se
// muestran con letra, texto y un indicador de nivel de cuatro casillas (dibujado, no tipográfico),
// legible también en blanco y negro. Los textos del CARC salen en el idioma elegido en la app.

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/i18n.dart';
import '../data/codecs.dart';
import '../domain/report.dart';
import '../domain/rubric.dart';
import '../features/evaluation/evaluation_labels.dart';
import '../features/live/live_labels.dart';
import '../features/review/review_labels.dart';
import 'export_document.dart';

class PdfFonts {
  const PdfFonts({required this.regular, required this.medium, required this.bold, required this.italic});
  final pw.Font regular;
  final pw.Font medium;
  final pw.Font bold;
  final pw.Font italic;

  factory PdfFonts.fromBytes({required ByteData regular, required ByteData medium, required ByteData bold, required ByteData italic}) =>
      PdfFonts(regular: pw.Font.ttf(regular), medium: pw.Font.ttf(medium), bold: pw.Font.ttf(bold), italic: pw.Font.ttf(italic));
}

// ───────────── Paleta de impresión (sobria; contraste alto también en B/N) ─────────────

const _ink = PdfColor.fromInt(0xFF0F172A);
const _muted = PdfColor.fromInt(0xFF334155);
const _rule = PdfColor.fromInt(0xFF94A3B8);
const _panel = PdfColor.fromInt(0xFFF1F5F9);
const _accent = PdfColor.fromInt(0xFF1E40AF);

PdfColor _bandFill(BandCode b) => switch (b) {
      BandCode.excellent => const PdfColor.fromInt(0xFF166534),
      BandCode.competent => _ink,
      BandCode.notYet => const PdfColor.fromInt(0xFF92400E),
      BandCode.urgent => const PdfColor.fromInt(0xFF991B1B),
    };

BandCode? _band(Object? code) => decodeBand(code as String?);

String _difficultyLabel(String? d) => d == null ? 'No indicada' : difficultyText(d);

String _observationLabel(String m) => switch (m) {
      'LIVE' => 'En directo',
      'VIDEO' => 'En vídeo',
      'LIVE_AND_VIDEO' => 'En directo y en vídeo',
      _ => m,
    };

String _reviewStatus(String s) => switch (s) {
      'ACHIEVED' => 'Lograda',
      'PARTIAL' => 'Parcial',
      'NOT_ACHIEVED' => 'No lograda',
      'NOT_OBSERVED' => 'No observada',
      _ => s,
    };

String _decisionText(Object? d) {
  if (d is! Map) return '—';
  final outcomes = [for (final o in (d['outcomes'] as List? ?? const [])) outcomeLabel(decodeOutcome(o as String))];
  final against = switch (d['againstTeam']) {
    'HOME' => ' (contra local)',
    'AWAY' => ' (contra visitante)',
    _ => '',
  };
  final law = d['lawRef'] == null ? '' : ' · ley ${d['lawRef']}';
  return outcomes.isEmpty ? '—' : '${outcomes.join(' + ')}$against$law';
}

/// Genera el PDF. `includeIncidentAnnex` añade la cronología de incidencias clave (impacto alto
/// o decisivo).
Future<Uint8List> buildReportPdf(
  Map<String, Object?> doc,
  AssessmentRubric rubric,
  PdfFonts fonts, {
  bool includeIncidentAnnex = true,
}) {
  final match = doc['match']! as Map<String, Object?>;
  final report = doc['report']! as Map<String, Object?>;
  final integrity = doc['integrity']! as Map<String, Object?>;
  final hash = integrity['contentHash']! as String;
  final version = report['version'];
  final category = match['category']! as Map<String, Object?>;
  final home = (match['home']! as Map)['name'] as String;
  final away = (match['away']! as Map)['name'] as String;

  final theme = pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold, italic: fonts.italic);
  final pdf = pw.Document(
    theme: theme,
    title: 'Informe de evaluación arbitral · $home – $away',
    author: (doc['assessor']! as Map)['fullName'] as String,
    creator: 'RefAssess',
    subject: 'Evaluación del árbitro principal',
    keywords: 'sha256:$hash',
  );

  pw.TextStyle st(double size, {pw.Font? font, PdfColor color = _ink, double? height}) =>
      pw.TextStyle(font: font ?? fonts.regular, fontSize: size, color: color, lineSpacing: height ?? 1.5);

  final criteriaByCode = {for (final c in rubric.criteria) c.code: c};
  String criterionName(String code) {
    final c = criteriaByCode[code];
    if (c == null) return code;
    return [code.substring(0, 2), ?c.levelLabel, c.label].join(' · ');
  }

  String bandText(BandCode b) => bandFullLabel(rubric, b);

  // ───────────── Piezas reutilizables ─────────────

  pw.Widget gauge(BandCode? band, {double cell = 9}) => pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          for (final (i, b) in BandCode.values.indexed) ...[
            if (i > 0) pw.SizedBox(width: 2),
            pw.Container(
              width: cell * 1.6,
              height: cell,
              decoration: pw.BoxDecoration(
                color: band == b ? _bandFill(b) : PdfColors.white,
                border: pw.Border.all(color: band == b ? _bandFill(b) : _rule, width: 0.8),
              ),
            ),
          ],
        ],
      );

  /// Indicador + texto en una columna: para celdas estrechas (la etiqueta nunca se corta).
  pw.Widget bandStacked(BandCode? band, {double size = 8.5}) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          gauge(band, cell: size * 0.8),
          pw.SizedBox(height: 2),
          pw.Text(band == null ? 'Sin valorar' : bandText(band),
              style: st(size, font: fonts.bold, color: band == null ? _muted : _bandFill(band), height: 1.2)),
        ],
      );

  pw.Widget bandLabel(BandCode? band, {double size = 10, bool bold = true}) => pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          gauge(band, cell: size * 0.8),
          pw.SizedBox(width: 6),
          pw.Text(band == null ? 'Sin valorar' : bandText(band),
              style: st(size, font: bold ? fonts.bold : fonts.medium, color: band == null ? _muted : _bandFill(band))),
        ],
      );

  pw.Widget sectionTitle(String text) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 14, bottom: 6),
        padding: const pw.EdgeInsets.only(bottom: 3),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _ink, width: 1.2))),
        child: pw.Text(text.toUpperCase(), style: st(10.5, font: fonts.bold).copyWith(letterSpacing: 0.6)),
      );

  pw.Widget kv(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(width: 95, child: pw.Text(k, style: st(8.5, font: fonts.medium, color: _muted))),
            pw.Expanded(child: pw.Text(v, style: st(9))),
          ],
        ),
      );

  // ───────────── Contenido ─────────────

  final finalizedAt = DateTime.tryParse('${report['finalizedAt']}')?.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  final closedText = finalizedAt == null
      ? '—'
      : '${two(finalizedAt.day)}/${two(finalizedAt.month)}/${finalizedAt.year} · ${two(finalizedAt.hour)}:${two(finalizedAt.minute)}';
  final assistants = match['assistants'] as Map?;
  final score = match['finalScore'] as Map?;
  final referee = doc['referee']! as Map;
  final assessor = doc['assessor']! as Map;

  final header = <pw.Widget>[
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('INFORME DE EVALUACIÓN ARBITRAL', style: st(8.5, font: fonts.bold, color: _accent).copyWith(letterSpacing: 1.2)),
              pw.SizedBox(height: 3),
              pw.Text('$home – $away', style: st(19, font: fonts.bold, height: 1.1)),
              pw.SizedBox(height: 2),
              pw.Text(
                [match['competition'], if (match['round'] != null) match['round'], category['name']].join(' · '),
                style: st(10, color: _muted),
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: _ink, width: 1)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Informe v$version', style: st(9, font: fonts.bold)),
              pw.Text(report['status'] == 'FINALIZED' ? 'Cerrado' : 'Sustituido', style: st(8, color: _muted)),
            ],
          ),
        ),
      ],
    ),
    pw.SizedBox(height: 10),
    pw.Container(
      padding: const pw.EdgeInsets.all(10),
      color: _panel,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(children: [
              kv('Árbitro', [referee['fullName'], if (referee['federationLicence'] != null) 'lic. ${referee['federationLicence']}'].join(' · ')),
              kv('Asistentes', assistants == null ? '—' : '${[assistants['ar1'], assistants['ar2']].whereType<String>().join(', ')} (no evaluados)'),
              kv('Evaluador', assessor['fullName'] as String),
              kv('Observación', _observationLabel(match['observationMode']! as String)),
            ]),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(children: [
              kv('Fecha y hora', '${formatKickoff((match['kickoff']! as Map)['local'] as String)} (${(match['kickoff']! as Map)['tz']})'),
              kv('Campo', match['venue']! as String),
              kv('Categoría', '${category['name']} · partes de ${category['periodLengthMin']} min'),
              if (score != null) kv('Resultado', '$home ${score['home']} – ${score['away']} $away'),
              kv('Dificultad estimada', _difficultyLabel(match['difficulty'] as String?)),
              kv('Dificultad real', _difficultyLabel(report['actualDifficulty'] as String?)),
              kv('Cierre', closedText),
            ]),
          ),
        ],
      ),
    ),
  ];

  // Resumen ejecutivo
  final globalBand = _band(report['band']);
  final areaScores = [for (final a in report['areaScores']! as List) a as Map];
  final keys = report['keyDecisionAccuracy']! as Map;
  final recommendation = decodeLevelRecommendation(report['levelRecommendation'] as String?);
  final summaryText = (report['summary'] as String?) ?? '';
  final summary = <pw.Widget>[
    sectionTitle('Resumen ejecutivo'),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 190,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: globalBand == null ? _rule : _bandFill(globalBand), width: 2)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(tr('Valoración global', 'Valoració global'), style: st(8.5, font: fonts.medium, color: _muted)),
              pw.SizedBox(height: 6),
              bandLabel(globalBand, size: 13),
              pw.SizedBox(height: 4),
              pw.Text(globalBand == null ? '' : rubric.band(globalBand).help, style: st(8.5, color: _muted)),
              pw.SizedBox(height: 8),
              pw.Text(tr('Recomendación', 'Recomanació'), style: st(8.5, font: fonts.medium, color: _muted)),
              pw.SizedBox(height: 2),
              pw.Text(
                recommendation == null
                    ? 'No indicada'
                    : '${levelRecommendationLabel(recommendation).$1}  ${levelRecommendationLabel(recommendation).$2}',
                style: st(9.5, font: fonts.bold),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final area in rubric.areas)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(children: [
                    pw.Expanded(child: pw.Text('${area.letter} · ${area.label}', style: st(9))),
                    bandLabel(_band(areaScores.firstWhere((a) => a['areaCode'] == area.code)['band']), size: 9),
                  ]),
                ),
              pw.SizedBox(height: 4),
              pw.Text(
                keys['total'] == 0
                    ? 'Decisiones clave: ninguna valorada (impacto alto o decisivo).'
                    : 'Decisiones clave acertadas: ${keys['correct']} de ${keys['total']} (impacto alto o decisivo).',
                style: st(9, font: fonts.medium),
              ),
            ],
          ),
        ),
      ],
    ),
    if (summaryText.trim().isNotEmpty) ...[pw.SizedBox(height: 8), pw.Text(summaryText, style: st(9.5))],
    pw.SizedBox(height: 4),
    pw.Text(
      'Escala: ${[for (final b in rubric.bands) bandText(b.code)].join(' · ')}',
      style: st(8, color: _muted),
    ),
  ];

  // Desglose por áreas y criterios
  final scores = {for (final s in report['criterionScores']! as List) (s as Map)['criterionCode'] as String: s};
  final breakdown = <pw.Widget>[sectionTitle(tr('Desglose por áreas y competencias', 'Desglossament per àrees i competències'))];
  for (final area in rubric.areas) {
    // Título del área + su tabla en un bloque que no se parte: nunca queda una cabecera huérfana.
    final block = <pw.Widget>[];
    block.add(pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
      child: pw.Row(children: [
        pw.Expanded(child: pw.Text('${area.letter} · ${area.label}', style: st(10.5, font: fonts.bold))),
        bandLabel(_band(areaScores.firstWhere((a) => a['areaCode'] == area.code)['band']), size: 9),
      ]),
    ));
    block.add(pw.Table(
      border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _rule, width: 0.5), bottom: pw.BorderSide(color: _rule, width: 0.5)),
      columnWidths: const {0: pw.FlexColumnWidth(2.1), 1: pw.FlexColumnWidth(1.6), 2: pw.FlexColumnWidth(4.7)},
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _panel),
          children: [
            for (final h in [tr('Competencia', 'Competència'), tr('Valoración', 'Valoració'), 'Justificación'])
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(h, style: st(8, font: fonts.bold, color: _muted))),
          ],
        ),
        for (final c in area.criteria)
          () {
            final s = scores[c.code]!;
            final notObserved = s['notObserved'] == true;
            final finalBand = _band(s['finalBand']);
            final suggested = _band(s['suggestedBand']);
            final cap = _band(s['capBand']);
            final notes = [
              if (suggested != null && suggested != finalBand && !notObserved) 'Sugerencia de la app: ${bandText(suggested)}.',
              if (cap != null) 'Tope automático por error grave: máximo ${bandText(cap)}.',
            ];
            return pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.top,
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(criterionName(c.code), style: st(8.5, font: fonts.medium))),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: notObserved ? pw.Text('No observado', style: st(8.5, font: fonts.medium, color: _muted)) : bandStacked(finalBand),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text((s['justification'] as String).trim().isEmpty ? '—' : s['justification'] as String, style: st(8.5)),
                      for (final n in notes) pw.Text(n, style: st(7.5, font: fonts.italic, color: _muted)),
                    ],
                  ),
                ),
              ],
            );
          }(),
      ],
    ));
    breakdown.add(pw.Inseparable(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: block)));
  }

  // Fortalezas, áreas de mejora, recomendaciones y seguimiento
  pw.Widget bullet(String head, String body) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('•  ', style: st(9.5, font: fonts.bold)),
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(children: [
                pw.TextSpan(text: '$head  ', style: st(9, font: fonts.bold)),
                pw.TextSpan(text: body, style: st(9.5)),
              ]),
            ),
          ),
        ]),
      );

  // Todo es opcional: una sección sin contenido no se imprime.
  final strengths = report['strengths']! as List;
  final development = report['developmentAreas']! as List;
  final actionPoints = report['actionPoints']! as List;
  final findings = <pw.Widget>[
    if (strengths.isNotEmpty) sectionTitle('Fortalezas'),
    for (final f in strengths) bullet(criterionName((f as Map)['criterionCode'] as String), f['text'] as String),
    if (development.isNotEmpty) sectionTitle('Áreas de mejora'),
    for (final f in development) bullet(criterionName((f as Map)['criterionCode'] as String), f['text'] as String),
    if (actionPoints.isNotEmpty) sectionTitle('Recomendaciones para el próximo informe'),
    for (final (i, a) in actionPoints.indexed)
      pw.Container(
        width: double.infinity,
        margin: const pw.EdgeInsets.only(bottom: 6),
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: _rule, width: 0.8)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('Recomendación ${i + 1} · ${criterionName((a as Map)['criterionCode'] as String)}', style: st(8.5, font: fonts.bold, color: _muted)),
          pw.SizedBox(height: 2),
          pw.Text(a['text'] as String, style: st(9.5, font: fonts.medium)),
          if ((a['successIndicator'] as String? ?? '').trim().isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.RichText(
              text: pw.TextSpan(children: [
                pw.TextSpan(text: 'Indicador de logro: ', style: st(8.5, font: fonts.bold)),
                pw.TextSpan(text: a['successIndicator'] as String, style: st(8.5)),
              ]),
            ),
          ],
        ]),
      ),
    if ((report['previousActionPointReviews']! as List).isNotEmpty) ...[
      sectionTitle('Seguimiento de recomendaciones anteriores'),
      pw.Table(
        border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _rule, width: 0.5), bottom: pw.BorderSide(color: _rule, width: 0.5)),
        columnWidths: const {0: pw.FlexColumnWidth(4), 1: pw.FlexColumnWidth(1.3), 2: pw.FlexColumnWidth(3.2)},
        children: [
          pw.TableRow(decoration: const pw.BoxDecoration(color: _panel), children: [
            for (final h in ['Recomendación', 'Estado', 'Comentario'])
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(h, style: st(8, font: fonts.bold, color: _muted))),
          ]),
          for (final r in report['previousActionPointReviews']! as List)
            pw.TableRow(children: [
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text((r as Map)['text'] as String, style: st(8.5))),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(_reviewStatus(r['status'] as String), style: st(8.5, font: fonts.bold))),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text((r['comment'] as String).isEmpty ? '—' : r['comment'] as String, style: st(8.5))),
            ]),
        ],
      ),
    ],
  ];

  // Anexo: incidencias clave en orden cronológico
  final keyIncidents = [
    for (final i in doc['incidents']! as List)
      if ((i as Map)['impact'] == 'HIGH' || i['impact'] == 'MATCH_DEFINING') i,
  ];
  final annex = <pw.Widget>[
    if (includeIncidentAnnex) ...[
      pw.NewPage(),
      sectionTitle('Anexo · Cronología de incidencias clave'),
      pw.Text('Incidencias de impacto alto o decisivo valoradas durante la revisión post-partido.', style: st(8.5, color: _muted)),
      pw.SizedBox(height: 6),
      if (keyIncidents.isEmpty)
        pw.Text('No hubo incidencias clave en este partido.', style: st(9))
      else
        pw.Table(
          border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _rule, width: 0.5), bottom: pw.BorderSide(color: _rule, width: 0.5)),
          columnWidths: const {
            0: pw.FlexColumnWidth(0.8),
            1: pw.FlexColumnWidth(1.4),
            2: pw.FlexColumnWidth(1.7),
            3: pw.FlexColumnWidth(1.7),
            4: pw.FlexColumnWidth(1.2),
            5: pw.FlexColumnWidth(2.6),
          },
          children: [
            pw.TableRow(decoration: const pw.BoxDecoration(color: _panel), children: [
              for (final h in ['Min.', 'Acción', 'Decisión tomada', 'Decisión esperada', 'Valoración', 'Notas'])
                pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(h, style: st(7.5, font: fonts.bold, color: _muted))),
            ]),
            for (final i in keyIncidents)
              pw.TableRow(verticalAlignment: pw.TableCellVerticalAlignment.top, children: [
                pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(i['matchClock'] as String, style: st(8, font: fonts.bold))),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(3),
                  child: pw.Text(
                    '${kCategoryLabel[decodeCategory(i['category'] as String)]}\n${criterionName(i['criterionCode'] as String)}'
                    '${i['infraction'] == null ? '' : '\n${(i['infraction'] as Map)['label']}${(i['infraction'] as Map)['lawRef'] == null ? '' : ' (${(i['infraction'] as Map)['lawRef']})'}'}',
                    style: st(8),
                  ),
                ),
                pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(_decisionText(i['decisionTaken']), style: st(8))),
                pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(_decisionText(i['decisionExpected']), style: st(8))),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(3),
                  child: pw.Text(
                    '${verdictLabel(decodeVerdict(i['verdict'] as String))}\n${impactLabel(decodeImpact(i['impact'] as String))}',
                    style: st(8, font: fonts.medium),
                  ),
                ),
                pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text((i['notes'] as String?) ?? '—', style: st(8))),
              ]),
          ],
        ),
    ],
  ];

  // Marcador y disciplina (datos del partido registrados en directo; no forman parte del informe firmado)
  final stats = doc['matchStats'] as Map?;
  final statScore = stats?['score'] as Map?;
  final statSanctions = stats?['sanctions'] as Map?;
  pw.Widget statTable(List<String> rowLabels, List<int> Function(String side) values) => pw.Table(
        border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _rule, width: 0.5), bottom: pw.BorderSide(color: _rule, width: 0.5)),
        columnWidths: const {0: pw.FlexColumnWidth(2.4), 1: pw.FlexColumnWidth(1), 2: pw.FlexColumnWidth(1)},
        children: [
          pw.TableRow(decoration: const pw.BoxDecoration(color: _panel), children: [
            for (final h in ['', home, away])
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(h, style: st(8, font: fonts.bold, color: _muted))),
          ]),
          for (final (i, label) in rowLabels.indexed)
            pw.TableRow(children: [
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(label, style: st(8.5, font: fonts.medium))),
              for (final side in ['home', 'away'])
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${values(side)[i]}', style: st(8.5, font: fonts.bold))),
            ]),
        ],
      );
  int scoreCount(String side, String kind) =>
      (statScore!['events'] as List).where((e) => (e as Map)['team'] == side.toUpperCase() && e['kind'] == kind).length;
  final statsBlock = <pw.Widget>[
    if (stats != null) ...[
      sectionTitle('Marcador y disciplina'),
      pw.Text('Datos del partido registrados en directo por el evaluador. Son contexto: no modifican la evaluación.', style: st(8.5, color: _muted)),
      pw.SizedBox(height: 6),
      // Título + tabla en un bloque que no se parte: nunca queda una cabecera huérfana.
      if (statScore != null)
        pw.Inseparable(
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
            pw.Text('Marcador: $home ${statScore['home']} – ${statScore['away']} $away', style: st(10, font: fonts.bold)),
            pw.SizedBox(height: 4),
            statTable(
              const ['Ensayos', 'Transformaciones', 'Golpes a palos', 'Drops', 'Puntos'],
              (side) => [
                for (final k in const ['TRY', 'CONVERSION', 'PENALTY_GOAL', 'DROP_GOAL']) scoreCount(side, k),
                statScore[side] as int,
              ],
            ),
            pw.SizedBox(height: 8),
          ]),
        ),
      if (statSanctions != null) ...[
        pw.Inseparable(
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
            pw.Text('Sanciones del árbitro (contra el equipo infractor)', style: st(10, font: fonts.bold)),
            pw.SizedBox(height: 4),
            statTable(
              const ['Golpes de castigo', 'Golpes francos', 'Tarjetas amarillas', 'Tarjetas rojas'],
              (side) => [
                for (final k in const ['PENALTY', 'FREE_KICK', 'YELLOW_CARD', 'RED_CARD'])
                  ((statSanctions['totals'] as Map)[side] as Map)[k] as int,
              ],
            ),
          ]),
        ),
        pw.SizedBox(height: 6),
        for (final side in const ['home', 'away'])
          if (((statSanctions['breakdown'] as Map)[side] as List).isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.RichText(
                text: pw.TextSpan(children: [
                  pw.TextSpan(text: 'Golpes de ${side == 'home' ? home : away}: ', style: st(8.5, font: fonts.bold)),
                  pw.TextSpan(
                    text: [
                      for (final r in (statSanctions['breakdown'] as Map)[side] as List)
                        '${(r as Map)['penalties'] + r['freeKicks']}× ${r['label']}${r['lawRef'] == null ? '' : ' (${r['lawRef']})'}',
                    ].join(' · '),
                    style: st(8.5),
                  ),
                ]),
              ),
            ),
        for (final e in statSanctions['events'] as List)
          if ((e as Map)['kind'] == 'YELLOW_CARD' || e['kind'] == 'RED_CARD')
            pw.Text(
              '${e['kind'] == 'YELLOW_CARD' ? 'Amarilla' : 'Roja'} · ${e['matchClock']} · ${e['team'] == 'HOME' ? home : away}'
              ' · ${(e['infraction'] as Map?)?['label'] ?? 'Sin especificar'}',
              style: st(8.5),
            ),
      ],
    ],
  ];

  // Integridad (al final del cuerpo, completa)
  final integrityBlock = <pw.Widget>[
    sectionTitle('Integridad del informe'),
    pw.Text(
      'Huella SHA-256 del informe cerrado (JSON canónico, ${integrity['canonicalization']}). '
      'Cualquier cambio en el contenido evaluado produce una huella distinta; '
      'puede verificarse con la exportación JSON de este mismo informe.',
      style: st(8.5, color: _muted),
    ),
    pw.SizedBox(height: 4),
    pw.Text(hash, style: st(8.5, font: fonts.bold)),
  ];

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(18 * PdfPageFormat.mm, 16 * PdfPageFormat.mm, 18 * PdfPageFormat.mm, 14 * PdfPageFormat.mm),
    header: (ctx) => ctx.pageNumber == 1
        ? pw.SizedBox()
        : pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.only(bottom: 3),
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _rule, width: 0.5))),
            child: pw.Text('Informe de evaluación arbitral · $home – $away · ${referee['fullName']}', style: st(7.5, color: _muted)),
          ),
    footer: (ctx) => pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 3),
      decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _rule, width: 0.5))),
      child: pw.Row(children: [
        pw.Expanded(
          child: pw.Text(
            'Informe v$version · Rúbrica ${(doc['rubric']! as Map)['code']} ${(doc['rubric']! as Map)['version']} · '
            'SHA-256 ${hash.substring(0, 8)}…${hash.substring(hash.length - 8)}',
            style: st(7.5, color: _muted),
          ),
        ),
        pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}', style: st(7.5, font: fonts.medium, color: _muted)),
      ]),
    ),
    build: (ctx) => [...header, ...summary, ...breakdown, ...findings, ...statsBlock, ...integrityBlock, ...annex],
  ));
  return pdf.save();
}
