import 'package:flutter/material.dart';

import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/clock.dart';
import '../../domain/laws.dart';
import '../../domain/match_facts.dart';
import '../../domain/model.dart';
import '../../domain/review.dart';
import '../live/live_controller.dart' show periodLabel;
import '../common/infraction_picker.dart';
import '../live/live_labels.dart';
import 'review_controller.dart';
import 'review_labels.dart';
import 'widgets/choice_controls.dart';

/// Editor de una incidencia. Orden de arriba abajo = orden en que se razona:
/// ¿qué pasó? → veredicto → ley → impacto → decisiones → notas → contexto (opcional).
/// Los errores se muestran junto a su campo, no en un resumen lejano.
class IncidentEditorScreen extends StatefulWidget {
  const IncidentEditorScreen({super.key, required this.controller, required this.incidentId, this.chainPending = true});
  final ReviewController controller;
  final String incidentId;

  /// En la revisión, guardar salta a la siguiente pendiente. Abierto desde el directo (false),
  /// guardar vuelve al partido.
  final bool chainPending;

  @override
  State<IncidentEditorScreen> createState() => _IncidentEditorScreenState();
}

class _IncidentEditorScreenState extends State<IncidentEditorScreen> {
  late Incident _original;
  late Incident _draft;
  late final TextEditingController _notes;
  late final TextEditingController _lawRef;
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _original = widget.controller.byId(widget.incidentId);
    _draft = _original;
    _notes = TextEditingController(text: _original.notes ?? '');
    _lawRef = TextEditingController(text: _original.decisionExpected?.lawRef ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    _lawRef.dispose();
    super.dispose();
  }

  bool get _dirty => !_draft.sameContentAs(_original);
  bool get _needsExpected => _draft.verdict == Verdict.incorrect || _draft.verdict == Verdict.missed;
  List<ReviewIssue> get _issues => reviewIssues(_draft);

  void _update(Incident next) => setState(() {
    _draft = next;
    _saveError = null;
  });

  Decision _withOutcomes(Decision? d, Set<DecisionOutcome> outcomes) => Decision(
    outcomes: DecisionOutcome.values.where(outcomes.contains).toList(),
    againstTeam: d?.againstTeam,
    lawRef: d?.lawRef,
    description: d?.description,
  );

  Decision? _normalize(Decision? d) =>
      d == null || (d.outcomes.isEmpty && d.againstTeam == null && (d.lawRef ?? '').isEmpty) ? null : d;

  Future<void> _save({required bool goNext}) async {
    setState(() {
      _saving = true;
      _saveError = null;
    });
    final draft = _draft.copyWith(
      decisionTaken: _normalize(_draft.decisionTaken),
      decisionExpected: _normalize(_draft.decisionExpected),
    );
    try {
      final saved = await widget.controller.save(draft);
      if (!mounted) return;
      final next = goNext ? widget.controller.nextPendingAfter(saved.id) : null;
      if (next != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => IncidentEditorScreen(controller: widget.controller, incidentId: next.id),
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = 'No se ha podido guardar. Tus cambios siguen aquí: vuelve a intentarlo.';
        });
      }
    }
  }

  Future<void> _confirmVoid() async {
    final c = context.refColors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Anular esta marca?'),
        content: const Text('No se borra: queda registrada como anulada y deja de contar en el informe.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            key: const ValueKey('confirm-void'),
            style: FilledButton.styleFrom(backgroundColor: c.negative, foregroundColor: c.onNegative),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Anular'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await widget.controller.voidIncident(_original, 'REVIEW');
    if (mounted) Navigator.of(context).pop();
  }

  Future<bool> _confirmDiscard() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar los cambios?'),
        content: const Text('Lo que has editado en esta marca no se ha guardado.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir editando')),
          TextButton(
            key: const ValueKey('confirm-discard'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final i = _draft;
    final issues = _issues;
    final hasNext = widget.chainPending && widget.controller.nextPendingAfter(i.id) != null;
    final sanction = isSanction(i);
    final period = i.matchTime.period;

    return PopScope(
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Revisar marca'),
          backgroundColor: c.background,
          foregroundColor: c.onSurface,
          actions: [
            IconButton(
              key: const ValueKey('void-incident'),
              tooltip: 'Anular marca',
              icon: Icon(Icons.delete_outline_rounded, color: c.negative),
              onPressed: _saving ? null : _confirmVoid,
            ),
          ],
        ),
        body: SafeArea(
          // Formulario corto: SingleChildScrollView (no ListView perezoso) para que todos los
          // campos existan siempre y el foco/lector de pantalla los recorra en orden.
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(RefSpace.l, 0, RefSpace.l, RefSpace.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Qué pasó ───
                Text(formatClock(i.matchTime.matchClockMs), style: RefType.clockCompact.copyWith(color: c.onSurface)),
                Text(
                  '${incidentHeadline(i, (t) => t == TeamSide.home ? widget.controller.homeTeam : widget.controller.awayTeam)} · ${period == null ? 'fuera de juego' : periodLabel(period)}',
                  style: RefType.control.copyWith(color: c.onSurface),
                ),
                if (i.matchTime.integrity == TimeIntegrity.degraded)
                  Padding(
                    padding: const EdgeInsets.only(top: RefSpace.xs),
                    child: Text(
                      'Minuto estimado (reloj sin verificar tras un reinicio)',
                      style: RefType.caption.copyWith(color: c.onSurfaceMuted),
                    ),
                  ),
                const SizedBox(height: RefSpace.s),
                _CriterionRow(
                  code: i.criterionCode,
                  onChanged: (code) => _update(i.copyWith(criterionCode: code)),
                ),

                // ─── Veredicto ───
                SectionHeader(
                  title: 'Veredicto',
                  required: true,
                  subtitle: sanction ? 'Es una sanción: el árbitro la pitó. ¿Estuvo bien pitada?' : null,
                  error: issues.contains(ReviewIssue.verdictPending) ? 'Elige un veredicto.' : null,
                ),
                ChoiceGrid<Verdict>(
                  keyPrefix: 'verdict',
                  selected: i.verdict == Verdict.pending ? null : i.verdict,
                  onSelected: (v) => _update(i.copyWith(verdict: v)),
                  options: [
                    for (final v in const [
                      Verdict.correct,
                      Verdict.incorrect,
                      Verdict.missed,
                      Verdict.debatable,
                      Verdict.notAssessable,
                    ])
                      // "No pitada" solo tiene sentido en lo que el árbitro NO pitó: una sanción sí
                      // se pitó. (Si ya estaba elegida, se sigue mostrando para poder cambiarla.)
                      if (v != Verdict.missed || !sanction || i.verdict == Verdict.missed)
                      ChoiceOption(
                        value: v,
                        label: verdictLabel(v),
                        hint: verdictHint(v),
                        icon: verdictChoiceIcon(v),
                        selectedBackground: verdictColors(v, c).$1,
                        selectedForeground: verdictColors(v, c).$2,
                      ),
                  ],
                ),

                // ─── Ley / infracción (acierto o error) ───
                const SectionHeader(
                  title: 'Ley / infracción',
                  subtitle: 'La ley concreta de la acción, tanto si se aplicó bien como si no (opcional).',
                ),
                _InfractionField(
                  value: i.infraction,
                  onPick: () async {
                    final choice = await showInfractionPicker(
                      context,
                      title: 'Ley · ${kCategoryLabel[i.category] ?? ''}',
                      groups: lawGroupsFor(i.category),
                      current: i.infraction,
                    );
                    if (choice != null && mounted) _update(_draft.copyWith(infraction: choice.value));
                  },
                ),

                // ─── Impacto ───
                SectionHeader(
                  title: 'Impacto en el partido',
                  subtitle: i.impactConfirmed
                      ? null
                      : _needsExpected
                          ? 'Recomendado en un error: confirma el impacto (por defecto, el del directo).'
                          : 'Valor por defecto del directo: tócalo para confirmarlo.',
                ),
                ChoiceGrid<ImpactLevel>(
                  keyPrefix: 'impact',
                  selected: i.impactConfirmed ? i.impact : null,
                  onSelected: (v) => _update(i.copyWith(impact: v, impactConfirmed: true)),
                  options: [
                    for (final v in ImpactLevel.values) ChoiceOption(value: v, label: impactLabel(v), hint: impactHint(v)),
                  ],
                ),

                // ─── Decisión esperada (solo si es un error) ───
                if (_needsExpected) ...[
                  const SectionHeader(
                    title: 'Decisión esperada',
                    subtitle: 'Lo que debía pitar según el reglamento (recomendado).',
                  ),
                  _DecisionEditor(
                    keyPrefix: 'expected',
                    decision: i.decisionExpected,
                    onOutcomes: (set) => _update(i.copyWith(decisionExpected: _withOutcomes(i.decisionExpected, set))),
                    onTeam: (team) => _update(
                      i.copyWith(
                        decisionExpected: Decision(
                          outcomes: i.decisionExpected?.outcomes ?? const [],
                          againstTeam: team,
                          lawRef: i.decisionExpected?.lawRef,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: RefSpace.m),
                  TextField(
                    key: const ValueKey('law-ref'),
                    controller: _lawRef,
                    style: RefType.body.copyWith(color: c.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Ley aplicable (opcional)',
                      hintText: 'p. ej. 15.4',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _update(
                      i.copyWith(
                        decisionExpected: Decision(
                          outcomes: i.decisionExpected?.outcomes ?? const [],
                          againstTeam: i.decisionExpected?.againstTeam,
                          lawRef: v.trim().isEmpty ? null : v.trim(),
                        ),
                      ),
                    ),
                  ),
                ],

                // ─── Decisión tomada ───
                const SectionHeader(title: 'Decisión tomada', subtitle: 'Lo que pitó el árbitro (opcional).'),
                _DecisionEditor(
                  keyPrefix: 'taken',
                  decision: i.decisionTaken,
                  onOutcomes: (set) => _update(i.copyWith(decisionTaken: _withOutcomes(i.decisionTaken, set))),
                  onTeam: (team) => _update(
                    i.copyWith(
                      decisionTaken: Decision(outcomes: i.decisionTaken?.outcomes ?? const [], againstTeam: team),
                    ),
                  ),
                ),

                // ─── Notas ───
                SectionHeader(
                  title: 'Notas',
                  subtitle: i.impact == ImpactLevel.high || i.impact == ImpactLevel.matchDefining
                      ? 'Recomendado en las de impacto alto o decisivo.'
                      : null,
                ),
                TextField(
                  key: const ValueKey('notes'),
                  controller: _notes,
                  minLines: 3,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  style: RefType.body.copyWith(color: c.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'Qué pasó, qué debía ver el árbitro y por qué.',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => _update(i.copyWith(notes: v)),
                ),

                // ─── Contexto ───
                const SectionHeader(title: 'Contexto', subtitle: 'Opcional: ayuda a encontrar patrones entre partidos.'),
                Text('Fase de juego', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
                const SizedBox(height: RefSpace.xs),
                ChipMultiSelect<GamePhase>(
                  keyPrefix: 'phase',
                  single: true,
                  values: GamePhase.values,
                  selected: {?i.gamePhase},
                  labelOf: gamePhaseLabel,
                  onChanged: (s) => _update(i.copyWith(gamePhase: s.isEmpty ? null : s.first)),
                ),
                const SizedBox(height: RefSpace.m),
                Text('Zona del campo', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
                const SizedBox(height: RefSpace.xs),
                ChipMultiSelect<FieldZone>(
                  keyPrefix: 'zone',
                  single: true,
                  values: FieldZone.values,
                  selected: {?i.fieldZone},
                  labelOf: fieldZoneLabel,
                  onChanged: (s) => _update(i.copyWith(fieldZone: s.isEmpty ? null : s.first)),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: c.background,
              border: Border(top: BorderSide(color: c.outline, width: 1)),
            ),
            padding: const EdgeInsets.fromLTRB(RefSpace.l, RefSpace.s, RefSpace.l, RefSpace.s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_saveError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: RefSpace.s),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(_saveError!, style: RefType.caption.copyWith(color: c.negative)),
                    ),
                  ),
                Text(
                  issues.isNotEmpty
                      ? 'Pendiente: ${issues.map(issueLabel).join(' · ')}'
                      : reviewRecommendations(i).isEmpty
                          ? 'Lista para el informe.'
                          : 'Lista para el informe. ${reviewRecommendations(i).map(recommendationLabel).join(' · ')}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RefType.caption.copyWith(color: c.onSurfaceMuted),
                ),
                const SizedBox(height: RefSpace.s),
                SizedBox(
                  height: RefTouch.control,
                  child: FilledButton.icon(
                    key: const ValueKey('save-incident'),
                    onPressed: _saving ? null : () => _save(goNext: hasNext),
                    icon: _saving
                        ? SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 3, color: c.onPrimary))
                        : Icon(hasNext ? Icons.arrow_forward_rounded : Icons.check_rounded),
                    label: Text(hasNext ? 'Guardar y siguiente' : (widget.chainPending ? 'Guardar' : 'Guardar y volver al directo')),
                    style: FilledButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: c.onPrimary,
                      disabledBackgroundColor: c.surfacePressed,
                      disabledForegroundColor: c.onSurface,
                      textStyle: context.refText(RefType.control),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Decisiones frecuentes, visibles siempre. El resto aparece con "Más decisiones": 15 opciones a la
/// vez son demasiadas para elegir de un vistazo (y la pantalla las repite para tomada/esperada).
const List<DecisionOutcome> kFrequentOutcomes = [
  DecisionOutcome.playOn,
  DecisionOutcome.advantage,
  DecisionOutcome.penalty,
  DecisionOutcome.freeKick,
  DecisionOutcome.scrum,
  DecisionOutcome.yellowCard,
];

/// Campo de solo lectura que abre el selector de leyes.
class _InfractionField extends StatelessWidget {
  const _InfractionField({required this.value, required this.onPick});
  final InfractionRef? value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final v = value;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RefRadius.control),
        side: BorderSide(color: c.outline, width: v == null ? 1.5 : 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const ValueKey('infraction-field'),
        onTap: onPick,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: RefTouch.control),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: RefSpace.m, vertical: RefSpace.s),
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, color: c.onSurface),
                const SizedBox(width: RefSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        v?.label ?? 'Elegir ley o infracción',
                        style: RefType.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w700),
                      ),
                      if (v != null)
                        Text(
                          [if (v.catalog != null) v.catalog!.english, if (v.lawRef != null) v.lawRef!, if (v.isCustom) 'Personalizada'].join(' · '),
                          style: RefType.caption.copyWith(color: c.onSurfaceMuted),
                        ),
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

class _DecisionEditor extends StatefulWidget {
  const _DecisionEditor({required this.keyPrefix, required this.decision, required this.onOutcomes, required this.onTeam});
  final String keyPrefix;
  final Decision? decision;
  final ValueChanged<Set<DecisionOutcome>> onOutcomes;
  final ValueChanged<TeamSide?> onTeam;

  @override
  State<_DecisionEditor> createState() => _DecisionEditorState();
}

class _DecisionEditorState extends State<_DecisionEditor> {
  late bool _expanded = (widget.decision?.outcomes ?? const []).any((o) => !kFrequentOutcomes.contains(o));

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final selected = {...?widget.decision?.outcomes};
    // Lo ya elegido se ve siempre, aunque sea una opción poco frecuente.
    final values = _expanded
        ? DecisionOutcome.values
        : [for (final o in DecisionOutcome.values) if (kFrequentOutcomes.contains(o) || selected.contains(o)) o];
    final hidden = DecisionOutcome.values.length - values.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChipMultiSelect<DecisionOutcome>(
          keyPrefix: widget.keyPrefix,
          values: values,
          selected: selected,
          labelOf: outcomeLabel,
          onChanged: widget.onOutcomes,
        ),
        if (hidden > 0)
          Padding(
            padding: const EdgeInsets.only(top: RefSpace.xs),
            child: TextButton.icon(
              key: ValueKey('${widget.keyPrefix}-more'),
              onPressed: () => setState(() => _expanded = true),
              icon: const Icon(Icons.expand_more_rounded),
              label: Text('Más decisiones ($hidden)'),
              style: TextButton.styleFrom(
                foregroundColor: c.onSurface,
                minimumSize: const Size(RefTouch.minTarget, RefTouch.minTarget),
                textStyle: context.refText(RefType.caption.copyWith(fontSize: 16)),
              ),
            ),
          ),
        const SizedBox(height: RefSpace.m),
        Text('Contra', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
        const SizedBox(height: RefSpace.xs),
        ChipMultiSelect<TeamSide>(
          keyPrefix: '${widget.keyPrefix}-team',
          single: true,
          values: TeamSide.values,
          selected: {?widget.decision?.againstTeam},
          labelOf: (t) => t == TeamSide.home ? 'Local' : 'Visitante',
          onChanged: (s) => widget.onTeam(s.isEmpty ? null : s.first),
        ),
      ],
    );
  }
}

/// Criterio al que se atribuye la marca. Se puede reasignar (spec §1.2: una marca alimenta un
/// solo criterio, pero el evaluador decide cuál).
class _CriterionRow extends StatelessWidget {
  const _CriterionRow({required this.code, required this.onChanged});
  final String code;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(RefRadius.control),
      child: InkWell(
        key: const ValueKey('criterion-row'),
        borderRadius: BorderRadius.circular(RefRadius.control),
        onTap: () async {
          final picked = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => _CriterionPicker(current: code),
          );
          if (picked != null) onChanged(picked);
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: RefTouch.control),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: RefSpace.m, vertical: RefSpace.s),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Cuenta en la competencia', style: RefType.caption.copyWith(color: c.onSurfaceMuted)),
                      Text(
                        '${code.substring(0, 2)} · ${criterionLabel(code)}',
                        style: RefType.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.onSurface),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CriterionPicker extends StatelessWidget {
  const _CriterionPicker({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: RefSpace.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (area, criteria) in kRubricCriteria) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(RefSpace.l, RefSpace.m, RefSpace.l, RefSpace.xs),
              child: Text(area, style: RefType.status.copyWith(color: c.onSurfaceMuted)),
            ),
            for (final (code, label) in criteria)
              ListTile(
                key: ValueKey('criterion-$code'),
                minTileHeight: RefTouch.control,
                title: Text('${code.substring(0, 2)} · $label', style: RefType.body.copyWith(color: c.onSurface)),
                trailing: code == current ? Icon(Icons.check_rounded, color: c.onSurface) : null,
                selected: code == current,
                onTap: () => Navigator.of(context).pop(code),
              ),
          ],
        ],
      ),
    );
  }
}
