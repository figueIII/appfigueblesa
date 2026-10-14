import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';
import '../../../core/i18n.dart';
import '../../../domain/rubric.dart';
import '../evaluation_labels.dart';

/// Pastilla de banda (icono + "E · Excelente"). `band == null` → "Sin valorar", en contorno.
class BandBadge extends StatelessWidget {
  const BandBadge({super.key, required this.band, required this.rubric, this.large = false, this.prefix});
  final BandCode? band;
  final AssessmentRubric rubric;
  final bool large;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final (bg, fg) = band == null ? (c.background, c.onSurfaceMuted) : bandColors(band!, c);
    final label = band == null ? tr('Sin valorar', 'Sense valorar') : bandFullLabel(rubric, band!);
    final style = (large ? RefType.control.copyWith(fontSize: 24) : RefType.caption.copyWith(fontSize: 15)).copyWith(color: fg);
    return Semantics(
      label: '${prefix ?? ''}$label',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: large ? RefSpace.l : RefSpace.s, vertical: large ? RefSpace.m : 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(large ? RefRadius.control : RefRadius.pill),
          border: band == null ? Border.all(color: c.outline, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(band == null ? Icons.remove_rounded : bandIcon(band!), size: large ? 32 : 18, color: fg),
            SizedBox(width: large ? RefSpace.s : RefSpace.xs),
            Flexible(child: Text('${prefix ?? ''}$label', style: style)),
          ],
        ),
      ),
    );
  }
}

/// Selector de la escala E / C / N / U: cuatro botones grandes en fila, en el orden del CARC. El
/// elegido va relleno con su color, borde de 4 dp y check; el sugerido lleva la marca "Sugerida".
/// Tocar el elegido otra vez lo desmarca (la valoración es opcional).
class BandSelector extends StatelessWidget {
  const BandSelector({
    super.key,
    required this.rubric,
    required this.selected,
    required this.suggested,
    required this.onSelected,
    this.capBand,
    this.enabled = true,
    this.keyPrefix = 'band',
  });

  final AssessmentRubric rubric;
  final BandCode? selected;
  final BandCode? suggested;
  final BandCode? capBand;
  final ValueChanged<BandCode> onSelected;
  final bool enabled;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, b) in kBandsInDisplayOrder.indexed) ...[
            if (i > 0) const SizedBox(width: RefTouch.gap),
            Expanded(child: _option(context, c, b)),
          ],
        ],
      ),
    );
  }

  Widget _option(BuildContext context, RefColors c, BandCode b) {
    final isSel = selected == b;
    final (sbg, sfg) = bandColors(b, c);
    final bg = isSel ? sbg : c.surface;
    final fg = isSel ? sfg : c.onSurface;
    final overCap = capBand != null && b.index > capBand!.index;
    return Semantics(
      button: true,
      selected: isSel,
      inMutuallyExclusiveGroup: true,
      enabled: enabled,
      label: [bandFullLabel(rubric, b), if (suggested == b) tr('sugerida', 'suggerida'), if (overCap) tr('por encima del tope', 'per sobre del topall')]
          .join(', '),
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RefRadius.control),
          side: BorderSide(color: isSel ? c.onSurface : c.outline, width: isSel ? 4 : 2),
        ),
        child: InkWell(
          key: ValueKey('$keyPrefix-${b.name}'),
          onTap: enabled ? () => onSelected(b) : null,
          borderRadius: BorderRadius.circular(RefRadius.control),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 88),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: RefSpace.s),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSel) ...[Icon(Icons.check_circle_rounded, color: fg, size: 20), const SizedBox(width: 2)],
                      Text(rubric.band(b).letter, style: RefType.control.copyWith(color: fg, fontSize: 26, height: 1.1)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(bandShort(b), textAlign: TextAlign.center, style: RefType.caption.copyWith(color: fg, fontSize: 14)),
                  ),
                  if (suggested == b || overCap) ...[
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        suggested == b ? tr('Sugerida', 'Suggerida') : tr('Sobre el tope', 'Sobre el topall'),
                        textAlign: TextAlign.center,
                        style: RefType.caption.copyWith(color: fg, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
