import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';
import '../../../domain/clock.dart';
import '../../../domain/laws.dart';
import '../../../domain/model.dart';
import '../../common/infraction_picker.dart';
import '../live_controller.dart';
import '../live_labels.dart';

/// Tira inferior de altura FIJA (no desplaza la rejilla). Tres estados:
///  · vacío: indica qué hacer;
///  · valoración (10 s tras una marca): ✓ Bien / ✗ Error / Ley / Deshacer, con cuenta atrás;
///  · reposo: resumen de la última marca.
/// Valorar es opcional: si no se toca nada, la marca queda "Por revisar".
class RefineStrip extends StatefulWidget {
  const RefineStrip({super.key, required this.controller, this.onEdit});
  final LiveController controller;

  /// Abre el editor completo de una marca (veredicto, impacto, decisiones, ley, notas) sin
  /// esperar al final del partido. null = sin acceso al editor.
  final ValueChanged<String>? onEdit;

  static const double height = 130;

  @override
  State<RefineStrip> createState() => _RefineStripState();
}

class _RefineStripState extends State<RefineStrip> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctl = widget.controller;
    final last = ctl.lastIncident;
    final now = ctl.now();
    return SizedBox(
      height: RefineStrip.height,
      child: switch (last) {
        null => const _EmptyHint(),
        final i when ctl.canRefine(now) =>
          _RefineControls(controller: ctl, incident: i, remainingMs: ctl.refineUntil - now, onEdit: widget.onEdit),
        final i => _LastSummary(controller: ctl, incident: i, onEdit: widget.onEdit),
      },
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Row(
      children: [
        ExcludeSemantics(child: Icon(Icons.touch_app_rounded, size: 32, color: c.onSurfaceMuted)),
        const SizedBox(width: RefSpace.m),
        Expanded(
          child: Text(
            'Toca una acción para marcarla con el minuto. Puedes valorarla al momento o más tarde.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: RefType.body.copyWith(color: c.onSurfaceMuted),
          ),
        ),
      ],
    );
  }
}

String _incidentTitle(LiveController ctl, Incident i) =>
    '${incidentHeadline(i, ctl.teamName)} · ${formatClock(i.matchTime.matchClockMs)}';

/// "Editar" (≥ 48 dp): abre el editor completo de la marca.
class _EditButton extends StatelessWidget {
  const _EditButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return TextButton.icon(
      key: const ValueKey('edit-last'),
      onPressed: onPressed,
      icon: const Icon(Icons.edit_rounded, size: 20),
      label: const Text('Editar'),
      style: TextButton.styleFrom(
        foregroundColor: c.primary,
        minimumSize: const Size(RefTouch.minTarget, RefTouch.minTarget),
        padding: const EdgeInsets.symmetric(horizontal: RefSpace.s),
        textStyle: context.refText(RefType.caption.copyWith(fontSize: 16)),
      ),
    );
  }
}

class _LastSummary extends StatelessWidget {
  const _LastSummary({required this.controller, required this.incident, this.onEdit});
  final LiveController controller;
  final Incident incident;
  final ValueChanged<String>? onEdit;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final voided = incident.status == IncidentStatus.voided;
    return Row(
      children: [
        ExcludeSemantics(
          child: Icon(voided ? Icons.undo_rounded : polarityIcon(incident.polarity), size: 28, color: c.onSurfaceMuted),
        ),
        const SizedBox(width: RefSpace.m),
        Expanded(
          child: Text(
            voided
                ? 'Anulada: ${_incidentTitle(controller, incident)}'
                : 'Última: ${_incidentTitle(controller, incident)} · ${polarityLabel(incident.polarity)}'
                    '${incident.infraction == null ? '' : ' · ${incident.infraction!.label}'}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: RefType.body.copyWith(
              color: c.onSurfaceMuted,
              decoration: voided ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (!voided && onEdit != null) _EditButton(onPressed: () => onEdit!(incident.id)),
      ],
    );
  }
}

class _RefineControls extends StatelessWidget {
  const _RefineControls({required this.controller, required this.incident, required this.remainingMs, this.onEdit});
  final LiveController controller;
  final Incident incident;
  final int remainingMs;
  final ValueChanged<String>? onEdit;

  /// La ley se asigna a ESTA marca aunque la ventana de 10 s termine mientras se elige.
  Future<void> _pickLaw(BuildContext context) async {
    final id = incident.id;
    final choice = await showInfractionPicker(
      context,
      title: 'Ley · ${_incidentTitle(controller, incident)}',
      subtitle: 'Vale tanto si la decisión fue correcta como si fue un error.',
      groups: lawGroupsFor(incident.category),
      current: incident.infraction,
    );
    if (choice != null) controller.setIncidentInfraction(id, choice.value);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final fraction = (remainingMs / RefMotion.refineWindow.inMilliseconds).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Marcado: ${_incidentTitle(controller, incident)}',
                    maxLines: 1,
                    style: RefType.control.copyWith(color: c.onSurface),
                  ),
                ),
              ),
            ),
            const SizedBox(width: RefSpace.s),
            if (onEdit != null)
              _EditButton(onPressed: () => onEdit!(incident.id))
            else
              Text(polarityLabel(incident.polarity), maxLines: 1, style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
          ],
        ),
        const SizedBox(height: RefSpace.xs),
        // Cuenta atrás de la ventana de valoración: información, no decoración.
        ExcludeSemantics(
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 4,
            color: c.outline,
            backgroundColor: c.surface,
          ),
        ),
        const SizedBox(height: RefSpace.s),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StripButton(
                  key: const ValueKey('refine-positive'),
                  label: 'Bien',
                  icon: Icons.check_rounded,
                  selected: incident.polarity == QuickPolarity.positive,
                  bg: c.positive,
                  fg: c.onPositive,
                  onPressed: () => controller.refineLast(QuickPolarity.positive),
                ),
              ),
              const SizedBox(width: RefTouch.gap),
              Expanded(
                child: _StripButton(
                  key: const ValueKey('refine-negative'),
                  label: 'Error',
                  icon: Icons.close_rounded,
                  selected: incident.polarity == QuickPolarity.negative,
                  bg: c.negative,
                  fg: c.onNegative,
                  onPressed: () => controller.refineLast(QuickPolarity.negative),
                ),
              ),
              const SizedBox(width: RefTouch.gap),
              Expanded(
                child: _StripButton(
                  key: const ValueKey('refine-law'),
                  label: 'Ley',
                  icon: Icons.menu_book_rounded,
                  selected: incident.infraction != null,
                  bg: c.surface,
                  fg: c.onSurface,
                  outline: c.outline,
                  semanticsLabel: incident.infraction == null ? 'Asignar ley' : 'Ley: ${incident.infraction!.label}',
                  onPressed: () => _pickLaw(context),
                ),
              ),
              const SizedBox(width: RefTouch.gap),
              Expanded(
                child: _StripButton(
                  key: const ValueKey('refine-undo'),
                  label: 'Deshacer',
                  icon: Icons.undo_rounded,
                  selected: false,
                  bg: c.surface,
                  fg: c.onSurface,
                  outline: c.outline,
                  onPressed: controller.undoLast,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StripButton extends StatelessWidget {
  const _StripButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.bg,
    required this.fg,
    required this.onPressed,
    this.outline,
    this.semanticsLabel,
  });

  final String? semanticsLabel;
  final String label;
  final IconData icon;
  final bool selected;
  final Color bg;
  final Color fg;
  final Color? outline;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Semantics(
      selected: selected,
      label: semanticsLabel,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: const Size(RefTouch.minTarget, RefTouch.control),
          padding: const EdgeInsets.symmetric(horizontal: RefSpace.s),
          textStyle: context.refText(RefType.control),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RefRadius.control),
            // La opción elegida se marca con un borde grueso + icono de check: no solo color.
            side: BorderSide(
              color: selected ? c.onSurface : (outline ?? bg),
              width: selected ? 4 : 2,
            ),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? Icons.radio_button_checked_rounded : icon, size: 26),
              const SizedBox(width: RefSpace.xs),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
