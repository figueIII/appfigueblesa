import 'package:flutter/material.dart';

import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/rubric.dart';
import 'evaluation_controller.dart';
import 'widgets/band_widgets.dart';
import 'widgets/closing_tab.dart';
import 'widgets/criterion_card.dart';

/// Pantalla 3 · Evaluación por criterios y bandas cualitativas.
///
/// Una pestaña por área (A · B · C · D) y una de cierre. Cada área muestra su banda (calculada
/// a partir de las bandas elegidas) y sus criterios; el cierre, la banda global, el texto del
/// informe y la comprobación previa. En toda la pantalla no aparece ninguna puntuación: solo
/// "Por debajo del nivel", "En el nivel" y "Por encima del nivel".
class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key, required this.controller, required this.onOpenReview});
  final EvaluationController controller;
  final VoidCallback onOpenReview;

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> with SingleTickerProviderStateMixin {
  EvaluationController get _ctl => widget.controller;
  late final TabController _tabs = TabController(length: _ctl.rubric.areas.length + 1, vsync: this);
  final Map<String, GlobalKey> _criterionKeys = {};

  @override
  void initState() {
    super.initState();
    if (_ctl.loadState != EvaluationLoadState.ready) _ctl.load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String code) => _criterionKeys.putIfAbsent(code, GlobalKey.new);

  /// Lleva a la pestaña del área y desplaza hasta la tarjeta del criterio.
  Future<void> goToCriterion(String code) async {
    final areaIndex = _ctl.rubric.areas.indexWhere((a) => a.criteria.any((c) => c.code == code));
    _tabs.animateTo(areaIndex, duration: RefMotion.sheet);
    await Future<void>.delayed(RefMotion.sheet + const Duration(milliseconds: 50));
    final ctx = _keyFor(code).currentContext;
    if (ctx != null && ctx.mounted) await Scrollable.ensureVisible(ctx, duration: RefMotion.sheet, alignment: 0.05);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return ListenableBuilder(
      listenable: _ctl,
      builder: (context, _) => PopScope(
        onPopInvokedWithResult: (_, _) => _ctl.flush(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: c.background,
            foregroundColor: c.onSurface,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Evaluación por criterios'),
                if (_ctl.refereeName.isNotEmpty)
                  Text(
                    '${_ctl.refereeName} · ${_ctl.homeTeam} – ${_ctl.awayTeam}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RefType.caption.copyWith(color: c.onSurfaceMuted),
                  ),
              ],
            ),
            bottom: _ctl.loadState == EvaluationLoadState.ready ? _tabBar(context) : null,
          ),
          body: SafeArea(
            child: switch (_ctl.loadState) {
              EvaluationLoadState.loading => Center(child: CircularProgressIndicator(color: c.primary)),
              EvaluationLoadState.failed => _Failed(onRetry: _ctl.load),
              EvaluationLoadState.ready => TabBarView(
                controller: _tabs,
                children: [
                  for (final (i, area) in _ctl.rubric.areas.indexed) _areaTab(context, area, i),
                  ClosingTab(controller: _ctl, onGoToCriterion: goToCriterion, onOpenReview: widget.onOpenReview),
                ],
              ),
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _tabBar(BuildContext context) {
    final c = context.refColors;
    return TabBar(
      controller: _tabs,
      labelColor: c.onSurface,
      unselectedLabelColor: c.onSurfaceMuted,
      indicatorColor: c.primary,
      indicatorWeight: 4,
      labelPadding: const EdgeInsets.symmetric(horizontal: RefSpace.s),
      labelStyle: context.refText(RefType.control),
      unselectedLabelStyle: context.refText(RefType.control.copyWith(fontWeight: FontWeight.w600)),
      tabs: [
        for (final area in _ctl.rubric.areas)
          Tab(
            key: ValueKey('tab-${area.letter}'),
            height: 56,
            child: Semantics(
              label:
                  'Área ${area.letter}, ${area.name}, ${_ctl.completedIn(area) == area.criteria.length ? 'completa' : 'pendiente'}',
              excludeSemantics: true,
              // FittedBox: con texto del sistema grande, la pestaña se reduce en vez de desbordar.
              child: FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(area.letter),
                    const SizedBox(width: RefSpace.xs),
                    Icon(
                      _ctl.completedIn(area) == area.criteria.length
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        Tab(
          key: const ValueKey('tab-close'),
          height: 56,
          child: const FittedBox(child: Text('Cierre')),
        ),
      ],
    );
  }

  Widget _areaTab(BuildContext context, RubricArea area, int index) {
    final c = context.refColors;
    final agg = _ctl.aggregateResult;
    final next = index + 1 < _ctl.rubric.areas.length ? _ctl.rubric.areas[index + 1] : null;
    return SingleChildScrollView(
      key: PageStorageKey('area-${area.code}'),
      padding: const EdgeInsets.fromLTRB(RefSpace.l, RefSpace.l, RefSpace.l, RefSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('${area.letter} · ${area.name}', style: RefType.control.copyWith(color: c.onSurface, fontSize: 22)),
          ),
          const SizedBox(height: RefSpace.s),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: RefSpace.s,
            runSpacing: RefSpace.xs,
            children: [
              Text('Banda del área:', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
              BandBadge(key: ValueKey('area-band-${area.code}'), band: agg.areas[index].band, rubric: _ctl.rubric),
            ],
          ),
          const SizedBox(height: RefSpace.l),
          for (final crit in area.criteria) ...[
            KeyedSubtree(
              key: _keyFor(crit.code),
              child: CriterionCard(controller: _ctl, criterion: crit),
            ),
            const SizedBox(height: RefSpace.l),
          ],
          SizedBox(
            height: RefTouch.control,
            child: FilledButton.icon(
              key: ValueKey('next-from-${area.letter}'),
              onPressed: () => _tabs.animateTo(index + 1, duration: RefMotion.sheet),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(next == null ? 'Ir al cierre' : 'Siguiente: área ${next.letter}'),
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: c.onPrimary,
                textStyle: context.refText(RefType.control),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});
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
            Icon(Icons.storage_rounded, size: 56, color: c.onSurface),
            const SizedBox(height: RefSpace.l),
            Text(
              'No se ha podido abrir la evaluación',
              textAlign: TextAlign.center,
              style: RefType.control.copyWith(color: c.onSurface),
            ),
            const SizedBox(height: RefSpace.xl),
            SizedBox(
              height: RefTouch.control,
              child: FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(backgroundColor: c.primary, foregroundColor: c.onPrimary),
                child: const Text('Reintentar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
