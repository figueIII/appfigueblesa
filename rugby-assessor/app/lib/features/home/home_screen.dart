import 'package:flutter/material.dart';

import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/i18n.dart';
import '../../data/match_repository.dart';
import '../../domain/rubric.dart';
import '../evaluation/widgets/band_widgets.dart';
import '../review/widgets/choice_controls.dart';

/// Pantalla de inicio: los partidos del evaluador agrupados por lo que queda por hacer.
/// - **En curso** (preparados o en juego) → vuelve al directo.
/// - **Pendientes de revisión** (terminados, sin informe cerrado) → revisión y evaluación.
/// - **Finalizados** → informe en solo lectura, desde donde se re-exporta PDF/JSON.
/// "Nuevo partido" va fijo abajo, al alcance del pulgar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.rubric,
    required this.onNewMatch,
    required this.onOpenMatch,
    this.onLanguage,
  });

  final MatchRepository repository;
  final AssessmentRubric rubric;

  /// Abre la preparación; al volver (con o sin partido creado) la lista se recarga.
  final Future<void> Function() onNewMatch;

  /// Abre el partido en el punto del flujo que le corresponde; al volver, se recarga.
  final Future<void> Function(MatchSummary match) onOpenMatch;

  /// Cambio de idioma desde el menú (castellano / catalán). Null = sin selector (tests).
  final Future<void> Function(AppLanguage language)? onLanguage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MatchSummary>? _matches;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await widget.repository.listMatches();
      if (!mounted) return;
      setState(() {
        _matches = list;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo leer la lista de partidos ($e).');
    }
  }

  Future<void> _then(Future<void> Function() action) async {
    await action();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final matches = _matches;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.onSurface,
        title: const Text('RefAssess'),
        actions: [
          if (widget.onLanguage != null)
            PopupMenuButton<AppLanguage>(
              key: const ValueKey('home-menu'),
              tooltip: tr('Menú', 'Menú'),
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (l) => widget.onLanguage!(l),
              itemBuilder: (context) => [
                PopupMenuItem<AppLanguage>(
                  enabled: false,
                  child: Text(tr('Idioma', 'Idioma'), style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
                ),
                for (final l in AppLanguage.values)
                  CheckedPopupMenuItem<AppLanguage>(
                    key: ValueKey('language-${l.name}'),
                    value: l,
                    checked: appLanguage.value == l,
                    child: Text(languageName(l)),
                  ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: switch ((matches, _error)) {
          (_, final String error) => _Message(icon: Icons.error_rounded, title: 'Error', text: error, color: c.negative),
          (null, _) => const Center(child: CircularProgressIndicator()),
          (final List<MatchSummary> list, _) when list.isEmpty => const _Message(
              key: ValueKey('home-empty'),
              icon: Icons.sports_rounded,
              title: 'Aún no hay partidos',
              text: 'Pulsa "Nuevo partido" para preparar el primero. Todo se guarda solo en este dispositivo.',
            ),
          (final List<MatchSummary> list, _) => _MatchList(
              matches: list,
              rubric: widget.rubric,
              onOpen: (m) => _then(() => widget.onOpenMatch(m)),
            ),
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: c.background, border: Border(top: BorderSide(color: c.outline, width: 1))),
          padding: const EdgeInsets.fromLTRB(RefSpace.l, RefSpace.s, RefSpace.l, RefSpace.s),
          child: SizedBox(
            height: RefTouch.control,
            child: FilledButton.icon(
              key: const ValueKey('new-match'),
              onPressed: () => _then(widget.onNewMatch),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo partido'),
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: c.onPrimary,
                textStyle: context.refText(RefType.control),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList({required this.matches, required this.rubric, required this.onOpen});
  final List<MatchSummary> matches;
  final AssessmentRubric rubric;
  final ValueChanged<MatchSummary> onOpen;

  @override
  Widget build(BuildContext context) {
    List<MatchSummary> of(MatchStage s) => [for (final m in matches) if (m.stage == s) m];
    final sections = [
      (MatchStage.inProgress, 'En curso', 'Vuelve al directo con el reloj donde lo dejaste.'),
      (MatchStage.pendingReview, 'Pendientes de revisión', 'Revisa las marcas y completa la evaluación.'),
      (MatchStage.finalized, 'Finalizados', 'Informe cerrado: consúltalo o vuelve a exportar PDF/JSON.'),
    ];
    return ListView(
      key: const ValueKey('home-list'),
      padding: const EdgeInsets.fromLTRB(RefSpace.l, 0, RefSpace.l, RefSpace.xxl),
      children: [
        for (final (stage, title, subtitle) in sections)
          if (of(stage).isNotEmpty) ...[
            KeyedSubtree(
              key: ValueKey('section-${stage.name}'),
              child: SectionHeader(title: '$title · ${of(stage).length}', subtitle: subtitle),
            ),
            for (final m in of(stage)) ...[
              _MatchCard(match: m, rubric: rubric, onTap: () => onOpen(m)),
              const SizedBox(height: RefTouch.tileGap),
            ],
          ],
      ],
    );
  }
}

/// "2026-10-17T17:00" → "17/10/2026 · 17:00".
String formatKickoff(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})').firstMatch(iso);
  if (m == null) return iso;
  return '${m[3]}/${m[2]}/${m[1]} · ${m[4]}:${m[5]}';
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.rubric, required this.onTap});
  final MatchSummary match;
  final AssessmentRubric rubric;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final m = match;
    final (action, icon) = switch (m.stage) {
      MatchStage.inProgress => (m.status == 'READY' ? 'Empezar' : 'Continuar', Icons.play_arrow_rounded),
      MatchStage.pendingReview => ('Revisar', Icons.fact_check_rounded),
      MatchStage.finalized => ('Ver y exportar', Icons.ios_share_rounded),
    };
    final state = switch (m.status) {
      'READY' => 'Sin empezar',
      'LIVE' => 'En directo · ${_marks(m.markCount)}',
      'POST_MATCH' => 'Terminado · ${_marks(m.markCount)}',
      'ARCHIVED' => 'Archivado',
      _ => 'Informe cerrado',
    };
    return Semantics(
      button: true,
      label: '${m.homeTeam} contra ${m.awayTeam}. ${formatKickoff(m.kickoffLocal)}. $state. $action',
      excludeSemantics: true,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RefRadius.tile),
          side: BorderSide(color: c.outline, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('match-${m.id}'),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: RefTouch.tileMinHeight),
            child: Padding(
              padding: const EdgeInsets.all(RefSpace.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${m.homeTeam} – ${m.awayTeam}', style: context.refText(RefType.tile).copyWith(color: c.onSurface)),
                  const SizedBox(height: RefSpace.xs),
                  Text(
                    '${formatKickoff(m.kickoffLocal)} · ${m.categoryName}',
                    style: RefType.caption.copyWith(color: c.onSurfaceMuted),
                  ),
                  Text('Árbitro: ${m.refereeName} · ${m.venue}', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
                  const SizedBox(height: RefSpace.s),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: m.stage == MatchStage.finalized && m.band != null
                              ? BandBadge(band: m.band, rubric: rubric)
                              : Text(state, style: RefType.caption.copyWith(color: c.onSurface)),
                        ),
                      ),
                      const SizedBox(width: RefSpace.s),
                      Text(action, style: RefType.caption.copyWith(color: c.primary)),
                      const SizedBox(width: RefSpace.xs),
                      Icon(icon, size: 24, color: c.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _marks(int n) => n == 1 ? '1 marca' : '$n marcas';
}

class _Message extends StatelessWidget {
  const _Message({super.key, required this.icon, required this.title, required this.text, this.color});
  final IconData icon;
  final String title;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RefSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: color ?? c.onSurfaceMuted),
            const SizedBox(height: RefSpace.m),
            Text(title, textAlign: TextAlign.center, style: context.refText(RefType.tile).copyWith(color: c.onSurface)),
            const SizedBox(height: RefSpace.s),
            Text(text, textAlign: TextAlign.center, style: RefType.body.copyWith(color: color ?? c.onSurfaceMuted)),
          ],
        ),
      ),
    );
  }
}
