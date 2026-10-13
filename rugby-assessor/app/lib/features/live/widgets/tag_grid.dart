import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';
import '../../../domain/clock.dart';
import '../../../domain/model.dart';
import '../live_controller.dart';
import '../live_labels.dart';
import 'tag_tile.dart';

/// Rejilla de 4 × 3 que ocupa todo el alto disponible: cuanto más grande, mejor se acierta
/// sin mirar. Las filas se reparten el espacio por igual.
class TagGrid extends StatelessWidget {
  const TagGrid({super.key, required this.controller});

  final LiveController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (rowIndex, row) in kPrimaryGrid.indexed) ...[
          if (rowIndex > 0) const SizedBox(height: RefTouch.tileGap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (colIndex, category) in row.indexed) ...[
                  if (colIndex > 0) const SizedBox(width: RefTouch.tileGap),
                  Expanded(child: _tileFor(context, category)),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _tileFor(BuildContext context, IncidentCategory? category) {
    if (category == null) {
      return TagTile(
        key: const ValueKey('tag-more'),
        label: 'Más…',
        icon: Icons.more_horiz_rounded,
        semanticsHint: 'Abre más acciones con el minuto de ahora',
        captureInstant: controller.now,
        onCommit: (t) => showMoreTagsSheet(context, controller, t),
      );
    }
    return TagTile(
      key: ValueKey('tag-${category.name}'),
      label: kCategoryLabel[category]!,
      count: controller.countFor(category),
      captureInstant: controller.now,
      onCommit: (t) => controller.logIncident(category, t: t),
    );
  }
}

/// Hoja con las categorías poco frecuentes. El minuto queda CONGELADO en el instante del tap
/// en "Más…": lo que tardes en elegir no desplaza la marca.
Future<void> showMoreTagsSheet(BuildContext context, LiveController controller, int t) {
  final frozen = formatClock(controller.matchTimeAt(t).matchClockMs);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final c = sheetContext.refColors;
      return Padding(
        padding: const EdgeInsets.fromLTRB(RefSpace.l, 0, RefSpace.l, RefSpace.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text('Marcar a las $frozen', style: RefType.control.copyWith(color: c.onSurface)),
            ),
            const SizedBox(height: RefSpace.xs),
            Text('El minuto ya está guardado; elige la acción.', style: RefType.body.copyWith(color: c.onSurfaceMuted)),
            const SizedBox(height: RefSpace.l),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: RefTouch.tileGap,
              crossAxisSpacing: RefTouch.tileGap,
              childAspectRatio: 2.2,
              children: [
                for (final category in kSecondaryCategories)
                  TagTile(
                    key: ValueKey('more-${category.name}'),
                    label: kCategoryLabel[category]!,
                    count: controller.countFor(category),
                    captureInstant: () => t,
                    onCommit: (_) {
                      controller.logIncident(category, t: t);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
              ],
            ),
            const SizedBox(height: RefSpace.l),
            SizedBox(
              height: RefTouch.control,
              child: OutlinedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.onSurface,
                  side: BorderSide(color: c.outline, width: 2),
                  textStyle: context.refText(RefType.control),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
                ),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
