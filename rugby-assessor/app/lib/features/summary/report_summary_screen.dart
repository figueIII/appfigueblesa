import 'package:flutter/material.dart';

import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/i18n.dart';
import '../../domain/report.dart';
import '../../domain/rubric.dart';
import '../../export/export_document.dart';
import '../evaluation/evaluation_labels.dart';
import '../evaluation/export_controller.dart';
import '../evaluation/widgets/band_widgets.dart';
import '../evaluation/widgets/export_section.dart';

/// Lo que necesita el resumen: el documento de exportación del informe cerrado (el mismo que se
/// imprime en el PDF y se guarda en el JSON) y la rúbrica con la que se cerró.
typedef SummaryData = (Map<String, Object?> document, AssessmentRubric rubric);

/// Resumen de un informe cerrado: árbitro y partido, marcador, golpes y tarjetas, valoración
/// (global, por áreas, dificultad y recomendación) y lo escrito en el informe. Desde aquí se
/// exporta, se abre el informe completo o se vuelve al menú.
///
/// Se lee del documento de exportación: lo que se ve aquí es exactamente lo firmado.
class ReportSummaryScreen extends StatefulWidget {
  const ReportSummaryScreen({super.key, required this.load, required this.onBackToMenu, required this.onOpenFullReport, this.createExport});

  final Future<SummaryData> Function() load;
  final VoidCallback onBackToMenu;
  final VoidCallback onOpenFullReport;
  final ExportController Function(String homeTeam, String awayTeam)? createExport;

  @override
  State<ReportSummaryScreen> createState() => _ReportSummaryScreenState();
}

class _ReportSummaryScreenState extends State<ReportSummaryScreen> {
  SummaryData? _data;
  Object? _error;
  ExportController? _export;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _export?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final d = await widget.load();
      if (!mounted) return;
      final match = d.$1['match']! as Map;
      _export ??= widget.createExport?.call((match['home']! as Map)['name'] as String, (match['away']! as Map)['name'] as String);
      setState(() => _data = d);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final data = _data;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.onSurface,
        title: Text(tr('Resumen del informe', "Resum de l'informe")),
        actions: [
          IconButton(
            key: const ValueKey('summary-home'),
            tooltip: tr('Volver al menú', 'Tornar al menú'),
            onPressed: widget.onBackToMenu,
            icon: const Icon(Icons.home_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: switch ((data, _error)) {
          (_, final Object e) => _Failed(error: '$e', onRetry: _load),
          (null, _) => Center(child: CircularProgressIndicator(color: c.primary)),
          (final SummaryData d, _) => _SummaryBody(
            document: d.$1,
            rubric: d.$2,
            export: _export,
            onBackToMenu: widget.onBackToMenu,
            onOpenFullReport: widget.onOpenFullReport,
          ),
        },
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.document,
    required this.rubric,
    required this.export,
    required this.onBackToMenu,
    required this.onOpenFullReport,
  });

  final Map<String, Object?> document;
  final AssessmentRubric rubric;
  final ExportController? export;
  final VoidCallback onBackToMenu;
  final VoidCallback onOpenFullReport;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final match = document['match']! as Map;
    final report = document['report']! as Map;
    final home = (match['home']! as Map)['name'] as String;
    final away = (match['away']! as Map)['name'] as String;
    final category = match['category']! as Map;
    final stats = document['matchStats'] as Map?;
    final score = stats?['score'] as Map?;
    final finalScore = match['finalScore'] as Map?;
    final sanctions = stats?['sanctions'] as Map?;
    final incidents = [for (final i in document['incidents']! as List) i as Map];
    final keys = report['keyDecisionAccuracy']! as Map;
    final areaScores = [for (final a in report['areaScores']! as List) a as Map];
    final recommendation = decodeLevelRecommendation(report['levelRecommendation'] as String?);
    final strengths = report['strengths']! as List;
    final development = report['developmentAreas']! as List;
    final actionPoints = report['actionPoints']! as List;
    final summaryText = (report['summary'] as String?)?.trim() ?? '';
    String nameOf(String side) => side == 'home' ? home : away;
    int verdicts(String v) => incidents.where((i) => i['verdict'] == v).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(RefSpace.l, RefSpace.l, RefSpace.l, RefSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Árbitro y partido ───
          _Card(
            key: const ValueKey('summary-match'),
            children: [
              Text(tr('Árbitro', 'Àrbitre'), style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
              Text(
                '${(document['referee']! as Map)['fullName']}',
                key: const ValueKey('summary-referee'),
                style: RefType.control.copyWith(color: c.onSurface, fontSize: 22),
              ),
              const SizedBox(height: RefSpace.s),
              Text(
                '$home – $away',
                style: RefType.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w700),
              ),
              Text(
                <Object?>{match['competition'], if (match['round'] != null) match['round'], category['name']}.join(' · '),
                style: RefType.caption.copyWith(color: c.onSurfaceMuted),
              ),
              Text(
                '${formatKickoff((match['kickoff']! as Map)['local'] as String)} · ${match['venue']}',
                style: RefType.caption.copyWith(color: c.onSurfaceMuted),
              ),
              Text(
                '${tr('Evaluador', 'Avaluador')}: ${(document['assessor']! as Map)['fullName']}',
                style: RefType.caption.copyWith(color: c.onSurfaceMuted),
              ),
            ],
          ),

          // ─── Valoración ───
          _Title(tr('Valoración', 'Valoració')),
          _Card(
            key: const ValueKey('summary-assessment'),
            children: [
              BandBadge(key: const ValueKey('summary-band'), band: decodeBand(report['band'] as String?), rubric: rubric, large: true),
              const SizedBox(height: RefSpace.m),
              for (final area in rubric.areas)
                Padding(
                  padding: const EdgeInsets.only(bottom: RefSpace.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${area.letter} · ${area.label}', style: RefType.caption.copyWith(color: c.onSurface)),
                      ),
                      const SizedBox(width: RefSpace.s),
                      Flexible(
                        child: BandBadge(
                          band: decodeBand(areaScores.where((a) => a['areaCode'] == area.code).firstOrNull?['band'] as String?),
                          rubric: rubric,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: RefSpace.s),
              _Line(
                icon: Icons.trending_up_rounded,
                label: tr('Recomendación', 'Recomanació'),
                value: recommendation == null
                    ? tr('No indicada', 'No indicada')
                    : '${levelRecommendationLabel(recommendation).$1}  ${levelRecommendationLabel(recommendation).$2}',
                valueKey: const ValueKey('summary-recommendation'),
              ),
              _Line(
                icon: Icons.speed_rounded,
                label: tr('Dificultad estimada', 'Dificultat estimada'),
                value: match['difficulty'] == null ? tr('No indicada', 'No indicada') : difficultyText(match['difficulty'] as String),
              ),
              _Line(
                icon: Icons.speed_rounded,
                label: tr('Dificultad real', 'Dificultat real'),
                value: report['actualDifficulty'] == null
                    ? tr('No indicada', 'No indicada')
                    : difficultyText(report['actualDifficulty'] as String),
                valueKey: const ValueKey('summary-actual-difficulty'),
              ),
              _Line(
                icon: Icons.gavel_rounded,
                label: tr('Decisiones clave', 'Decisions clau'),
                value: keys['total'] == 0
                    ? tr('ninguna valorada', 'cap valorada')
                    : tr('${keys['correct']} de ${keys['total']} acertadas', '${keys['correct']} de ${keys['total']} encertades'),
              ),
              _Line(
                icon: Icons.flag_rounded,
                label: tr('Marcas', 'Marques'),
                value: tr(
                  '${incidents.length} · ${verdicts('CORRECT')} correctas, ${verdicts('INCORRECT')} incorrectas, '
                      '${verdicts('MISSED')} no pitadas, ${verdicts('DEBATABLE')} discutibles'
                    '${verdicts('PENDING') > 0 ? ', ${verdicts('PENDING')} sin valorar' : ''}',
                  '${incidents.length} · ${verdicts('CORRECT')} correctes, ${verdicts('INCORRECT')} incorrectes, '
                      '${verdicts('MISSED')} no xiulades, ${verdicts('DEBATABLE')} discutibles'
                    '${verdicts('PENDING') > 0 ? ', ${verdicts('PENDING')} sense valorar' : ''}',
                ),
              ),
            ],
          ),

          // ─── Marcador ───
          _Title(tr('Marcador', 'Marcador')),
          _Card(
            key: const ValueKey('summary-score'),
            children: [
              if (score == null && finalScore == null)
                Text(
                  tr('No se registró el marcador.', "No es va registrar el marcador."),
                  style: RefType.body.copyWith(color: c.onSurfaceMuted),
                )
              else ...[
                Text(
                  '$home  ${(score ?? finalScore)!['home']} – ${(score ?? finalScore)!['away']}  $away',
                  key: const ValueKey('summary-scoreline'),
                  textAlign: TextAlign.center,
                  style: RefType.control.copyWith(color: c.onSurface, fontSize: 22),
                ),
                if (score != null) ...[
                  const SizedBox(height: RefSpace.s),
                  _Table(
                    home: home,
                    away: away,
                    rows: [
                      for (final (k, label) in [
                        ('TRY', tr('Ensayos', 'Assajos')),
                        ('CONVERSION', tr('Transformaciones', 'Transformacions')),
                        ('PENALTY_GOAL', tr('Golpes a palos', 'Cops de càstig a pals')),
                        ('DROP_GOAL', 'Drops'),
                      ])
                        (
                          label,
                          [
                            for (final side in const ['HOME', 'AWAY'])
                              (score['events'] as List).where((e) => (e as Map)['team'] == side && e['kind'] == k).length,
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ],
          ),

          // ─── Disciplina ───
          _Title(tr('Golpes y tarjetas', 'Cops i targetes')),
          _Card(
            key: const ValueKey('summary-discipline'),
            children: [
              if (sanctions == null)
                Text(
                  tr('No se registraron sanciones.', "No es van registrar sancions."),
                  style: RefType.body.copyWith(color: c.onSurfaceMuted),
                )
              else ...[
                _Table(
                  home: home,
                  away: away,
                  rows: [
                    for (final (k, label) in [
                      ('PENALTY', tr('Golpes de castigo', 'Cops de càstig')),
                      ('FREE_KICK', tr('Golpes francos', 'Cops francs')),
                      ('YELLOW_CARD', tr('Tarjetas amarillas', 'Targetes grogues')),
                      ('RED_CARD', tr('Tarjetas rojas', 'Targetes vermelles')),
                    ])
                      (
                        label,
                        [
                          for (final side in const ['home', 'away']) ((sanctions['totals'] as Map)[side] as Map)[k] as int,
                        ],
                      ),
                  ],
                ),
                for (final e in sanctions['events'] as List)
                  if ((e as Map)['kind'] == 'YELLOW_CARD' || e['kind'] == 'RED_CARD')
                    Padding(
                      padding: const EdgeInsets.only(top: RefSpace.xs),
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 18,
                            decoration: BoxDecoration(
                              color: e['kind'] == 'YELLOW_CARD' ? const Color(0xFFFACC15) : const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: c.outline),
                            ),
                          ),
                          const SizedBox(width: RefSpace.s),
                          Expanded(
                            child: Text(
                              '${e['matchClock']} · ${nameOf(e['team'] == 'HOME' ? 'home' : 'away')}'
                              '${(e['infraction'] as Map?)?['label'] == null ? '' : ' · ${(e['infraction'] as Map)['label']}'}',
                              style: RefType.caption.copyWith(color: c.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ],
          ),

          // ─── Lo escrito en el informe ───
          if (summaryText.isNotEmpty || strengths.isNotEmpty || development.isNotEmpty || actionPoints.isNotEmpty) ...[
            _Title(tr('Informe', 'Informe')),
            _Card(
              children: [
                if (summaryText.isNotEmpty) Text(summaryText, style: RefType.body.copyWith(color: c.onSurface)),
                for (final (title, items) in [
                  (tr('Fortalezas', 'Fortaleses'), strengths),
                  (tr('Áreas de mejora', 'Àrees de millora'), development),
                  (tr('Recomendaciones', 'Recomanacions'), actionPoints),
                ])
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: RefSpace.s),
                    Text(
                      title,
                      style: RefType.caption.copyWith(color: c.onSurfaceMuted, fontWeight: FontWeight.w700),
                    ),
                    for (final f in items) Text('• ${(f as Map)['text']}', style: RefType.body.copyWith(color: c.onSurface)),
                  ],
              ],
            ),
          ],

          // ─── Exportar y salir ───
          if (export != null) ...[const SizedBox(height: RefSpace.l), ExportSection(controller: export!)],
          const SizedBox(height: RefSpace.l),
          SizedBox(
            height: RefTouch.control,
            child: OutlinedButton.icon(
              key: const ValueKey('open-full-report'),
              onPressed: onOpenFullReport,
              icon: const Icon(Icons.description_rounded),
              label: Text(tr('Ver el informe completo', "Veure l'informe complet")),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.onSurface,
                side: BorderSide(color: c.outline, width: 2),
                textStyle: context.refText(RefType.control),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
              ),
            ),
          ),
          const SizedBox(height: RefTouch.gap),
          SizedBox(
            height: RefTouch.control,
            child: FilledButton.icon(
              key: const ValueKey('back-to-menu'),
              onPressed: onBackToMenu,
              icon: const Icon(Icons.home_rounded),
              label: Text(tr('Volver al menú', 'Tornar al menú')),
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: c.onPrimary,
                textStyle: context.refText(RefType.control),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: RefSpace.l, bottom: RefSpace.s),
    child: Semantics(
      header: true,
      child: Text(text, style: RefType.status.copyWith(color: context.refColors.onSurface)),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Container(
      padding: const EdgeInsets.all(RefSpace.l),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RefRadius.tile),
        border: Border.all(color: c.outline, width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.label, required this.value, this.valueKey});
  final IconData icon;
  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Padding(
      padding: const EdgeInsets.only(top: RefSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: c.onSurface),
          const SizedBox(width: RefSpace.s),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: value),
                ],
              ),
              key: valueKey,
              style: RefType.caption.copyWith(color: c.onSurface, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabla de dos columnas (local / visitante).
class _Table extends StatelessWidget {
  const _Table({required this.home, required this.away, required this.rows});
  final String home;
  final String away;
  final List<(String, List<int>)> rows;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final head = RefType.caption.copyWith(color: c.onSurfaceMuted, fontWeight: FontWeight.w700);
    final cell = RefType.body.copyWith(color: c.onSurface);
    return Table(
      columnWidths: const {0: FlexColumnWidth(2.2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            const SizedBox.shrink(),
            Text(home, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: head),
            Text(away, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: head),
          ],
        ),
        for (final (label, values) in rows)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(label, style: cell),
              ),
              for (final v in values)
                Text(
                  '$v',
                  textAlign: TextAlign.center,
                  style: cell.copyWith(fontWeight: FontWeight.w700),
                ),
            ],
          ),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RefSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_rounded, size: 56, color: c.negative),
            const SizedBox(height: RefSpace.l),
            Text(
              tr('No se ha podido abrir el resumen', "No s'ha pogut obrir el resum"),
              textAlign: TextAlign.center,
              style: RefType.control.copyWith(color: c.onSurface),
            ),
            const SizedBox(height: RefSpace.s),
            Text(
              error,
              textAlign: TextAlign.center,
              style: RefType.caption.copyWith(color: c.onSurfaceMuted),
            ),
            const SizedBox(height: RefSpace.xl),
            FilledButton(onPressed: onRetry, child: Text(tr('Reintentar', 'Reintentar'))),
          ],
        ),
      ),
    );
  }
}
