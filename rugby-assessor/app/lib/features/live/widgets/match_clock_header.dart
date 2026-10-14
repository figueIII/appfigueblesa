import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';
import '../../../domain/clock.dart';
import '../../../domain/model.dart';
import '../live_controller.dart';
import 'discipline.dart';
import 'scoreboard.dart';

/// Cabecera: marcador, reloj grande, estado del periodo, aviso contextual, acción principal del
/// reloj y contador de sanciones (GC · GF · tarjetas por equipo).
/// Lo que cambia cada segundo vive en [LiveClockText], aislado en su propio RepaintBoundary.
class MatchClockHeader extends StatelessWidget {
  const MatchClockHeader({
    super.key,
    required this.controller,
    required this.onOpenClockMenu,
    required this.onGoToReview,
    this.onOpenMarks,
    this.compact = false,
  });

  final LiveController controller;
  final VoidCallback onOpenClockMenu;
  final VoidCallback onGoToReview;

  /// Abre la lista de marcas para revisarlas y editarlas sin esperar al final.
  final VoidCallback? onOpenMarks;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final s = controller.clockState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ScoreboardBar(controller: controller, onOpen: () => showScoreSheet(context, controller)),
            ),
            // Las marcas se pueden revisar y editar en cualquier momento, no solo al final.
            if (onOpenMarks != null)
              _MarksButton(pending: controller.pendingReviewCount, total: controller.activeCount, onPressed: onOpenMarks!),
            _IconControl(
              key: const ValueKey('clock-menu'),
              icon: Icons.menu_rounded,
              label: 'Menú del partido: salir al menú principal y reloj',
              onPressed: onOpenClockMenu,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    liveRegion: true,
                    // Una sola línea: con texto grande se reduce en lugar de empujar la rejilla.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(_periodLine(s), maxLines: 1, style: RefType.status.copyWith(color: c.onSurfaceMuted)),
                    ),
                  ),
                  const SizedBox(height: RefSpace.xs),
                  LiveClockText(controller: controller, compact: compact),
                ],
              ),
            ),
            const SizedBox(width: RefSpace.m),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.46),
              child: _PrimaryClockButton(controller: controller, onGoToReview: onGoToReview),
            ),
          ],
        ),
        const SizedBox(height: RefSpace.s),
        _StatusBand(controller: controller, onFixClock: onOpenClockMenu),
        const SizedBox(height: RefSpace.s),
        DisciplineBar(controller: controller, onOpen: () => showSanctionsSheet(context, controller)),
        const SizedBox(height: RefSpace.s),
        Semantics(
          liveRegion: true,
          child: Text(
            _counterLine(controller),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RefType.caption.copyWith(color: c.onSurfaceMuted),
          ),
        ),
      ],
    );
  }

  static String _periodLine(ClockState s) => switch (s.status) {
        ClockStatus.preMatch => 'ANTES DEL INICIO',
        ClockStatus.running => '${periodLabel(s.period!).toUpperCase()} · EN JUEGO',
        ClockStatus.stopped => '${periodLabel(s.period!).toUpperCase()} · TIEMPO PARADO',
        ClockStatus.interval => 'DESCANSO',
        ClockStatus.fullTime => 'FINAL DEL PARTIDO',
        ClockStatus.abandoned => 'PARTIDO SUSPENDIDO',
      };

  static String _counterLine(LiveController c) {
    final n = c.activeCount;
    if (n == 0) return 'Sin marcas todavía';
    final pending = c.pendingReviewCount;
    return '$n ${n == 1 ? 'marca' : 'marcas'} · $pending por revisar';
  }
}

/// Reloj que se repinta 4 veces por segundo, pero solo reconstruye el texto si cambia el
/// segundo mostrado. Cifras tabulares: el ancho no baila.
class LiveClockText extends StatefulWidget {
  const LiveClockText({super.key, required this.controller, this.compact = false});
  final LiveController controller;
  final bool compact;

  @override
  State<LiveClockText> createState() => _LiveClockTextState();
}

class _LiveClockTextState extends State<LiveClockText> {
  Timer? _timer;
  String _text = '00:00';

  @override
  void initState() {
    super.initState();
    _text = _compute();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final next = _compute();
      if (next != _text) setState(() => _text = next);
    });
  }

  @override
  void didUpdateWidget(covariant LiveClockText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _text = _compute();
  }

  String _compute() {
    final c = widget.controller;
    return formatClock(c.matchTimeAt(c.now()).matchClockMs);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final stopped = widget.controller.clockState.status == ClockStatus.stopped;
    return RepaintBoundary(
      child: Semantics(
        label: 'Reloj de partido $_text',
        excludeSemantics: true,
        child: SizedBox(
          // Altura fija: con texto del sistema muy grande el reloj se ajusta, no crece.
          height: widget.compact ? 48 : 68,
          child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _text,
            key: const ValueKey('match-clock'),
            style: (widget.compact ? RefType.clockCompact : RefType.clock)
                .copyWith(color: stopped ? c.onSurfaceMuted : c.onSurface),
          ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryClockButton extends StatelessWidget {
  const _PrimaryClockButton({required this.controller, required this.onGoToReview});
  final LiveController controller;
  final VoidCallback onGoToReview;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final action = controller.primaryAction;
    final (label, icon, bg, fg) = switch (action) {
      StartPeriodAction(:final period) => ('Iniciar\n${periodLabel(period)}', Icons.play_arrow_rounded, c.primary, c.onPrimary),
      StopTimeAction() => ('Parar\ntiempo', Icons.pause_rounded, c.review, c.onReview),
      ResumeTimeAction() => ('Reanudar', Icons.play_arrow_rounded, c.primary, c.onPrimary),
      GoToReviewAction() => ('Ir a\nrevisión', Icons.fact_check_rounded, c.primary, c.onPrimary),
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, minHeight: RefTouch.control + 8, maxHeight: 96),
      child: FilledButton.icon(
        key: const ValueKey('primary-clock-action'),
        onPressed: () {
          if (action is GoToReviewAction) {
            onGoToReview();
            return;
          }
          final error = controller.runPrimaryAction();
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No permitido: ${error.code.name}')));
          }
        },
        icon: Icon(icon, size: 28),
        label: FittedBox(fit: BoxFit.scaleDown, child: Text(label, textAlign: TextAlign.center, maxLines: 2)),
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          textStyle: context.refText(RefType.control),
          padding: const EdgeInsets.symmetric(horizontal: RefSpace.l, vertical: RefSpace.m),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
        ),
      ),
    );
  }
}

/// Aviso contextual de una línea. Siempre reserva su altura (sin saltos de layout) y nunca
/// usa solo el color: icono + texto.
class _StatusBand extends StatefulWidget {
  const _StatusBand({required this.controller, required this.onFixClock});
  final LiveController controller;
  final VoidCallback onFixClock;

  @override
  State<_StatusBand> createState() => _StatusBandState();
}

class _StatusBandState extends State<_StatusBand> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // El tiempo cumplido aparece sin que cambie el estado del reloj: se comprueba cada segundo.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
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
    final c = context.refColors;
    final ctl = widget.controller;
    final s = ctl.clockState;
    final mt = ctl.matchTimeAt(ctl.now());

    (IconData, String, Color, Color, VoidCallback?)? band;
    if (s.integrity == TimeIntegrity.degraded) {
      band = (Icons.sync_problem_rounded, 'Reloj sin verificar · toca para ajustar', c.warningSurface, c.onWarningSurface, widget.onFixClock);
    } else if (s.status == ClockStatus.stopped) {
      band = (Icons.pause_circle_rounded, 'Tiempo parado (${s.timeOffCount}ª vez en el periodo)', c.review, c.onReview, null);
    } else if (s.status == ClockStatus.running && mt.overtimeMs > 0) {
      band = (Icons.timer_off_rounded, 'Tiempo cumplido +${formatClock(mt.overtimeMs)}', c.warningSurface, c.onWarningSurface, null);
    }

    return SizedBox(
      height: 44,
      child: band == null
          ? const SizedBox.shrink()
          : Semantics(
              liveRegion: true,
              button: band.$5 != null,
              child: Material(
                color: band.$3,
                borderRadius: BorderRadius.circular(RefRadius.control),
                child: InkWell(
                  onTap: band.$5,
                  borderRadius: BorderRadius.circular(RefRadius.control),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: RefSpace.m),
                    child: Row(
                      children: [
                        Icon(band.$1, color: band.$4, size: 24),
                        const SizedBox(width: RefSpace.s),
                        Expanded(
                          child: Text(
                            band.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: RefType.status.copyWith(color: band.$4),
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

/// Lista de marcas (con insignia de las que faltan por revisar).
class _MarksButton extends StatelessWidget {
  const _MarksButton({required this.pending, required this.total, required this.onPressed});
  final int pending;
  final int total;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Semantics(
      button: true,
      label: 'Ver y editar las marcas: $total, $pending por revisar',
      excludeSemantics: true,
      child: IconButton(
        key: const ValueKey('open-marks'),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: RefTouch.minTarget, minHeight: RefTouch.minTarget),
        icon: Badge(
          isLabelVisible: pending > 0,
          label: Text('$pending'),
          backgroundColor: c.review,
          textColor: c.onReview,
          child: Icon(Icons.format_list_bulleted_rounded, size: 28, color: c.onSurface),
        ),
      ),
    );
  }
}

class _IconControl extends StatelessWidget {
  const _IconControl({super.key, required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      icon: Icon(icon, size: 28, color: context.refColors.onSurface),
      constraints: const BoxConstraints(minWidth: RefTouch.minTarget, minHeight: RefTouch.minTarget),
    );
  }
}
