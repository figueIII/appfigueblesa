import 'package:flutter/material.dart';

import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/platform_ports.dart';
import 'live_controller.dart';
import 'widgets/clock_menu_sheet.dart';
import 'widgets/match_clock_header.dart';
import 'widgets/refine_strip.dart';
import 'widgets/tag_grid.dart';

/// Pantalla 1 · Registro en directo con un tap.
///
/// Jerarquía (de arriba abajo, de "mirar" a "tocar"):
///   1. Cabecera: reloj y estado, para un vistazo. Acción de reloj contextual.
///   2. Rejilla de etiquetas: el 60–65 % de la pantalla, las más usadas abajo (pulgar).
///   3. Tira de valoración: altura fija, ✓/✗/Deshacer durante 10 s tras cada marca.
/// En horizontal, la cabecera pasa a una columna izquierda y la rejilla a la derecha.
class LiveScreen extends StatefulWidget {
  const LiveScreen({
    super.key,
    required this.controller,
    required this.onGoToReview,
    this.onOpenMarks,
    this.onEditIncident,
    this.screenAwake = const WakelockScreenAwake(),
  });

  final LiveController controller;
  final VoidCallback onGoToReview;

  /// Lista de marcas para revisarlas y editarlas durante el partido (el reloj sigue).
  final VoidCallback? onOpenMarks;

  /// Editor completo de una marca, también durante el partido.
  final ValueChanged<String>? onEditIncident;
  final ScreenAwake screenAwake;

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  LiveController get _ctl => widget.controller;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Al pasar a segundo plano (llamada, bloqueo, cambio de app) se vacía la cola de escritura.
    _lifecycle = AppLifecycleListener(onHide: _ctl.flush, onPause: _ctl.flush);
    widget.screenAwake.enable();
    if (_ctl.loadState != LiveLoadState.ready) _ctl.load();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    widget.screenAwake.disable();
    super.dispose();
  }

  Future<bool> _confirmLeave() async {
    if (!_ctl.clockState.isPlaying) return true;
    final c = context.refColors;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir del directo?'),
        content: const Text('El reloj sigue contando y las marcas están guardadas. Puedes volver cuando quieras.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir aquí')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: c.primary, foregroundColor: c.onPrimary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctl,
      builder: (context, _) => PopScope(
        canPop: !_ctl.clockState.isPlaying,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (await _confirmLeave() && context.mounted) Navigator.of(context).pop();
        },
        child: Scaffold(
          body: SafeArea(
            child: switch (_ctl.loadState) {
              LiveLoadState.loading => const _LoadingState(),
              LiveLoadState.failed => _FailedState(onRetry: _ctl.load),
              LiveLoadState.ready => _ReadyLayout(
                controller: _ctl,
                onGoToReview: widget.onGoToReview,
                onOpenMarks: widget.onOpenMarks,
                onEditIncident: widget.onEditIncident,
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _ReadyLayout extends StatelessWidget {
  const _ReadyLayout({required this.controller, required this.onGoToReview, this.onOpenMarks, this.onEditIncident});
  final LiveController controller;
  final VoidCallback onGoToReview;
  final VoidCallback? onOpenMarks;
  final ValueChanged<String>? onEditIncident;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final landscape = constraints.maxWidth > constraints.maxHeight;
        final compact = constraints.maxHeight < 640;
        final header = MatchClockHeader(
          controller: controller,
          compact: compact,
          onOpenClockMenu: () async {
            final exit = await showClockMenuSheet(context, controller);
            if (!exit || !context.mounted) return;
            await controller.flush();
            // Salir es una decisión explícita: no se pide confirmación aunque el reloj corra.
            if (context.mounted) Navigator.of(context).pop();
          },
          onGoToReview: onGoToReview,
          onOpenMarks: onOpenMarks,
        );
        final grid = TagGrid(controller: controller);
        final strip = RefineStrip(controller: controller, onEdit: onEditIncident);
        final banner = _SaveErrorBanner(controller: controller);
        const pad = EdgeInsets.fromLTRB(RefSpace.l, RefSpace.s, RefSpace.l, RefSpace.l);

        if (landscape) {
          return Padding(
            padding: pad,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // La tira de valoración va fija abajo (es lo que corre prisa: 10 s); si la cabecera
                // no cabe entera, es ella la que se desplaza.
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(child: SingleChildScrollView(child: Column(children: [header, banner]))),
                      const SizedBox(height: RefSpace.s),
                      strip,
                    ],
                  ),
                ),
                const SizedBox(width: RefSpace.l),
                Expanded(flex: 3, child: grid),
              ],
            ),
          );
        }
        return Padding(
          padding: pad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: RefSpace.s),
              Expanded(child: grid),
              banner,
              const SizedBox(height: RefSpace.m),
              strip,
            ],
          ),
        );
      },
    );
  }
}

/// Error de guardado: visible, accionable y sin bloquear la captura (las marcas siguen en cola).
class _SaveErrorBanner extends StatelessWidget {
  const _SaveErrorBanner({required this.controller});
  final LiveController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.saveFailed) return const SizedBox.shrink();
    final c = context.refColors;
    final n = controller.pendingWriteCount;
    return Padding(
      padding: const EdgeInsets.only(top: RefSpace.s),
      child: Semantics(
        liveRegion: true,
        child: Material(
          color: c.negative,
          borderRadius: BorderRadius.circular(RefRadius.control),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: RefSpace.m, vertical: RefSpace.xs),
            child: Row(
              children: [
                Icon(Icons.error_rounded, color: c.onNegative),
                const SizedBox(width: RefSpace.s),
                Expanded(
                  child: Text(
                    'No se ha podido guardar ($n pendiente${n == 1 ? '' : 's'}). Siguen en el móvil.',
                    style: RefType.caption.copyWith(color: c.onNegative),
                  ),
                ),
                TextButton(
                  key: const ValueKey('retry-save'),
                  onPressed: controller.retryPendingWrites,
                  style: TextButton.styleFrom(
                    foregroundColor: c.onNegative,
                    minimumSize: const Size(RefTouch.minTarget, RefTouch.minTarget),
                    textStyle: context.refText(RefType.control),
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Center(
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(dimension: 48, child: CircularProgressIndicator(color: c.primary, strokeWidth: 5)),
            const SizedBox(height: RefSpace.l),
            Text('Recuperando el partido…', style: RefType.control.copyWith(color: c.onSurface)),
          ],
        ),
      ),
    );
  }
}

class _FailedState extends StatelessWidget {
  const _FailedState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RefSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storage_rounded, size: 56, color: c.onSurfaceMuted),
            const SizedBox(height: RefSpace.l),
            Text('No se ha podido abrir el partido', textAlign: TextAlign.center, style: RefType.control.copyWith(color: c.onSurface)),
            const SizedBox(height: RefSpace.s),
            Text(
              'Tus marcas no se han perdido: están en el almacenamiento del móvil.',
              textAlign: TextAlign.center,
              style: RefType.body.copyWith(color: c.onSurfaceMuted),
            ),
            const SizedBox(height: RefSpace.xl),
            SizedBox(
              height: RefTouch.control,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.onPrimary,
                  textStyle: context.refText(RefType.control),
                  padding: const EdgeInsets.symmetric(horizontal: RefSpace.xl),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
