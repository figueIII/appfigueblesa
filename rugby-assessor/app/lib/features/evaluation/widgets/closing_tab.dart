import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';
import '../../../core/i18n.dart';
import '../../../domain/report.dart';
import '../../../domain/rubric.dart';
import '../../review/widgets/choice_controls.dart';
import '../evaluation_controller.dart';
import '../evaluation_labels.dart';
import '../export_controller.dart';
import 'export_section.dart';
import 'band_widgets.dart';

/// Pestaña "Cierre": valoración global, dificultad real, recomendación de nivel, resumen,
/// fortalezas, áreas de mejora, recomendaciones, seguimiento de las anteriores y cierre.
/// NADA es obligatorio: la lista "Antes de cerrar" solo avisa de lo que falta.
class ClosingTab extends StatefulWidget {
  const ClosingTab({
    super.key,
    required this.controller,
    required this.onGoToCriterion,
    required this.onOpenReview,
    this.export,
    this.onFinalized,
  });

  final EvaluationController controller;
  final ValueChanged<String> onGoToCriterion;
  final VoidCallback onOpenReview;

  /// Exportación (solo con el informe cerrado). Null en contextos sin exportación (tests, demos).
  final ExportController? export;

  /// Tras cerrar el informe (la app abre el resumen del partido).
  final VoidCallback? onFinalized;

  @override
  State<ClosingTab> createState() => _ClosingTabState();
}

class _ClosingTabState extends State<ClosingTab> {
  EvaluationController get controller => widget.controller;

  final _scroll = ScrollController();
  final _previousKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, duration: RefMotion.sheet, alignment: 0.1);
  }

  void _handleIssue(CloseIssue i) {
    if (isIncidentIssue(i)) return widget.onOpenReview();
    if (i.criterionCode != null) return widget.onGoToCriterion(i.criterionCode!);
    _goTo(_previousKey);
  }

  /// Al cerrar, lo nuevo (aviso de informe cerrado y exportación) aparece ARRIBA: se vuelve al
  /// principio para que se vea, y la app pasa al resumen del partido.
  void _afterClose() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
    widget.onFinalized?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ctl = controller;
    final readOnly = ctl.isFinalized;
    final optional = tr('Opcional.', 'Opcional.');
    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(RefSpace.l, RefSpace.l, RefSpace.l, RefSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ctl.finalized != null) _FinalizedBanner(controller: ctl),
          if (ctl.finalized != null && widget.export != null) ...[
            ExportSection(controller: widget.export!),
            const SizedBox(height: RefSpace.l),
          ],
          _GlobalBandPanel(controller: ctl),
          _Header(
            title: tr('Dificultad real del partido', 'Dificultat real del partit'),
            subtitle: [
              tr('Estimada al preparar el partido: ', "Estimada en preparar el partit: ") +
                  (ctl.estimatedDifficulty == null ? tr('no indicada', 'no indicada') : difficultyText(ctl.estimatedDifficulty!)),
              optional,
            ].join(' · '),
          ),
          ChoiceGrid<String>(
            keyPrefix: 'actual-difficulty',
            options: [for (final d in kDifficultyCodes) ChoiceOption(value: d, label: difficultyText(d))],
            selected: ctl.actualDifficulty,
            onSelected: (v) => readOnly ? null : ctl.setActualDifficulty(ctl.actualDifficulty == v ? null : v),
          ),
          _Header(
            title: tr('Recomendación', 'Recomanació'),
            subtitle: '${tr('Nivel de los próximos partidos del árbitro.', "Nivell dels propers partits de l'àrbitre.")} $optional',
          ),
          ChoiceGrid<LevelRecommendation>(
            keyPrefix: 'level-rec',
            columns: 1,
            options: [
              for (final r in LevelRecommendation.values)
                ChoiceOption(value: r, label: '${levelRecommendationLabel(r).$1}  ${levelRecommendationLabel(r).$2}'),
            ],
            selected: ctl.levelRecommendation,
            onSelected: (v) => readOnly ? null : ctl.setLevelRecommendation(ctl.levelRecommendation == v ? null : v),
          ),
          _Header(title: tr('Resumen del partido', 'Resum del partit'), subtitle: optional),
          _SyncedTextField(
            fieldKey: const ValueKey('summary'),
            initial: ctl.summary,
            enabled: !readOnly,
            hint: tr('Contexto del partido y valoración general en dos o tres frases.',
                'Context del partit i valoració general en dues o tres frases.'),
            minLines: 3,
            onChanged: ctl.setSummary,
          ),
          _Header(title: tr('Fortalezas', 'Fortaleses'), subtitle: tr('Opcional, hasta tres.', 'Opcional, fins a tres.')),
          _FindingsList(controller: ctl, kind: FindingKind.strength),
          _Header(title: tr('Áreas de mejora', 'Àrees de millora'), subtitle: tr('Opcional, hasta tres.', 'Opcional, fins a tres.')),
          _FindingsList(controller: ctl, kind: FindingKind.development),
          _Header(
            title: tr('Recomendaciones para el próximo informe', "Recomanacions per al proper informe"),
            subtitle: tr('Opcional, hasta tres. El próximo evaluador las revisará.', "Opcional, fins a tres. El proper avaluador les revisarà."),
          ),
          _ActionPointsList(controller: ctl),
          if (ctl.openPrevious.isNotEmpty) ...[
            _Header(
              key: _previousKey,
              title: tr('Recomendaciones del informe anterior', "Recomanacions de l'informe anterior"),
              subtitle: optional,
            ),
            _PreviousReviews(controller: ctl),
          ],
          if (!readOnly) ...[
            _Header(title: tr('Antes de cerrar', 'Abans de tancar')),
            _Checklist(controller: ctl, onIssue: _handleIssue, onClosed: _afterClose),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => SectionHeader(title: title, subtitle: subtitle);
}

class _GlobalBandPanel extends StatelessWidget {
  const _GlobalBandPanel({required this.controller});
  final EvaluationController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final ctl = controller;
    final agg = ctl.aggregateResult;
    final keys = ctl.keyDecisions;
    final rubric = ctl.rubric;
    final total = rubric.criteria.length;
    return Container(
      padding: const EdgeInsets.all(RefSpace.l),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RefRadius.tile),
        border: Border.all(color: c.outline, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('Valoración global', 'Valoració global'), style: RefType.status.copyWith(color: c.onSurfaceMuted)),
          const SizedBox(height: RefSpace.s),
          Semantics(
            liveRegion: true,
            child: BandBadge(key: const ValueKey('global-band'), band: agg.band, rubric: rubric, large: true),
          ),
          const SizedBox(height: RefSpace.s),
          Text(
            agg.band == null
                ? tr('Aparecerá en cuanto valores competencias.', 'Apareixerà quan valoris competències.')
                : rubric.band(agg.band!).help,
            style: RefType.body.copyWith(color: c.onSurface),
          ),
          if (ctl.completedCount < total)
            Padding(
              padding: const EdgeInsets.only(top: RefSpace.xs),
              child: Text(
                tr('Las competencias sin valorar no cuentan.', 'Les competències sense valorar no compten.'),
                style: RefType.caption.copyWith(color: c.onSurfaceMuted),
              ),
            ),
          const SizedBox(height: RefSpace.l),
          for (final (idx, area) in rubric.areas.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: RefSpace.s),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: RefSpace.s,
                runSpacing: RefSpace.xs,
                children: [
                  Text('${area.letter} · ${area.label}', style: RefType.caption.copyWith(color: c.onSurface)),
                  BandBadge(band: agg.areas[idx].band, rubric: rubric, prefix: ''),
                ],
              ),
            ),
          const SizedBox(height: RefSpace.s),
          Row(
            children: [
              Icon(Icons.gavel_rounded, size: 20, color: c.onSurface),
              const SizedBox(width: RefSpace.xs),
              Expanded(
                child: Text(
                  keys.total == 0
                      ? tr('Sin decisiones clave (impacto alto o decisivo) valoradas.', 'Sense decisions clau (impacte alt o decisiu) valorades.')
                      : tr('Decisiones clave acertadas: ${keys.correct} de ${keys.total}.', 'Decisions clau encertades: ${keys.correct} de ${keys.total}.'),
                  style: RefType.caption.copyWith(color: c.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: RefSpace.xs),
          Text(
            tr('Competencias valoradas: ${ctl.completedCount} de $total.', 'Competències valorades: ${ctl.completedCount} de $total.'),
            style: RefType.caption.copyWith(color: c.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

class _FindingsList extends StatelessWidget {
  const _FindingsList({required this.controller, required this.kind});
  final EvaluationController controller;
  final FindingKind kind;

  @override
  Widget build(BuildContext context) {
    final ctl = controller;
    final items = ctl.findingsOf(kind);
    final label = kind == FindingKind.strength ? tr('fortaleza', 'fortalesa') : tr('área de mejora', 'àrea de millora');
    final prefix = kind == FindingKind.strength ? 'strength' : 'development';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final f in items) ...[
          _ItemCard(
            key: ValueKey('$prefix-${f.id}'),
            rubric: ctl.rubric,
            criterionCode: f.criterionCode,
            enabled: !ctl.isFinalized,
            onCriterion: (code) => ctl.updateFinding(f.id, criterionCode: code),
            onRemove: () => ctl.removeFinding(f.id),
            removeLabel: '${tr('Quitar', 'Treure')} $label',
            fields: [
              _SyncedTextField(
                fieldKey: ValueKey('$prefix-text-${f.id}'),
                initial: f.text,
                enabled: !ctl.isFinalized,
                label: kind == FindingKind.strength ? tr('Qué hizo bien', 'Què va fer bé') : tr('Qué debe mejorar', 'Què ha de millorar'),
                onChanged: (v) => ctl.updateFinding(f.id, text: v),
              ),
            ],
          ),
          const SizedBox(height: RefTouch.gap),
        ],
        if (!ctl.isFinalized && items.length < 3)
          _AddButton(key: ValueKey('add-$prefix'), label: '${tr('Añadir', 'Afegir')} $label', onPressed: () => ctl.addFinding(kind)),
      ],
    );
  }
}

class _ActionPointsList extends StatelessWidget {
  const _ActionPointsList({required this.controller});
  final EvaluationController controller;

  @override
  Widget build(BuildContext context) {
    final ctl = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final a in ctl.actionPoints) ...[
          _ItemCard(
            key: ValueKey('ap-${a.id}'),
            rubric: ctl.rubric,
            criterionCode: a.criterionCode,
            enabled: !ctl.isFinalized,
            onCriterion: (code) => ctl.updateActionPoint(a.id, criterionCode: code),
            onRemove: () => ctl.removeActionPoint(a.id),
            removeLabel: tr('Quitar recomendación', 'Treure recomanació'),
            fields: [
              _SyncedTextField(
                fieldKey: ValueKey('ap-text-${a.id}'),
                initial: a.text,
                enabled: !ctl.isFinalized,
                label: tr('Qué debe hacer', 'Què ha de fer'),
                onChanged: (v) => ctl.updateActionPoint(a.id, text: v),
              ),
              const SizedBox(height: RefSpace.s),
              _SyncedTextField(
                fieldKey: ValueKey('ap-indicator-${a.id}'),
                initial: a.successIndicator,
                enabled: !ctl.isFinalized,
                label: tr('Cómo se verá que lo ha logrado (opcional)', "Com es veurà que ho ha assolit (opcional)"),
                hint: tr('Algo observable en el próximo partido.', 'Alguna cosa observable al proper partit.'),
                onChanged: (v) => ctl.updateActionPoint(a.id, successIndicator: v),
              ),
            ],
          ),
          const SizedBox(height: RefTouch.gap),
        ],
        if (!ctl.isFinalized && ctl.actionPoints.length < 3)
          _AddButton(key: const ValueKey('add-ap'), label: tr('Añadir recomendación', 'Afegir recomanació'), onPressed: ctl.addActionPoint),
      ],
    );
  }
}

class _PreviousReviews extends StatelessWidget {
  const _PreviousReviews({required this.controller});
  final EvaluationController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final ctl = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final p in ctl.openPrevious) ...[
          Container(
            padding: const EdgeInsets.all(RefSpace.m),
            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(RefRadius.control)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  p.text,
                  style: RefType.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w700),
                ),
                if (p.successIndicator.trim().isNotEmpty)
                  Text('${tr('Indicador', 'Indicador')}: ${p.successIndicator}', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
                const SizedBox(height: RefSpace.s),
                ChoiceGrid<ActionPointReviewStatus>(
                  keyPrefix: 'prev-${p.id}',
                  options: [for (final s in ActionPointReviewStatus.values) ChoiceOption(value: s, label: reviewStatusLabel(s))],
                  selected: ctl.previousReviewOf(p.id)?.status,
                  onSelected: (s) => ctl.setPreviousReview(p.id, status: s),
                ),
                const SizedBox(height: RefSpace.s),
                _SyncedTextField(
                  fieldKey: ValueKey('prev-comment-${p.id}'),
                  initial: ctl.previousReviewOf(p.id)?.comment ?? '',
                  enabled: !ctl.isFinalized && ctl.previousReviewOf(p.id) != null,
                  label: tr('Comentario', 'Comentari'),
                  onChanged: (v) => ctl.setPreviousReview(p.id, comment: v),
                ),
              ],
            ),
          ),
          const SizedBox(height: RefTouch.gap),
        ],
      ],
    );
  }
}

class _Checklist extends StatelessWidget {
  const _Checklist({required this.controller, required this.onIssue, required this.onClosed});
  final EvaluationController controller;
  final ValueChanged<CloseIssue> onIssue;
  final VoidCallback onClosed;

  Future<void> _confirmAndClose(BuildContext context, int warnings) async {
    final c = context.refColors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('¿Cerrar el informe?', "Tancar l'informe?")),
        content: Text(
          [
            if (warnings > 0)
              warnings == 1
                  ? tr('Hay 1 aviso sin resolver: no impide cerrar, pero lo que falte no contará.',
                      'Hi ha 1 avís sense resoldre: no impedeix tancar, però el que falti no comptarà.')
                  : tr('Hay $warnings avisos sin resolver: no impiden cerrar, pero lo que falte no contará.',
                      'Hi ha $warnings avisos sense resoldre: no impedeixen tancar, però el que falti no comptarà.'),
            tr('El informe quedará congelado con una huella de integridad y las marcas del partido se bloquearán.',
                "L'informe quedarà congelat amb una empremta d'integritat i les marques del partit es bloquejaran."),
          ].join('\n\n'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr('Seguir revisando', 'Continuar revisant'))),
          FilledButton(
            key: const ValueKey('confirm-close'),
            style: FilledButton.styleFrom(backgroundColor: c.primary, foregroundColor: c.onPrimary),
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('Cerrar informe', "Tancar l'informe")),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await controller.finalize();
      if (controller.isFinalized) onClosed();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('No se ha podido cerrar el informe. Tus datos siguen guardados: vuelve a intentarlo.',
                "No s'ha pogut tancar l'informe. Les teves dades continuen desades: torna-ho a provar.")),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final ctl = controller;
    final issues = ctl.closeWarningsList;
    // Las marcas pendientes y las competencias sin valorar se agrupan en una línea cada una.
    final incidentIssues = issues.where(isIncidentIssue).toList();
    final unrated = issues.where((i) => i.code == CloseIssueCode.criterionBandMissing).toList();
    final previous = issues.where((i) => i.code == CloseIssueCode.previousActionPointNotReviewed).toList();
    final lines = <(CloseIssue, String)>[
      if (incidentIssues.isNotEmpty)
        (
          incidentIssues.first,
          incidentIssues.length == 1
              ? tr('1 marca sin valorar: no cuenta (ir a la revisión)', '1 marca sense valorar: no compta (anar a la revisió)')
              : tr('${incidentIssues.length} marcas sin valorar: no cuentan (ir a la revisión)',
                  '${incidentIssues.length} marques sense valorar: no compten (anar a la revisió)'),
        ),
      if (unrated.isNotEmpty)
        (
          unrated.first,
          unrated.length == 1
              ? tr('1 competencia sin valorar: no cuenta', '1 competència sense valorar: no compta')
              : tr('${unrated.length} competencias sin valorar: no cuentan', '${unrated.length} competències sense valorar: no compten'),
        ),
      if (previous.isNotEmpty) (previous.first, closeIssueText(previous.first, ctl.rubric)),
    ];
    final clean = lines.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Row(
            children: [
              Icon(clean ? Icons.task_alt_rounded : Icons.info_outline_rounded, color: clean ? c.positive : c.onSurface),
              const SizedBox(width: RefSpace.s),
              Expanded(
                child: Text(
                  clean
                      ? tr('Todo valorado.', 'Tot valorat.')
                      : tr('Avisos (no impiden cerrar; toca para ir):', 'Avisos (no impedeixen tancar; toca per anar-hi):'),
                  style: RefType.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RefSpace.s),
        for (final (i, text) in lines)
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('issue-${i.code.name}'),
              onTap: () => onIssue(i),
              borderRadius: BorderRadius.circular(RefRadius.control),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: RefTouch.minTarget),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 20, color: c.onSurface),
                    const SizedBox(width: RefSpace.s),
                    Expanded(child: Text(text, style: RefType.caption.copyWith(color: c.onSurface, fontSize: 15))),
                    Icon(Icons.chevron_right_rounded, color: c.onSurface),
                  ],
                ),
              ),
            ),
          ),
        if (ctl.saveFailed)
          Padding(
            padding: const EdgeInsets.only(top: RefSpace.s),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tr('No se han podido guardar los últimos cambios.', "No s'han pogut desar els darrers canvis."),
                    style: RefType.caption.copyWith(color: c.negative),
                  ),
                ),
                TextButton(onPressed: ctl.retryPendingWrites, child: Text(tr('Reintentar', 'Reintentar'))),
              ],
            ),
          ),
        const SizedBox(height: RefSpace.l),
        SizedBox(
          height: RefTouch.control,
          child: FilledButton.icon(
            key: const ValueKey('close-report'),
            onPressed: ctl.finalizing ? null : () => _confirmAndClose(context, lines.length),
            icon: ctl.finalizing
                ? SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 3, color: c.onPrimary))
                : const Icon(Icons.lock_rounded),
            label: Text(tr('Cerrar informe', "Tancar l'informe")),
            style: FilledButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: c.onPrimary,
              disabledBackgroundColor: c.surfacePressed,
              disabledForegroundColor: c.onSurface,
              textStyle: context.refText(RefType.control),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
            ),
          ),
        ),
      ],
    );
  }
}

class _FinalizedBanner extends StatelessWidget {
  const _FinalizedBanner({required this.controller});
  final EvaluationController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final f = controller.finalized!;
    final local = f.at.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(bottom: RefSpace.l),
      child: Container(
        key: const ValueKey('finalized-banner'),
        padding: const EdgeInsets.all(RefSpace.m),
        decoration: BoxDecoration(color: c.onSurface, borderRadius: BorderRadius.circular(RefRadius.control)),
        child: Row(
          children: [
            Icon(Icons.verified_rounded, color: c.background, size: 32),
            const SizedBox(width: RefSpace.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Informe cerrado', 'Informe tancat'), style: RefType.control.copyWith(color: c.background)),
                  Text(
                    '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)} · '
                    '${tr('huella', 'empremta')} ${f.contentHash.substring(0, 12)}…',
                    style: RefType.caption.copyWith(color: c.background),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de un hallazgo o recomendación: criterio (reasignable), campos y botón de quitar.
class _ItemCard extends StatelessWidget {
  const _ItemCard({
    super.key,
    required this.rubric,
    required this.criterionCode,
    required this.enabled,
    required this.onCriterion,
    required this.onRemove,
    required this.removeLabel,
    required this.fields,
  });
  final AssessmentRubric rubric;
  final String criterionCode;
  final bool enabled;
  final ValueChanged<String> onCriterion;
  final VoidCallback onRemove;
  final String removeLabel;
  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;

    return Container(
      padding: const EdgeInsets.all(RefSpace.m),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(RefRadius.control),
        border: Border.all(color: c.outline, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: enabled
                      ? () async {
                          final picked = await showCriterionPicker(context, rubric, criterionCode);
                          if (picked != null) onCriterion(picked);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(RefRadius.control),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: RefTouch.minTarget),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            criterionTitle(rubric, criterionCode),
                            style: RefType.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (enabled) Icon(Icons.arrow_drop_down_rounded, color: c.onSurface),
                      ],
                    ),
                  ),
                ),
              ),
              if (enabled)
                IconButton(
                  tooltip: removeLabel,
                  onPressed: onRemove,
                  icon: Icon(Icons.close_rounded, color: c.onSurface),
                ),
            ],
          ),
          const SizedBox(height: RefSpace.xs),
          ...fields,
        ],
      ),
    );
  }
}

Future<String?> showCriterionPicker(BuildContext context, AssessmentRubric rubric, String current) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final c = context.refColors;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: RefSpace.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final area in rubric.areas) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(RefSpace.l, RefSpace.m, RefSpace.l, RefSpace.xs),
                  child: Text('${area.letter} · ${area.label}', style: RefType.status.copyWith(color: c.onSurfaceMuted)),
                ),
                for (final crit in area.criteria)
                  ListTile(
                    key: ValueKey('pick-${crit.code}'),
                    minTileHeight: RefTouch.control,
                    title: Text(criterionTitle(rubric, crit.code), style: RefType.body.copyWith(color: c.onSurface)),
                    trailing: crit.code == current ? Icon(Icons.check_rounded, color: c.onSurface) : null,
                    onTap: () => Navigator.of(context).pop(crit.code),
                  ),
              ],
            ],
          ),
        );
      },
    );

class _AddButton extends StatelessWidget {
  const _AddButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return SizedBox(
      height: RefTouch.control,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: c.onSurface,
          side: BorderSide(color: c.outline, width: 2),
          textStyle: context.refText(RefType.control),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
        ),
      ),
    );
  }
}

/// Campo de texto con su propio controlador (sobrevive a las reconstrucciones del padre).
class _SyncedTextField extends StatefulWidget {
  const _SyncedTextField({
    required this.fieldKey,
    required this.initial,
    required this.onChanged,
    this.enabled = true,
    this.label,
    this.hint,
    this.minLines = 1,
  });
  final Key fieldKey;
  final String initial;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? label;
  final String? hint;
  final int minLines;

  @override
  State<_SyncedTextField> createState() => _SyncedTextFieldState();
}

class _SyncedTextFieldState extends State<_SyncedTextField> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return TextField(
      key: widget.fieldKey,
      controller: _c,
      enabled: widget.enabled,
      minLines: widget.minLines,
      maxLines: 6,
      textCapitalization: TextCapitalization.sentences,
      style: RefType.body.copyWith(color: c.onSurface),
      onChanged: widget.onChanged,
      decoration: InputDecoration(labelText: widget.label, hintText: widget.hint, border: const OutlineInputBorder()),
    );
  }
}
