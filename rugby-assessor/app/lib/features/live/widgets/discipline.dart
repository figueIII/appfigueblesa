import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';
import '../../../domain/clock.dart';
import '../../../domain/match_facts.dart';
import '../../../domain/model.dart';
import '../../common/infraction_picker.dart';
import '../../review/widgets/choice_controls.dart';
import '../live_controller.dart';

/// Tarjeta dibujada (amarilla o roja), con borde oscuro: se distingue también sin color.
class CardGlyph extends StatelessWidget {
  const CardGlyph({super.key, required this.kind, this.height = 16});
  final SanctionKind kind;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Container(
          width: height * 0.72,
          height: height,
          decoration: BoxDecoration(
            color: kind == SanctionKind.yellowCard ? RefCardColors.yellow : RefCardColors.red,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: RefCardColors.border, width: 1.2),
          ),
        ),
      );
}

String _plural(int n, String one, String many) => '$n ${n == 1 ? one : many}';

/// Contador de sanciones siempre visible: GC · GF · amarillas · rojas de cada equipo.
/// Un toque abre el panel con el desglose y el registro.
class DisciplineBar extends StatelessWidget {
  const DisciplineBar({super.key, required this.controller, required this.onOpen});
  final LiveController controller;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final tally = controller.sanctionTally;
    final num = RefType.caption.copyWith(color: c.onSurface, fontWeight: FontWeight.w800, fontSize: 15);
    final head = RefType.caption.copyWith(color: c.onSurfaceMuted, fontSize: 12);
    String spoken(TeamSide t) => '${controller.teamName(t)}: '
        '${_plural(tally.count(t, SanctionKind.penalty), 'golpe de castigo', 'golpes de castigo')}, '
        '${_plural(tally.count(t, SanctionKind.freeKick), 'golpe franco', 'golpes francos')}, '
        '${_plural(tally.count(t, SanctionKind.yellowCard), 'amarilla', 'amarillas')}, '
        '${_plural(tally.count(t, SanctionKind.redCard), 'roja', 'rojas')}';

    TableRow row(TeamSide t) => TableRow(
          children: [
            Text(controller.teamName(t), maxLines: 1, overflow: TextOverflow.ellipsis, style: RefType.caption.copyWith(color: c.onSurface)),
            for (final k in SanctionKind.values)
              Text('${tally.count(t, k)}', key: ValueKey('tally-${t.name}-${k.name}'), textAlign: TextAlign.center, style: num),
          ],
        );

    return Semantics(
      button: true,
      label: 'Sanciones. ${spoken(TeamSide.home)}. ${spoken(TeamSide.away)}. Toca para ver el desglose y registrar.',
      excludeSemantics: true,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RefRadius.control),
          side: BorderSide(color: c.outline, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const ValueKey('discipline-bar'),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(RefSpace.m, RefSpace.xs, RefSpace.s, RefSpace.xs),
            child: Row(
              children: [
                Expanded(
                  child: Table(
                    columnWidths: const {0: FlexColumnWidth(), 1: FixedColumnWidth(34), 2: FixedColumnWidth(34), 3: FixedColumnWidth(30), 4: FixedColumnWidth(30)},
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          Text('SANCIONES', style: head.copyWith(letterSpacing: 0.6)),
                          Text('GC', textAlign: TextAlign.center, style: head),
                          Text('GF', textAlign: TextAlign.center, style: head),
                          const Center(child: CardGlyph(kind: SanctionKind.yellowCard, height: 13)),
                          const Center(child: CardGlyph(kind: SanctionKind.redCard, height: 13)),
                        ],
                      ),
                      row(TeamSide.home),
                      row(TeamSide.away),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.onSurfaceMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Panel de sanciones: elegir el equipo infractor, registrar GC/GF/tarjetas con su motivo y ver
/// el desglose acumulado ("3× Fuera de juego").
Future<void> showSanctionsSheet(BuildContext context, LiveController controller, {TeamSide initialTeam = TeamSide.home}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 1,
        builder: (context, scroll) => _SanctionsSheet(controller: controller, scroll: scroll, initialTeam: initialTeam),
      ),
    );

class _SanctionsSheet extends StatefulWidget {
  const _SanctionsSheet({required this.controller, required this.scroll, required this.initialTeam});
  final LiveController controller;
  final ScrollController scroll;
  final TeamSide initialTeam;

  @override
  State<_SanctionsSheet> createState() => _SanctionsSheetState();
}

class _SanctionsSheetState extends State<_SanctionsSheet> {
  late TeamSide _team = widget.initialTeam;
  LiveController get _ctl => widget.controller;

  /// El instante se toma al tocar el botón, no al elegir el motivo.
  Future<void> _register(SanctionKind kind) async {
    final t = _ctl.now();
    final team = _team;
    final choice = await showInfractionPicker(
      context,
      title: '${sanctionKindLabel(kind)} · ${_ctl.teamName(team)}',
      subtitle: 'Motivo de la sanción (equipo infractor: ${_ctl.teamName(team)}).',
      allowUnspecified: true,
    );
    if (choice == null) return; // cancelado: no se registra nada
    _ctl.logSanction(team, kind, t: t, infraction: choice.value);
    // La sanción es una marca: se cierra el panel para valorarla al momento en la tira
    // (Bien / Error / Ley / Deshacer), como cualquier otra.
    if (mounted) Navigator.of(context).pop();
  }

  /// Completa el motivo de una sanción registrada "sin especificar".
  Future<void> _complete(SanctionEvent s) async {
    final choice = await showInfractionPicker(
      context,
      title: '${sanctionKindLabel(s.kind)} · ${formatClock(s.matchClockMs)}',
      subtitle: 'Completa el motivo.',
      current: s.infraction,
    );
    if (choice != null) _ctl.setIncidentInfraction(s.incidentId, choice.value);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return ListenableBuilder(
      listenable: _ctl,
      builder: (context, _) {
        final tally = _ctl.sanctionTally;
        final rows = _ctl.breakdown(_team);
        final cards = _ctl.cards(_team);
        final last = _ctl.lastSanction;
        final firstUnspecified = [
          for (final s in _ctl.sanctions)
            if (!s.voided && !s.isCard && s.team == _team && s.infraction == null) s,
        ];

        Widget register(SanctionKind kind, IconData? icon) => Expanded(
              child: SizedBox(
                height: RefTouch.control,
                child: FilledButton(
                  key: ValueKey('sanction-add-${kind.name}'),
                  onPressed: () => _register(kind),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.surface,
                    foregroundColor: c.onSurface,
                    textStyle: context.refText(RefType.control.copyWith(fontSize: 16)),
                    padding: const EdgeInsets.symmetric(horizontal: RefSpace.s),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RefRadius.control),
                      side: BorderSide(color: c.outline, width: 2),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) Icon(icon, size: 22) else CardGlyph(kind: kind, height: 22),
                        const SizedBox(width: RefSpace.s),
                        Text(sanctionKindLabel(kind)),
                      ],
                    ),
                  ),
                ),
              ),
            );

        return ListView(
          controller: widget.scroll,
          padding: const EdgeInsets.fromLTRB(RefSpace.l, 0, RefSpace.l, RefSpace.xl),
          children: [
            Semantics(header: true, child: Text('Sanciones del árbitro', style: RefType.control.copyWith(color: c.onSurface))),
            const SizedBox(height: RefSpace.xs),
            Text(
              'Cada sanción queda como una marca: al registrarla, valórala con Bien o Error como las demás.',
              style: RefType.caption.copyWith(color: c.onSurfaceMuted),
            ),
            const SizedBox(height: RefSpace.m),
            Text('Equipo infractor', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
            const SizedBox(height: RefSpace.xs),
            ChoiceGrid<TeamSide>(
              keyPrefix: 'sanction-team',
              selected: _team,
              onSelected: (t) => setState(() => _team = t),
              options: [
                for (final t in TeamSide.values)
                  ChoiceOption(
                    value: t,
                    label: _ctl.teamName(t),
                    hint: tally.total(t) == 1 ? '1 sanción' : '${tally.total(t)} sanciones',
                  ),
              ],
            ),
            const SizedBox(height: RefSpace.m),
            Semantics(
              liveRegion: true,
              child: Text(
                [
                  for (final k in SanctionKind.values) '${sanctionKindShort(k)} ${tally.count(_team, k)}',
                ].join('  ·  '),
                key: const ValueKey('sanction-team-tally'),
                style: RefType.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w800, fontFeatures: RefType.tabular),
              ),
            ),
            const SizedBox(height: RefSpace.s),
            Row(children: [
              register(SanctionKind.penalty, Icons.sports_rounded),
              const SizedBox(width: RefTouch.gap),
              register(SanctionKind.freeKick, Icons.flag_rounded),
            ]),
            const SizedBox(height: RefTouch.gap),
            Row(children: [
              register(SanctionKind.yellowCard, null),
              const SizedBox(width: RefTouch.gap),
              register(SanctionKind.redCard, null),
            ]),

            // ─── Desglose ───
            Padding(
              padding: const EdgeInsets.only(top: RefSpace.xl, bottom: RefSpace.xs),
              child: Semantics(
                header: true,
                child: Text('GOLPES POR MOTIVO', style: RefType.status.copyWith(color: c.onSurfaceMuted)),
              ),
            ),
            if (rows.isEmpty)
              Text('Sin golpes registrados contra ${_ctl.teamName(_team)}.', style: RefType.body.copyWith(color: c.onSurfaceMuted))
            else
              for (final r in rows)
                _BreakdownRow(
                  row: r,
                  onComplete: r.infraction == null && firstUnspecified.isNotEmpty ? () => _complete(firstUnspecified.first) : null,
                ),

            Padding(
              padding: const EdgeInsets.only(top: RefSpace.l, bottom: RefSpace.xs),
              child: Semantics(header: true, child: Text('TARJETAS', style: RefType.status.copyWith(color: c.onSurfaceMuted))),
            ),
            if (cards.isEmpty)
              Text('Sin tarjetas.', style: RefType.body.copyWith(color: c.onSurfaceMuted))
            else
              for (final card in cards)
                ListTile(
                  key: ValueKey('card-${card.id}'),
                  minTileHeight: RefTouch.minTarget + 8,
                  contentPadding: EdgeInsets.zero,
                  leading: CardGlyph(kind: card.kind, height: 24),
                  title: Text(
                    '${formatClock(card.matchClockMs)} · ${card.infraction?.label ?? kUnspecifiedInfractionLabel}',
                    style: RefType.body.copyWith(color: c.onSurface),
                  ),
                  subtitle: Text(sanctionKindLabel(card.kind), style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
                  trailing: Icon(Icons.edit_rounded, color: c.onSurfaceMuted),
                  onTap: () => _complete(card),
                ),

            const SizedBox(height: RefSpace.l),
            SizedBox(
              height: RefTouch.minTarget + 8,
              child: OutlinedButton.icon(
                key: const ValueKey('sanction-undo'),
                onPressed: last == null ? null : _ctl.undoLastSanction,
                icon: const Icon(Icons.undo_rounded),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    last == null
                        ? 'Deshacer última sanción'
                        : 'Deshacer: ${sanctionKindShort(last.kind)} · ${_ctl.teamName(last.team)} · ${formatClock(last.matchClockMs)}',
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.onSurface,
                  side: BorderSide(color: c.outline, width: 2),
                  textStyle: context.refText(RefType.caption.copyWith(fontSize: 16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.row, this.onComplete});
  final InfractionCount row;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final detail = [
      if (row.penalties > 0) 'GC ${row.penalties}',
      if (row.freeKicks > 0) 'GF ${row.freeKicks}',
      if (row.infraction?.lawRef != null) row.infraction!.lawRef!,
    ].join(' · ');
    return ListTile(
      key: ValueKey('breakdown-${row.infraction?.groupKey ?? 'unspecified'}'),
      minTileHeight: RefTouch.minTarget + 8,
      contentPadding: EdgeInsets.zero,
      title: Text('${row.total}× ${row.label}', style: RefType.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w700)),
      subtitle: Text(detail, style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
      trailing: onComplete == null
          ? null
          : TextButton(
              onPressed: onComplete,
              style: TextButton.styleFrom(minimumSize: const Size(RefTouch.minTarget, RefTouch.minTarget)),
              child: const Text('Completar'),
            ),
    );
  }
}
