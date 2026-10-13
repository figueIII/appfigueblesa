import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';
import '../../../domain/report.dart';
import '../../../domain/rubric.dart';
import '../../review/widgets/choice_controls.dart';
import '../evaluation_controller.dart';
import '../evaluation_labels.dart';
import '../export_controller.dart';
import 'export_section.dart';
import 'band_widgets.dart';

/// Pestaña "Cierre": banda global, resumen, fortalezas, áreas de mejora, recomendaciones,
/// seguimiento de las recomendaciones anteriores y comprobación previa al cierre.
class ClosingTab extends StatefulWidget {
  const ClosingTab({super.key, required this.controller, required this.onGoToCriterion, required this.onOpenReview, this.export});

  final EvaluationController controller;
  final ValueChanged<String> onGoToCriterion;
  final VoidCallback onOpenReview;

  /// Exportación (solo con el informe cerrado). Null en contextos sin exportación (tests, demos).
  final ExportController? export;

  @override
  State<ClosingTab> createState() => _ClosingTabState();
}

class _ClosingTabState extends State<ClosingTab> {
  EvaluationController get controller => widget.controller;

  final _summaryKey = GlobalKey();
  final _strengthsKey = GlobalKey();
  final _developmentKey = GlobalKey();
  final _actionPointsKey = GlobalKey();
  final _previousKey = GlobalKey();

  void _goTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, duration: RefMotion.sheet, alignment: 0.1);
  }

  void _handleIssue(CloseIssue i) {
    if (isIncidentIssue(i)) return widget.onOpenReview();
    if (i.criterionCode != null) return widget.onGoToCriterion(i.criterionCode!);
    _goTo(switch (i.code) {
      CloseIssueCode.summaryRequired => _summaryKey,
      CloseIssueCode.strengthsCount => _strengthsKey,
      CloseIssueCode.developmentCount || CloseIssueCode.findingTextRequired => _developmentKey,
      CloseIssueCode.previousActionPointNotReviewed => _previousKey,
      _ => _actionPointsKey,
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctl = controller;
    final readOnly = ctl.isFinalized;
    return SingleChildScrollView(
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
          _Header(key: _summaryKey, title: 'Resumen del partido', required: true),
          _SyncedTextField(
            fieldKey: const ValueKey('summary'),
            initial: ctl.summary,
            enabled: !readOnly,
            hint: 'Contexto del partido y valoración general en dos o tres frases.',
            minLines: 3,
            onChanged: ctl.setSummary,
          ),
          _Header(key: _strengthsKey, title: 'Fortalezas', required: true, subtitle: 'Entre una y tres.'),
          _FindingsList(controller: ctl, kind: FindingKind.strength),
          _Header(key: _developmentKey, title: 'Áreas de mejora', required: true, subtitle: 'Entre una y tres.'),
          _FindingsList(controller: ctl, kind: FindingKind.development),
          _Header(
            key: _actionPointsKey,
            title: 'Recomendaciones para el próximo informe',
            required: true,
            subtitle: 'Entre una y tres. El próximo evaluador las revisará con su indicador de logro.',
          ),
          _ActionPointsList(controller: ctl),
          if (ctl.openPrevious.isNotEmpty) ...[
            _Header(key: _previousKey, title: 'Recomendaciones del informe anterior', required: true),
            _PreviousReviews(controller: ctl),
          ],
          if (!readOnly) ...[const _Header(title: 'Antes de cerrar'), _Checklist(controller: ctl, onIssue: _handleIssue)],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key, required this.title, this.required = false, this.subtitle});
  final String title;
  final bool required;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => SectionHeader(title: title, required: required, subtitle: subtitle);
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
          Text('Banda global del partido', style: RefType.status.copyWith(color: c.onSurfaceMuted)),
          const SizedBox(height: RefSpace.s),
          Semantics(
            liveRegion: true,
            child: BandBadge(key: const ValueKey('global-band'), band: agg.band, rubric: rubric, large: true),
          ),
          const SizedBox(height: RefSpace.s),
          Text(
            agg.band == null ? 'Aparecerá en cuanto valores criterios.' : rubric.band(agg.band!).description,
            style: RefType.body.copyWith(color: c.onSurface),
          ),
          if (ctl.completedCount < total)
            Padding(
              padding: const EdgeInsets.only(top: RefSpace.xs),
              child: Text('Provisional: hay criterios sin completar.', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
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
                  Text('${area.letter} · ${area.name}', style: RefType.caption.copyWith(color: c.onSurface)),
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
                      ? 'Sin decisiones clave (impacto alto o decisivo) valoradas.'
                      : 'Decisiones clave acertadas: ${keys.correct} de ${keys.total}.',
                  style: RefType.caption.copyWith(color: c.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: RefSpace.xs),
          Text('Criterios completos: ${ctl.completedCount} de $total.', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
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
    final label = kind == FindingKind.strength ? 'fortaleza' : 'área de mejora';
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
            removeLabel: 'Quitar $label',
            fields: [
              _SyncedTextField(
                fieldKey: ValueKey('$prefix-text-${f.id}'),
                initial: f.text,
                enabled: !ctl.isFinalized,
                label: kind == FindingKind.strength ? 'Qué hizo bien' : 'Qué debe mejorar',
                onChanged: (v) => ctl.updateFinding(f.id, text: v),
              ),
            ],
          ),
          const SizedBox(height: RefTouch.gap),
        ],
        if (!ctl.isFinalized && items.length < 3)
          _AddButton(key: ValueKey('add-$prefix'), label: 'Añadir $label', onPressed: () => ctl.addFinding(kind)),
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
            removeLabel: 'Quitar recomendación',
            fields: [
              _SyncedTextField(
                fieldKey: ValueKey('ap-text-${a.id}'),
                initial: a.text,
                enabled: !ctl.isFinalized,
                label: 'Qué debe hacer',
                onChanged: (v) => ctl.updateActionPoint(a.id, text: v),
              ),
              const SizedBox(height: RefSpace.s),
              _SyncedTextField(
                fieldKey: ValueKey('ap-indicator-${a.id}'),
                initial: a.successIndicator,
                enabled: !ctl.isFinalized,
                label: 'Cómo se verá que lo ha logrado',
                hint: 'Algo observable en el próximo partido.',
                onChanged: (v) => ctl.updateActionPoint(a.id, successIndicator: v),
              ),
            ],
          ),
          const SizedBox(height: RefTouch.gap),
        ],
        if (!ctl.isFinalized && ctl.actionPoints.length < 3)
          _AddButton(key: const ValueKey('add-ap'), label: 'Añadir recomendación', onPressed: ctl.addActionPoint),
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
                Text('Indicador: ${p.successIndicator}', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
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
                  label: 'Comentario',
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
  const _Checklist({required this.controller, required this.onIssue});
  final EvaluationController controller;
  final ValueChanged<CloseIssue> onIssue;

  Future<void> _confirmAndClose(BuildContext context) async {
    final c = context.refColors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar el informe?'),
        content: const Text(
          'Quedará congelado con una huella de integridad y las marcas del partido se bloquearán. '
          'Después solo se podrá corregir mediante una enmienda.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir revisando')),
          FilledButton(
            key: const ValueKey('confirm-close'),
            style: FilledButton.styleFrom(backgroundColor: c.primary, foregroundColor: c.onPrimary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar informe'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await controller.finalize();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se ha podido cerrar el informe. Tus datos siguen guardados: vuelve a intentarlo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final ctl = controller;
    final issues = ctl.closeIssues;
    // Las marcas pendientes se agrupan en una sola línea con acceso a la revisión.
    final incidentIssues = issues.where(isIncidentIssue).toList();
    final shown = [if (incidentIssues.isNotEmpty) incidentIssues.first, ...issues.where((i) => !isIncidentIssue(i))];
    final ready = issues.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Row(
            children: [
              Icon(ready ? Icons.task_alt_rounded : Icons.checklist_rounded, color: ready ? c.positive : c.onSurface),
              const SizedBox(width: RefSpace.s),
              Expanded(
                child: Text(
                  ready ? 'Todo listo para cerrar.' : 'Pendiente antes de cerrar (toca para ir):',
                  style: RefType.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RefSpace.s),
        for (final i in shown)
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('issue-${i.code.name}-${i.criterionCode ?? i.itemId ?? ''}'),
              onTap: () => onIssue(i),
              borderRadius: BorderRadius.circular(RefRadius.control),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: RefTouch.minTarget),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 20, color: c.onSurface),
                    const SizedBox(width: RefSpace.s),
                    Expanded(
                      child: Text(
                        isIncidentIssue(i) ? 'Quedan marcas por revisar (ir a la revisión)' : closeIssueText(i, ctl.rubric),
                        style: RefType.caption.copyWith(color: c.onSurface, fontSize: 15),
                      ),
                    ),
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
                    'No se han podido guardar los últimos cambios.',
                    style: RefType.caption.copyWith(color: c.negative),
                  ),
                ),
                TextButton(onPressed: ctl.retryPendingWrites, child: const Text('Reintentar')),
              ],
            ),
          ),
        const SizedBox(height: RefSpace.l),
        SizedBox(
          height: RefTouch.control,
          child: FilledButton.icon(
            key: const ValueKey('close-report'),
            onPressed: ready && !ctl.finalizing ? () => _confirmAndClose(context) : null,
            icon: ctl.finalizing
                ? SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 3, color: c.onPrimary))
                : const Icon(Icons.lock_rounded),
            label: const Text('Cerrar informe'),
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
        if (!ready)
          Padding(
            padding: const EdgeInsets.only(top: RefSpace.xs),
            child: Text(
              'Se activará cuando no quede nada pendiente.',
              textAlign: TextAlign.center,
              style: RefType.caption.copyWith(color: c.onSurfaceMuted),
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
                  Text('Informe cerrado', style: RefType.control.copyWith(color: c.background)),
                  Text(
                    '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)} · '
                    'huella ${f.contentHash.substring(0, 12)}…',
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
    final crit = rubric.criteria.firstWhere((x) => x.code == criterionCode);
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
                            '${crit.code.substring(0, 2)} · ${crit.name}',
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
                  child: Text('${area.letter} · ${area.name}', style: RefType.status.copyWith(color: c.onSurfaceMuted)),
                ),
                for (final crit in area.criteria)
                  ListTile(
                    key: ValueKey('pick-${crit.code}'),
                    minTileHeight: RefTouch.control,
                    title: Text('${crit.code.substring(0, 2)} · ${crit.name}', style: RefType.body.copyWith(color: c.onSurface)),
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
