import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';

/// Tesela de etiqueta. El instante se captura en el PRIMER contacto (onTapDown) y la marca se
/// confirma al levantar el dedo; si el dedo se desliza fuera, no se registra nada.
/// El estado pulsado se pinta en el mismo frame (sin animación) y no cambia el tamaño.
class TagTile extends StatefulWidget {
  const TagTile({
    super.key,
    required this.label,
    required this.onCommit,
    required this.captureInstant,
    this.count = 0,
    this.icon,
    this.semanticsHint,
  });

  final String label;
  final int count;
  final IconData? icon;
  final String? semanticsHint;

  /// Devuelve el instante actual del eje de sesión.
  final int Function() captureInstant;

  /// Recibe el instante capturado en onTapDown.
  final void Function(int t) onCommit;

  @override
  State<TagTile> createState() => _TagTileState();
}

class _TagTileState extends State<TagTile> {
  bool _pressed = false;
  bool _flash = false;
  int? _downAt;
  Timer? _flashTimer;

  void _commit(int t) {
    widget.onCommit(t);
    _flashTimer?.cancel();
    setState(() {
      _pressed = false;
      _flash = true;
    });
    _flashTimer = Timer(RefMotion.confirmFlash, () {
      if (mounted) setState(() => _flash = false);
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final borderColor = _flash ? c.primary : c.outline;
    return Semantics(
      button: true,
      label: widget.label,
      value: widget.count == 0 ? null : '${widget.count} ${widget.count == 1 ? 'marca' : 'marcas'}',
      hint: widget.semanticsHint ?? 'Marca esta acción con el minuto actual',
      excludeSemantics: true,
      onTap: () => _commit(widget.captureInstant()),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() {
          _downAt = widget.captureInstant();
          _pressed = true;
        }),
        onTapCancel: () => setState(() {
          _downAt = null;
          _pressed = false;
        }),
        onTap: () => _commit(_downAt ?? widget.captureInstant()),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: RefTouch.minTarget, minWidth: RefTouch.minTarget),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _pressed || _flash ? c.surfacePressed : c.surface,
              borderRadius: BorderRadius.circular(RefRadius.tile),
              // Grosor fijo: solo cambia el color, nunca la geometría.
              border: Border.all(color: borderColor, width: 3),
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: RefSpace.s, vertical: RefSpace.xs),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 28, color: c.onSurface),
                            const SizedBox(height: RefSpace.xs),
                          ],
                          Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: RefType.tile.copyWith(color: c.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.count > 0)
                  Positioned(
                    right: RefSpace.s,
                    bottom: RefSpace.xs,
                    child: Text('×${widget.count}', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
