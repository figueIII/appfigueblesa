import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';
import '../../../domain/clock.dart';
import '../../../domain/model.dart';
import '../../../domain/report.dart';
import '../../../domain/rubric.dart';
import '../../live/live_labels.dart';
import '../../review/review_labels.dart';
import '../evaluation_controller.dart';
import '../evaluation_labels.dart';
import 'band_widgets.dart';

/// Tarjeta de un criterio. De arriba abajo: qué se evalúa → qué sugiere la app y por qué
/// (marcas del partido y topes) → banda elegida → justificación → estado.
class CriterionCard extends StatefulWidget {
  const CriterionCard({super.key, required this.controller, required this.criterion});
  final EvaluationController controller;
  final Criterion criterion;

  @override
  State<CriterionCard> createState() => _CriterionCardState();
}

class _CriterionCardState extends State<CriterionCard> {
  late final TextEditingController _text = TextEditingController(
    text: widget.controller.evaluationOf(widget.criterion.code)?.justification ?? '',
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final ctl = widget.controller;
    final crit = widget.criterion;
    final rubric = ctl.rubric;
    final s = ctl.suggestions[crit.code]!;
    final e = ctl.evaluationOf(crit.code);
    final issues = ctl.issuesFor(crit.code);
    final complete = issues.isEmpty;
    final readOnly = ctl.isFinalized;
    final longNeeded = needsLongJustification(e, s);
    final minChars = rubric.scoring.minJustificationChars;
    final missingChars = (minChars - (e?.justification.trim().length ?? 0)).clamp(0, minChars);
    final evidence = [for (final id in s.evidenceIncidentIds) ctl.incidents.firstWhere((i) => i.id == id)];

    return Material(
      color: c.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RefRadius.tile),
        side: BorderSide(color: complete ? c.outline : c.onSurface, width: complete ? 2 : 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RefSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Qué se evalúa ───
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      '${crit.code.substring(0, 2)} · ${crit.name}',
                      style: RefType.control.copyWith(color: c.onSurface),
                    ),
                  ),
                ),
                const SizedBox(width: RefSpace.s),
                Icon(
                  complete ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: complete ? c.positive : c.onSurfaceMuted,
                  semanticLabel: complete ? 'Criterio completo' : 'Criterio pendiente',
                ),
              ],
            ),
            const SizedBox(height: RefSpace.xs),
            Text(
              crit.description,
              style: RefType.caption.copyWith(color: c.onSurfaceMuted, fontWeight: FontWeight.w500),
            ),

            // ─── Sugerencia ───
            const SizedBox(height: RefSpace.m),
            Container(
              padding: const EdgeInsets.all(RefSpace.m),
              decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(RefRadius.control)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: RefSpace.s,
                    runSpacing: RefSpace.xs,
                    children: [
                      Text('Sugerencia de la app', style: RefType.caption.copyWith(color: c.onSurface)),
                      if (s.suggestedBand != null)
                        BandBadge(key: ValueKey('suggested-${crit.code}'), band: s.suggestedBand, rubric: rubric)
                      else
                        Text(
                          'sin marcas valoradas: elige según lo observado',
                          style: RefType.caption.copyWith(color: c.onSurfaceMuted),
                        ),
                    ],
                  ),
                  if (s.capBand != null) ...[
                    const SizedBox(height: RefSpace.s),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_rounded, size: 20, color: c.onSurface),
                        const SizedBox(width: RefSpace.xs),
                        Expanded(
                          child: Text(
                            'Tope automático: error grave en este criterio. Máximo «${rubric.band(s.capBand!).label}».',
                            key: ValueKey('cap-${crit.code}'),
                            style: RefType.caption.copyWith(color: c.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (evidence.isNotEmpty) ...[
                    const SizedBox(height: RefSpace.s),
                    Text('Basada en:', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
                    const SizedBox(height: RefSpace.xs),
                    Wrap(
                      spacing: RefSpace.xs,
                      runSpacing: RefSpace.xs,
                      children: [for (final i in evidence) _EvidenceChip(incident: i)],
                    ),
                  ],
                ],
              ),
            ),

            // ─── Banda elegida ───
            const SizedBox(height: RefSpace.l),
            Text('Tu valoración', style: RefType.status.copyWith(color: c.onSurface)),
            const SizedBox(height: RefSpace.s),
            Opacity(
              opacity: e?.notObserved == true ? 0.45 : 1,
              child: BandSelector(
                keyPrefix: 'band-${crit.code}',
                rubric: rubric,
                selected: e?.notObserved == true ? null : e?.finalBand,
                suggested: s.suggestedBand,
                capBand: s.capBand,
                enabled: !readOnly,
                onSelected: (b) => ctl.setBand(crit.code, b),
              ),
            ),
            const SizedBox(height: RefSpace.xs),
            MergeSemantics(
              child: CheckboxListTile(
                key: ValueKey('not-observed-${crit.code}'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                visualDensity: VisualDensity.standard,
                value: e?.notObserved ?? false,
                onChanged: readOnly ? null : (v) => ctl.setNotObserved(crit.code, v ?? false),
                title: Text('No se observó en este partido', style: RefType.body.copyWith(color: c.onSurface)),
                subtitle: Text(
                  'Su peso se reparte entre los demás criterios del área.',
                  style: RefType.caption.copyWith(color: c.onSurfaceMuted),
                ),
              ),
            ),

            // ─── Justificación ───
            const SizedBox(height: RefSpace.s),
            TextField(
              key: ValueKey('justification-${crit.code}'),
              controller: _text,
              enabled: !readOnly,
              minLines: 2,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              style: RefType.body.copyWith(color: c.onSurface),
              onChanged: (v) => ctl.setJustification(crit.code, v),
              decoration: InputDecoration(
                labelText: 'Justificación · obligatoria',
                border: const OutlineInputBorder(),
                helperMaxLines: 3,
                helperText: longNeeded
                    ? (missingChars > 0
                          ? 'Tu banda no coincide con la sugerencia: explica por qué (faltan $missingChars caracteres).'
                          : 'Justificación suficiente.')
                    : 'Qué viste para valorarlo así.',
              ),
            ),

            // ─── Estado ───
            const SizedBox(height: RefSpace.s),
            Semantics(
              liveRegion: true,
              child: Row(
                children: [
                  Icon(
                    complete ? Icons.check_rounded : Icons.error_outline_rounded,
                    size: 20,
                    color: complete ? c.positive : c.onSurface,
                  ),
                  const SizedBox(width: RefSpace.xs),
                  Expanded(
                    child: Text(
                      complete ? 'Criterio completo' : closeIssueText(issues.first, rubric),
                      style: RefType.caption.copyWith(color: c.onSurface),
                    ),
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

class _EvidenceChip extends StatelessWidget {
  const _EvidenceChip({required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final i = incident;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RefSpace.s, vertical: 2),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(RefRadius.pill),
        border: Border.all(color: c.outline, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(verdictIcon(i.verdict), size: 16, color: c.onSurface),
          const SizedBox(width: RefSpace.xs),
          Flexible(
            child: Text(
              '${kCategoryLabel[i.category]} ${formatClock(i.matchTime.matchClockMs)} · ${verdictLabel(i.verdict).toLowerCase()}'
              '${i.impact == ImpactLevel.high || i.impact == ImpactLevel.matchDefining ? ' · ${impactLabel(i.impact).toLowerCase()}' : ''}',
              style: RefType.caption.copyWith(color: c.onSurface, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
