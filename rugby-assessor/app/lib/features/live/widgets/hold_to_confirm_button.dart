import 'package:flutter/material.dart';

import '../../../core/design_system/tokens.dart';

/// Botón de "mantener pulsado para confirmar" para acciones irreversibles en directo.
/// Sustituye al diálogo de confirmación: no obliga a leer, y un roce no basta para dispararlo.
/// El progreso es información esencial: se muestra también con movimiento reducido.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    required this.background,
    required this.foreground,
    this.icon,
    this.hint,
    this.duration = RefMotion.holdToConfirm,
  });

  final String label;
  final String? hint;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final Duration duration;
  final VoidCallback onConfirmed;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton> with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(vsync: this, duration: widget.duration)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onConfirmed();
        _progress.value = 0;
      }
    });

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _start() => _progress.forward(from: 0);
  void _cancel() {
    if (_progress.status != AnimationStatus.completed) _progress.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      hint: widget.hint,
      // Lector de pantalla: la doble pulsación confirma directamente.
      onTap: widget.onConfirmed,
      excludeSemantics: true,
      // Listener (no GestureDetector): el progreso arranca en el mismo frame del contacto,
      // sin la espera de ~100 ms con la que el reconocedor de taps distingue un toque.
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _start(),
        onPointerUp: (_) => _cancel(),
        onPointerCancel: (_) => _cancel(),
        child: SizedBox(
          height: RefTouch.control,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RefRadius.control),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: widget.background),
                // El progreso se pinta como un velo del color del texto: el contraste del texto
                // se mantiene ≥ 7:1 en todo el recorrido.
                AnimatedBuilder(
                  animation: _progress,
                  builder: (context, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress.value,
                    child: ColoredBox(color: widget.foreground.withValues(alpha: 0.28)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: RefSpace.l),
                  child: Row(
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: widget.foreground, size: 26),
                        const SizedBox(width: RefSpace.s),
                      ],
                      Expanded(
                        child: Text(widget.label, style: RefType.control.copyWith(color: widget.foreground)),
                      ),
                      Text('Mantén', style: RefType.caption.copyWith(color: widget.foreground)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
