import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';
import '../../../domain/clock.dart';
import '../../../domain/match_facts.dart';
import '../../../domain/model.dart';
import '../live_controller.dart';

/// Marcador en la cabecera: "Local 12 – 7 Visitante". Un toque abre la hoja de anotación.
class ScoreboardBar extends StatelessWidget {
  const ScoreboardBar({super.key, required this.controller, required this.onOpen});
  final LiveController controller;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final s = controller.scoreline;
    final team = RefType.caption.copyWith(color: c.onSurface, fontWeight: FontWeight.w700);
    return Semantics(
      button: true,
      label: 'Marcador: ${controller.homeTeam} ${s.home}, ${controller.awayTeam} ${s.away}. Toca para anotar.',
      excludeSemantics: true,
      child: InkWell(
        key: const ValueKey('scoreboard'),
        onTap: onOpen,
        borderRadius: BorderRadius.circular(RefRadius.control),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: RefTouch.minTarget),
          child: Row(
            children: [
              Expanded(
                child: Text(controller.homeTeam, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: team),
              ),
              const SizedBox(width: RefSpace.s),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: RefSpace.s, vertical: 2),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(RefRadius.control),
                  border: Border.all(color: c.outline, width: 1.5),
                ),
                child: Text(
                  '${s.home} – ${s.away}',
                  key: const ValueKey('scoreboard-score'),
                  style: RefType.control.copyWith(color: c.onSurface, fontFeatures: RefType.tabular, fontSize: 20),
                ),
              ),
              const SizedBox(width: RefSpace.s),
              Expanded(
                child: Text(controller.awayTeam, maxLines: 1, overflow: TextOverflow.ellipsis, style: team),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja de anotación: dos columnas (local y visitante) con los cuatro tantos. La hoja queda
/// abierta para poder sumar la transformación justo después del ensayo.
Future<void> showScoreSheet(BuildContext context, LiveController controller) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => _ScoreSheet(controller: controller),
      ),
    );

class _ScoreSheet extends StatelessWidget {
  const _ScoreSheet({required this.controller});
  final LiveController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final s = controller.scoreline;
    final last = controller.lastScore;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(RefSpace.l, 0, RefSpace.l, RefSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text('Marcador', style: RefType.control.copyWith(color: c.onSurface))),
          const SizedBox(height: RefSpace.s),
          Semantics(
            liveRegion: true,
            label: '${controller.homeTeam} ${s.home}, ${controller.awayTeam} ${s.away}',
            excludeSemantics: true,
            child: Center(
              child: Text(
                '${s.home} – ${s.away}',
                key: const ValueKey('score-sheet-score'),
                style: RefType.clockCompact.copyWith(color: c.onSurface),
              ),
            ),
          ),
          const SizedBox(height: RefSpace.m),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, team) in TeamSide.values.indexed) ...[
                if (i > 0) const SizedBox(width: RefTouch.gap),
                Expanded(child: _TeamColumn(controller: controller, team: team)),
              ],
            ],
          ),
          const SizedBox(height: RefSpace.l),
          SizedBox(
            height: RefTouch.minTarget + 8,
            child: OutlinedButton.icon(
              key: const ValueKey('score-undo'),
              onPressed: last == null ? null : controller.undoLastScore,
              icon: const Icon(Icons.undo_rounded),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  last == null
                      ? 'Deshacer último tanto'
                      : 'Deshacer: ${scoreKindLabel(last.kind)} · ${controller.teamName(last.team)} · ${formatClock(last.matchClockMs)}',
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
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({required this.controller, required this.team});
  final LiveController controller;
  final TeamSide team;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final canConvert = controller.canConvert(team);
    final side = team == TeamSide.home ? 'home' : 'away';
    Widget button(ScoreKind kind, {String? hint}) {
      final enabled = kind != ScoreKind.conversion || canConvert;
      // La transformación pendiente se resalta: es lo siguiente que va a pasar.
      final highlight = kind == ScoreKind.conversion && canConvert;
      return Padding(
        padding: const EdgeInsets.only(top: RefTouch.gap),
        child: SizedBox(
          height: RefTouch.control,
          child: FilledButton(
            key: ValueKey('score-$side-${kind.name}'),
            onPressed: enabled ? () => controller.addScore(team, kind, t: controller.now()) : null,
            style: FilledButton.styleFrom(
              backgroundColor: highlight ? c.primary : c.surface,
              foregroundColor: highlight ? c.onPrimary : c.onSurface,
              disabledBackgroundColor: c.background,
              disabledForegroundColor: c.onSurfaceMuted,
              textStyle: context.refText(RefType.control),
              padding: const EdgeInsets.symmetric(horizontal: RefSpace.s),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RefRadius.control),
                side: BorderSide(color: enabled ? c.outline : c.surfacePressed, width: 2),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sin color propio: heredan el del botón (blanco sobre azul cuando se resalta).
                  Text('${scoreKindLabel(kind)}  +${pointsFor(kind)}'),
                  if (hint != null) Text(hint, style: RefType.caption),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          controller.teamName(team),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: RefType.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w800),
        ),
        button(ScoreKind.tryScored),
        button(ScoreKind.conversion, hint: canConvert ? null : 'Tras un ensayo'),
        button(ScoreKind.penaltyGoal),
        button(ScoreKind.dropGoal),
      ],
    );
  }
}
