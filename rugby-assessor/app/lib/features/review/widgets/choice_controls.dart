import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';

/// Opción de una rejilla de selección única.
class ChoiceOption<T> {
  const ChoiceOption({
    required this.value,
    required this.label,
    this.hint,
    this.icon,
    this.selectedBackground,
    this.selectedForeground,
  });
  final T value;
  final String label;
  final String? hint;
  final IconData? icon;
  final Color? selectedBackground;
  final Color? selectedForeground;
}

/// Rejilla de selección única con botones grandes (≥ 64 dp). La opción elegida se distingue por
/// relleno, borde grueso e icono de check: nunca solo por color.
class ChoiceGrid<T> extends StatelessWidget {
  const ChoiceGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.columns = 2,
    this.keyPrefix = 'choice',
  });

  final List<ChoiceOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final int columns;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final rows = <List<ChoiceOption<T>>>[];
    for (var i = 0; i < options.length; i += columns) {
      rows.add(options.sublist(i, (i + columns).clamp(0, options.length)));
    }
    return Column(
      children: [
        for (final (ri, row) in rows.indexed) ...[
          if (ri > 0) const SizedBox(height: RefTouch.gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var ci = 0; ci < columns; ci++) ...[
                  if (ci > 0) const SizedBox(width: RefTouch.gap),
                  Expanded(
                    child: ci < row.length
                        ? _ChoiceButton<T>(
                            key: ValueKey('$keyPrefix-${row[ci].value is Enum ? (row[ci].value as Enum).name : row[ci].value}'),
                            option: row[ci],
                            selected: row[ci].value == selected,
                            onTap: () => onSelected(row[ci].value),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ChoiceButton<T> extends StatelessWidget {
  const _ChoiceButton({super.key, required this.option, required this.selected, required this.onTap});
  final ChoiceOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final bg = selected ? (option.selectedBackground ?? c.primary) : c.surface;
    final fg = selected ? (option.selectedForeground ?? c.onPrimary) : c.onSurface;
    final muted = selected ? fg : c.onSurfaceMuted;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: option.hint == null ? option.label : '${option.label}. ${option.hint}',
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RefRadius.control),
          side: BorderSide(color: selected ? c.onSurface : c.outline, width: selected ? 4 : 2),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RefRadius.control),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: RefTouch.control),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RefSpace.m, vertical: RefSpace.s),
              child: Row(
                children: [
                  Icon(selected ? Icons.check_circle_rounded : (option.icon ?? Icons.circle_outlined), color: fg, size: 26),
                  const SizedBox(width: RefSpace.s),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.label, style: RefType.control.copyWith(color: fg)),
                        if (option.hint != null) Text(option.hint!, style: RefType.caption.copyWith(color: muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Selección múltiple en "pastillas" de 48 dp de alto.
class ChipMultiSelect<T> extends StatelessWidget {
  const ChipMultiSelect({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.keyPrefix = 'chip',
    this.single = false,
  });

  final List<T> values;
  final Set<T> selected;
  final String Function(T) labelOf;
  final ValueChanged<Set<T>> onChanged;
  final String keyPrefix;

  /// Si es true, se comporta como selección única que se puede desmarcar.
  final bool single;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Wrap(
      spacing: RefTouch.gap,
      runSpacing: RefTouch.gap,
      children: [
        for (final v in values)
          Semantics(
            button: true,
            selected: selected.contains(v),
            label: labelOf(v),
            excludeSemantics: true,
            child: Material(
              color: selected.contains(v) ? c.onSurface : c.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RefRadius.pill),
                side: BorderSide(color: c.outline, width: 2),
              ),
              child: InkWell(
                key: ValueKey('$keyPrefix-${v is Enum ? v.name : v}'),
                borderRadius: BorderRadius.circular(RefRadius.pill),
                onTap: () {
                  final next = {...selected};
                  if (next.contains(v)) {
                    next.remove(v);
                  } else {
                    if (single) next.clear();
                    next.add(v);
                  }
                  onChanged(next);
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: RefTouch.minTarget),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: RefSpace.l),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected.contains(v)) ...[
                          Icon(Icons.check_rounded, size: 20, color: c.background),
                          const SizedBox(width: RefSpace.xs),
                        ],
                        Text(
                          labelOf(v),
                          style: RefType.caption.copyWith(fontSize: 16, color: selected.contains(v) ? c.background : c.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Título de sección con marca de obligatorio y mensaje de error junto al campo.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.required = false, this.error, this.subtitle});
  final String title;
  final bool required;
  final String? error;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Padding(
      padding: const EdgeInsets.only(top: RefSpace.xl, bottom: RefSpace.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: title),
                  if (required)
                    TextSpan(
                      text: '  · obligatorio',
                      style: RefType.caption.copyWith(color: c.onSurfaceMuted),
                    ),
                ],
              ),
              style: RefType.status.copyWith(color: c.onSurface),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: RefSpace.xs),
            Text(subtitle!, style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
          ],
          if (error != null) ...[
            const SizedBox(height: RefSpace.xs),
            Semantics(
              liveRegion: true,
              child: Row(
                children: [
                  Icon(Icons.error_rounded, size: 20, color: c.negative),
                  const SizedBox(width: RefSpace.xs),
                  Expanded(
                    child: Text(error!, style: RefType.caption.copyWith(color: c.negative)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
