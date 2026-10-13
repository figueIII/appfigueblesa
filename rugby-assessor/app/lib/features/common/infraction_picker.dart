import 'package:flutter/material.dart';

import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/laws.dart';

/// Resultado del selector. `value == null` = "sin especificar" o "quitar la ley".
/// Si el selector se cierra sin elegir, [showInfractionPicker] devuelve null (cancelado).
class InfractionChoice {
  const InfractionChoice(this.value);
  final InfractionRef? value;
}

/// Selector rápido de ley o infracción, agrupado por fase (los [groups] más probables primero).
/// - [allowUnspecified]: añade "Sin especificar" arriba (registrar ya, completar después).
/// - [current]: marca la elegida y añade "Quitar la ley".
Future<InfractionChoice?> showInfractionPicker(
  BuildContext context, {
  required String title,
  String? subtitle,
  List<LawGroup> groups = LawGroup.values,
  InfractionRef? current,
  bool allowUnspecified = false,
}) =>
    showModalBottomSheet<InfractionChoice>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 1,
        builder: (context, scroll) => _InfractionPicker(
          scroll: scroll,
          title: title,
          subtitle: subtitle,
          groups: groups,
          current: current,
          allowUnspecified: allowUnspecified,
        ),
      ),
    );

class _InfractionPicker extends StatelessWidget {
  const _InfractionPicker({
    required this.scroll,
    required this.title,
    required this.subtitle,
    required this.groups,
    required this.current,
    required this.allowUnspecified,
  });
  final ScrollController scroll;
  final String title;
  final String? subtitle;
  final List<LawGroup> groups;
  final InfractionRef? current;
  final bool allowUnspecified;

  Future<void> _custom(BuildContext context) async {
    final ref = await showDialog<InfractionRef>(
      context: context,
      builder: (_) => _CustomInfractionDialog(initial: current?.isCustom == true ? current : null),
    );
    if (ref != null && context.mounted) Navigator.of(context).pop(InfractionChoice(ref));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    Widget tile({
      required Key key,
      required String label,
      String? detail,
      IconData? icon,
      bool selected = false,
      required VoidCallback onTap,
    }) =>
        ListTile(
          key: key,
          minTileHeight: RefTouch.control,
          contentPadding: const EdgeInsets.symmetric(horizontal: RefSpace.s),
          selected: selected,
          selectedColor: c.onSurface,
          selectedTileColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RefRadius.control),
            side: selected ? BorderSide(color: c.onSurface, width: 3) : BorderSide.none,
          ),
          leading: icon == null && !selected ? null : Icon(selected ? Icons.check_circle_rounded : icon, color: c.onSurface),
          title: Text(label, style: RefType.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w700)),
          subtitle: detail == null ? null : Text(detail, style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
          onTap: onTap,
        );

    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(RefSpace.l, 0, RefSpace.l, RefSpace.xl),
      children: [
        Semantics(header: true, child: Text(title, style: RefType.control.copyWith(color: c.onSurface))),
        if (subtitle != null) ...[
          const SizedBox(height: RefSpace.xs),
          Text(subtitle!, style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
        ],
        const SizedBox(height: RefSpace.s),
        if (allowUnspecified)
          tile(
            key: const ValueKey('infraction-unspecified'),
            label: 'Sin especificar',
            detail: 'Regístralo ya; el motivo se puede completar después.',
            icon: Icons.bolt_rounded,
            onTap: () => Navigator.of(context).pop(const InfractionChoice(null)),
          ),
        if (current != null)
          tile(
            key: const ValueKey('infraction-clear'),
            label: 'Quitar la ley',
            icon: Icons.backspace_outlined,
            onTap: () => Navigator.of(context).pop(const InfractionChoice(null)),
          ),
        for (final g in groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: RefSpace.l, bottom: RefSpace.xs),
            child: Semantics(
              header: true,
              child: Text(lawGroupLabel(g).toUpperCase(), style: RefType.status.copyWith(color: c.onSurfaceMuted)),
            ),
          ),
          for (final i in infractionsIn(g))
            tile(
              key: ValueKey('infraction-${i.code}'),
              label: i.label,
              detail: '${i.english} · ${i.lawRef}',
              selected: current?.code == i.code,
              onTap: () => Navigator.of(context).pop(InfractionChoice(InfractionRef.catalog(i.code))),
            ),
        ],
        const SizedBox(height: RefSpace.l),
        tile(
          key: const ValueKey('infraction-custom'),
          label: 'Otra ley / infracción personalizada',
          detail: current?.isCustom == true ? 'Actual: ${current!.label}' : 'Escríbela tú (y, si quieres, su ley).',
          icon: Icons.edit_note_rounded,
          selected: current?.isCustom == true,
          onTap: () => _custom(context),
        ),
      ],
    );
  }
}

class _CustomInfractionDialog extends StatefulWidget {
  const _CustomInfractionDialog({this.initial});
  final InfractionRef? initial;

  @override
  State<_CustomInfractionDialog> createState() => _CustomInfractionDialogState();
}

class _CustomInfractionDialogState extends State<_CustomInfractionDialog> {
  late final _text = TextEditingController(text: widget.initial?.customText ?? '');
  late final _law = TextEditingController(text: widget.initial?.customLawRef ?? '');

  @override
  void dispose() {
    _text.dispose();
    _law.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ok = _text.text.trim().isNotEmpty;
    return AlertDialog(
      title: const Text('Otra ley / infracción'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const ValueKey('custom-infraction-text'),
            controller: _text,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Infracción', hintText: 'p. ej. Avance intencionado', border: OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: RefSpace.m),
          TextField(
            key: const ValueKey('custom-infraction-law'),
            controller: _law,
            decoration: const InputDecoration(labelText: 'Ley (opcional)', hintText: 'p. ej. Ley 11', border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          key: const ValueKey('custom-infraction-ok'),
          onPressed: ok ? () => Navigator.pop(context, InfractionRef.custom(_text.text, lawRef: _law.text)) : null,
          child: const Text('Usar'),
        ),
      ],
    );
  }
}
