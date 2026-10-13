import 'package:flutter/material.dart';

import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/clock.dart';
import '../../domain/model.dart';
import '../../domain/review.dart';
import '../live/live_controller.dart' show periodLabel;
import '../live/live_labels.dart';
import 'incident_editor_screen.dart';
import 'review_controller.dart';
import 'review_labels.dart';

/// Pantalla 2 · Revisión post-partido.
///
/// Arriba, el progreso ("7 de 12 resueltas"). Debajo, la cola de lo pendiente ordenada por
/// urgencia e IMPACTO (domain/review.dart), o todas las marcas en orden cronológico.
/// Cada tarjeta dice qué le falta; al tocarla se abre el editor, que al guardar salta a la
/// siguiente pendiente. Cuando la cola se vacía, se ofrece pasar a la evaluación por criterios.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.controller, required this.onContinueToRubric});
  final ReviewController controller;
  final VoidCallback onContinueToRubric;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  ReviewController get _ctl => widget.controller;

  @override
  void initState() {
    super.initState();
    if (_ctl.loadState != ReviewLoadState.ready) _ctl.load();
  }

  void _open(Incident i) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => IncidentEditorScreen(controller: _ctl, incidentId: i.id),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return ListenableBuilder(
      listenable: _ctl,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          backgroundColor: c.background,
          foregroundColor: c.onSurface,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Revisión post-partido'),
              if (_ctl.homeTeam.isNotEmpty)
                Text('${_ctl.homeTeam} – ${_ctl.awayTeam}', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
            ],
          ),
        ),
        body: SafeArea(
          child: switch (_ctl.loadState) {
            ReviewLoadState.loading => const _Centered(icon: null, title: 'Cargando las marcas…'),
            ReviewLoadState.failed => _Centered(
              icon: Icons.storage_rounded,
              title: 'No se han podido cargar las marcas',
              body: 'Siguen guardadas en el móvil.',
              action: ('Reintentar', _ctl.load),
            ),
            ReviewLoadState.ready => _ready(context),
          },
        ),
      ),
    );
  }

  Widget _ready(BuildContext context) {
    final c = context.refColors;
    final p = _ctl.progress;
    if (p.total == 0) {
      return _Centered(
        icon: Icons.inbox_rounded,
        title: 'No hubo marcas en este partido',
        body: 'Puedes pasar directamente a la evaluación por criterios.',
        action: ('Ir a la evaluación', widget.onContinueToRubric),
      );
    }
    final list = _ctl.visible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(RefSpace.l, RefSpace.s, RefSpace.l, 0),
          child: _ProgressHeader(progress: p),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(RefSpace.l, RefSpace.m, RefSpace.l, RefSpace.s),
          child: SegmentedButton<ReviewFilter>(
            key: const ValueKey('review-filter'),
            // Sin icono de check: no cabe junto a "Pendientes (n)" en 360 dp. La selección se ve por
            // el relleno invertido (cambio de luminancia, no solo de tono) y se anuncia como seleccionada.
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              minimumSize: const Size.fromHeight(RefTouch.minTarget),
              textStyle: context.refText(RefType.caption.copyWith(fontSize: 16)),
              selectedBackgroundColor: c.onSurface,
              selectedForegroundColor: c.background,
              foregroundColor: c.onSurface,
              side: BorderSide(color: c.outline, width: 2),
            ),
            segments: [
              ButtonSegment(
                value: ReviewFilter.pending,
                label: FittedBox(child: Text('Pendientes (${p.remaining})')),
              ),
              ButtonSegment(
                value: ReviewFilter.all,
                label: FittedBox(child: Text('Todas (${p.total})')),
              ),
            ],
            selected: {_ctl.filter},
            onSelectionChanged: (s) => _ctl.setFilter(s.first),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? _Centered(
                  icon: Icons.task_alt_rounded,
                  title: 'Revisión completa',
                  body: 'Las ${p.total} marcas tienen veredicto, y las que lo necesitan, impacto, decisión esperada y notas.',
                  action: ('Ir a la evaluación por criterios', widget.onContinueToRubric),
                  actionKey: const ValueKey('continue-to-rubric'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(RefSpace.l, RefSpace.xs, RefSpace.l, RefSpace.xxl),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: RefTouch.gap),
                  itemBuilder: (context, index) => _IncidentCard(
                    incident: list[index],
                    position: _ctl.filter == ReviewFilter.pending ? index + 1 : null,
                    onTap: () => _open(list[index]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.progress});
  final ReviewProgress progress;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Semantics(
      liveRegion: true,
      label: '${progress.resolved} de ${progress.total} marcas resueltas',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${progress.resolved}', style: RefType.clockCompact.copyWith(color: c.onSurface)),
              const SizedBox(width: RefSpace.s),
              Expanded(
                child: Text('de ${progress.total} resueltas', style: RefType.control.copyWith(color: c.onSurfaceMuted)),
              ),
            ],
          ),
          const SizedBox(height: RefSpace.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(RefRadius.pill),
            child: LinearProgressIndicator(
              value: progress.fraction,
              minHeight: 10,
              color: progress.complete ? c.positive : c.primary,
              backgroundColor: c.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.incident, required this.onTap, this.position});
  final Incident incident;
  final VoidCallback onTap;
  final int? position;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final i = incident;
    final issues = reviewIssues(i);
    final period = i.matchTime.period;
    final (vBg, vFg) = verdictColors(i.verdict, c);
    final minute = formatClock(i.matchTime.matchClockMs);

    return Semantics(
      button: true,
      label: [
        if (position != null) 'Pendiente $position',
        '$minute, ${kCategoryLabel[i.category]}',
        if (i.infraction != null) i.infraction!.label,
        verdictLabel(i.verdict),
        'impacto ${impactLabel(i.impact).toLowerCase()}${i.impactConfirmed ? '' : ' sin confirmar'}',
        ...issues.map(issueLabel),
      ].join('. '),
      excludeSemantics: true,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RefRadius.tile),
          side: BorderSide(color: issues.isEmpty ? c.outline : c.onSurface, width: issues.isEmpty ? 2 : 3),
        ),
        child: InkWell(
          key: ValueKey('incident-${i.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(RefRadius.tile),
          child: Padding(
            padding: const EdgeInsets.all(RefSpace.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 76,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        minute,
                        style: RefType.control.copyWith(color: c.onSurface, fontFeatures: RefType.tabular, fontSize: 22),
                      ),
                      Text(period == null ? '—' : periodLabel(period), style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: RefSpace.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kCategoryLabel[i.category]!, style: RefType.control.copyWith(color: c.onSurface)),
                      if (i.infraction != null)
                        Text(
                          '${i.infraction!.label}${i.infraction!.lawRef == null ? '' : ' · ${i.infraction!.lawRef}'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: RefType.caption.copyWith(color: c.onSurface),
                        ),
                      const SizedBox(height: RefSpace.xs),
                      Wrap(
                        spacing: RefSpace.xs,
                        runSpacing: RefSpace.xs,
                        children: [
                          _Tag(icon: verdictIcon(i.verdict), text: verdictLabel(i.verdict), bg: vBg, fg: vFg),
                          _Tag(
                            icon: Icons.bolt_rounded,
                            text: 'Impacto ${impactLabel(i.impact).toLowerCase()}${i.impactConfirmed ? '' : ' ?'}',
                            bg: c.background,
                            fg: c.onSurface,
                            outline: c.outline,
                          ),
                        ],
                      ),
                      for (final issue in issues)
                        Padding(
                          padding: const EdgeInsets.only(top: RefSpace.xs),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, size: 18, color: c.onSurface),
                              const SizedBox(width: RefSpace.xs),
                              Expanded(
                                child: Text(issueLabel(issue), style: RefType.caption.copyWith(color: c.onSurface)),
                              ),
                            ],
                          ),
                        ),
                      if ((i.notes ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: RefSpace.xs),
                          child: Text(
                            i.notes!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: RefType.caption.copyWith(color: c.onSurfaceMuted),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.onSurface),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text, required this.bg, required this.fg, this.outline});
  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;
  final Color? outline;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: RefSpace.s, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(RefRadius.pill),
      border: outline == null ? null : Border.all(color: outline!, width: 1.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: fg),
        const SizedBox(width: RefSpace.xs),
        Flexible(
          child: Text(text, style: RefType.caption.copyWith(color: fg)),
        ),
      ],
    ),
  );
}

class _Centered extends StatelessWidget {
  const _Centered({required this.icon, required this.title, this.body, this.action, this.actionKey});
  final IconData? icon;
  final String title;
  final String? body;
  final (String, VoidCallback)? action;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(RefSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == null)
              SizedBox.square(dimension: 48, child: CircularProgressIndicator(color: c.primary, strokeWidth: 5))
            else
              Icon(icon, size: 64, color: c.onSurface),
            const SizedBox(height: RefSpace.l),
            Text(
              title,
              textAlign: TextAlign.center,
              style: RefType.control.copyWith(color: c.onSurface, fontSize: 22),
            ),
            if (body != null) ...[
              const SizedBox(height: RefSpace.s),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: RefType.body.copyWith(color: c.onSurfaceMuted),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: RefSpace.xl),
              SizedBox(
                height: RefTouch.control,
                child: FilledButton.icon(
                  key: actionKey,
                  onPressed: action!.$2,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(action!.$1),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: c.onPrimary,
                    textStyle: context.refText(RefType.control),
                    padding: const EdgeInsets.symmetric(horizontal: RefSpace.xl),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
