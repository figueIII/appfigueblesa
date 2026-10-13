import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';
import '../../../domain/clock.dart';
import '../live_controller.dart';
import 'hold_to_confirm_button.dart';

/// Opciones del reloj, fuera de la zona de juego para que no se toquen sin querer:
/// ajuste fino con el reloj oficial, fin de periodo (mantener pulsado) y deshacer.
Future<void> showClockMenuSheet(BuildContext context, LiveController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _ClockMenu(controller: controller),
    ),
  );
}

class _ClockMenu extends StatelessWidget {
  const _ClockMenu({required this.controller});
  final LiveController controller;

  void _apply(BuildContext context, ClockEventBody body, {bool close = false}) {
    final error = controller.applyClock(body);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No permitido: ${error.code.name}')));
    } else if (close) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final playing = controller.clockState.isPlaying;
    final mt = controller.matchTimeAt(controller.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(RefSpace.l, 0, RefSpace.l, RefSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text('Reloj', style: RefType.control.copyWith(color: c.onSurface))),
          const SizedBox(height: RefSpace.l),
          Text('Ajustar al reloj oficial', style: RefType.status.copyWith(color: c.onSurfaceMuted)),
          const SizedBox(height: RefSpace.s),
          Text(
            playing ? 'Ahora: ${formatClock(mt.matchClockMs)}' : 'Solo con el periodo en marcha o parado.',
            style: RefType.body.copyWith(color: c.onSurface, fontFeatures: RefType.tabular),
          ),
          const SizedBox(height: RefSpace.s),
          Row(
            children: [
              for (final (i, (label, delta)) in const [('−1:00', -60000), ('−0:10', -10000), ('+0:10', 10000), ('+1:00', 60000)].indexed) ...[
                if (i > 0) const SizedBox(width: RefTouch.gap),
                Expanded(
                  child: SizedBox(
                    height: RefTouch.control,
                    child: OutlinedButton(
                      key: ValueKey('adjust-$delta'),
                      onPressed: playing ? () => _apply(context, Adjust(delta)) : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.onSurface,
                        side: BorderSide(color: c.outline, width: 2),
                        textStyle: context.refText(RefType.control.copyWith(fontFeatures: RefType.tabular)),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
                      ),
                      child: Text(label),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (controller.endPeriodOptions.isNotEmpty) ...[
            const SizedBox(height: RefSpace.xl),
            Text('Cerrar periodo', style: RefType.status.copyWith(color: c.onSurfaceMuted)),
            const SizedBox(height: RefSpace.s),
            for (final option in controller.endPeriodOptions) ...[
              HoldToConfirmButton(
                key: ValueKey('end-${option.next.name}'),
                label: option.label,
                hint: 'Mantén pulsado para confirmar',
                icon: Icons.sports_rounded,
                background: c.onSurface,
                foreground: c.background,
                onConfirmed: () => _apply(context, PeriodEnd(option.next), close: true),
              ),
              const SizedBox(height: RefTouch.gap),
            ],
          ],
          const SizedBox(height: RefSpace.l),
          SizedBox(
            height: RefTouch.control,
            child: OutlinedButton.icon(
              key: const ValueKey('undo-clock'),
              onPressed: controller.canUndoClock
                  ? () {
                      final error = controller.undoLastClockEvent();
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No permitido: ${error.code.name}')));
                      }
                    }
                  : null,
              icon: const Icon(Icons.undo_rounded),
              label: const Text('Deshacer último cambio de reloj'),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.onSurface,
                side: BorderSide(color: c.outline, width: 2),
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
