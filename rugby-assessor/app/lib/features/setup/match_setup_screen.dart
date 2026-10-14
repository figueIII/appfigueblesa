import 'package:flutter/material.dart';

import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../data/match_repository.dart';
import '../../domain/category_presets.dart';
import '../../domain/match_setup.dart';
import '../../domain/model.dart';
import '../review/widgets/choice_controls.dart';

String difficultyLabel(String code) => switch (code) {
      'LOW' => 'Baja',
      'MEDIUM' => 'Media',
      'HIGH' => 'Alta',
      'VERY_HIGH' => 'Muy alta',
      _ => code,
    };

/// Preparación del partido. Un formulario corto, de arriba abajo en el orden en que se conoce la
/// información en el campo: categoría → equipos → árbitros → evaluador → cuándo y dónde →
/// dificultad. "Comenzar partido" crea el registro y abre el directo con el reloj a 00:00.
class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key, required this.repository, required this.onStart, DateTime Function()? now})
      : now = now ?? DateTime.now;

  final MatchRepository repository;

  /// Recibe el id del partido recién creado (abre el directo).
  final ValueChanged<String> onStart;
  final DateTime Function() now;

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  CategoryConfig? _category;
  String? _difficulty;
  late DateTime _kickoff = _roundedNow();
  final _home = TextEditingController();
  final _away = TextEditingController();
  final _referee = TextEditingController();
  final _ar1 = TextEditingController();
  final _ar2 = TextEditingController();
  final _assessor = TextEditingController();
  final _competition = TextEditingController();
  final _venue = TextEditingController();
  final _refereeFocus = FocusNode();
  final _assessorFocus = FocusNode();
  final Map<SetupField, GlobalKey> _keys = {for (final f in SetupField.values) f: GlobalKey()};

  List<String> _knownReferees = const [];
  List<String> _knownAssessors = const [];
  bool _submitted = false;
  bool _creating = false;

  /// Hora actual redondeada a los 5 minutos siguientes (la hora típica de un saque).
  DateTime _roundedNow() {
    final n = widget.now();
    final add = (5 - n.minute % 5) % 5;
    return DateTime(n.year, n.month, n.day, n.hour, n.minute).add(Duration(minutes: add));
  }

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final referees = await widget.repository.knownRefereeNames();
    final assessors = await widget.repository.knownAssessorNames();
    final last = await widget.repository.lastAssessorName();
    if (!mounted) return;
    setState(() {
      _knownReferees = referees;
      _knownAssessors = assessors;
      if (_assessor.text.isEmpty && last != null) _assessor.text = last;
    });
  }

  @override
  void dispose() {
    for (final c in [_home, _away, _referee, _ar1, _ar2, _assessor, _competition, _venue]) {
      c.dispose();
    }
    _refereeFocus.dispose();
    _assessorFocus.dispose();
    super.dispose();
  }

  MatchSetupDraft get _draft => MatchSetupDraft(
        category: _category,
        homeTeam: _home.text,
        awayTeam: _away.text,
        refereeName: _referee.text,
        ar1Name: _ar1.text,
        ar2Name: _ar2.text,
        assessorName: _assessor.text,
        competition: _competition.text,
        venue: _venue.text,
        kickoff: _kickoff,
        difficulty: _difficulty,
      );

  Map<SetupField, String> get _errors => _submitted ? validateSetup(_draft) : const {};

  Future<void> _start() async {
    setState(() => _submitted = true);
    final errors = validateSetup(_draft);
    if (errors.isNotEmpty) {
      final ctx = _keys[errors.keys.first]!.currentContext;
      if (ctx != null) await Scrollable.ensureVisible(ctx, duration: RefMotion.sheet, alignment: 0.1);
      return;
    }
    setState(() => _creating = true);
    try {
      String? opt(String v) => v.trim().isEmpty ? null : v.trim();
      final id = await widget.repository.createMatch(MatchSetupInput(
        category: _category!,
        homeTeam: _home.text.trim(),
        awayTeam: _away.text.trim(),
        refereeName: _referee.text.trim(),
        assessorName: _assessor.text.trim(),
        kickoffLocal: _kickoff,
        venue: _venue.text.trim(),
        competition: _competition.text.trim(),
        ar1Name: opt(_ar1.text),
        ar2Name: opt(_ar2.text),
        difficulty: _difficulty,
      ));
      if (mounted) widget.onStart(id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _creating = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se ha podido crear el partido. Vuelve a intentarlo.')));
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _kickoff,
      firstDate: DateTime(2020),
      lastDate: DateTime(widget.now().year + 2),
      helpText: 'Fecha del partido',
    );
    if (d != null) setState(() => _kickoff = DateTime(d.year, d.month, d.day, _kickoff.hour, _kickoff.minute));
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_kickoff),
      helpText: 'Hora del saque inicial',
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (t != null) setState(() => _kickoff = DateTime(_kickoff.year, _kickoff.month, _kickoff.day, t.hour, t.minute));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    final errors = _errors;
    String two(int v) => v.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(backgroundColor: c.background, foregroundColor: c.onSurface, title: const Text('Nuevo partido')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(RefSpace.l, 0, RefSpace.l, RefSpace.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Categoría ───
              KeyedSubtree(
                key: _keys[SetupField.category],
                child: SectionHeader(
                  title: 'Categoría',
                  required: true,
                  subtitle: 'Carga la duración de las partes y del sin-bin.',
                  error: errors[SetupField.category],
                ),
              ),
              ChoiceGrid<String>(
                keyPrefix: 'preset',
                selected: _category?.code,
                onSelected: (code) => setState(() => _category = categoryPreset(code)),
                options: [
                  for (final p in kCategoryPresets) ChoiceOption(value: p.code, label: p.name, hint: presetSummary(p)),
                ],
              ),

              // ─── Equipos ───
              const SectionHeader(title: 'Equipos', required: true),
              _Field(
                key: _keys[SetupField.homeTeam],
                fieldKey: const ValueKey('home-team'),
                controller: _home,
                label: 'Local',
                error: errors[SetupField.homeTeam],
                onChanged: _onEdit,
              ),
              const SizedBox(height: RefSpace.m),
              _Field(
                key: _keys[SetupField.awayTeam],
                fieldKey: const ValueKey('away-team'),
                controller: _away,
                label: 'Visitante',
                error: errors[SetupField.awayTeam],
                onChanged: _onEdit,
              ),

              // ─── Árbitros ───
              const SectionHeader(title: 'Árbitros', subtitle: 'Solo se evalúa al árbitro principal.'),
              KeyedSubtree(
                key: _keys[SetupField.referee],
                child: _AutocompleteField(
                  fieldKey: const ValueKey('referee'),
                  controller: _referee,
                  focusNode: _refereeFocus,
                  options: _knownReferees,
                  label: 'Árbitro principal · obligatorio',
                  helper: 'Escríbelo igual que en partidos anteriores para seguir sus recomendaciones.',
                  error: errors[SetupField.referee],
                  onChanged: _onEdit,
                ),
              ),
              const SizedBox(height: RefSpace.m),
              Row(
                children: [
                  Expanded(child: _Field(fieldKey: const ValueKey('ar1'), controller: _ar1, label: 'Asistente 1 (opcional)', onChanged: _onEdit)),
                  const SizedBox(width: RefTouch.gap),
                  Expanded(child: _Field(fieldKey: const ValueKey('ar2'), controller: _ar2, label: 'Asistente 2 (opcional)', onChanged: _onEdit)),
                ],
              ),

              // ─── Evaluador ───
              const SectionHeader(title: 'Evaluador / informador', required: true),
              KeyedSubtree(
                key: _keys[SetupField.assessor],
                child: _AutocompleteField(
                  fieldKey: const ValueKey('assessor'),
                  controller: _assessor,
                  focusNode: _assessorFocus,
                  options: _knownAssessors,
                  label: 'Nombre del evaluador',
                  error: errors[SetupField.assessor],
                  onChanged: _onEdit,
                ),
              ),

              // ─── Cuándo y dónde ───
              KeyedSubtree(key: _keys[SetupField.kickoff], child: const SectionHeader(title: 'Cuándo y dónde', required: true)),
              Row(
                children: [
                  Expanded(
                    child: _PickerButton(
                      key: const ValueKey('pick-date'),
                      icon: Icons.event_rounded,
                      label: '${two(_kickoff.day)}/${two(_kickoff.month)}/${_kickoff.year}',
                      semantics: 'Fecha del partido',
                      onPressed: _pickDate,
                    ),
                  ),
                  const SizedBox(width: RefTouch.gap),
                  Expanded(
                    child: _PickerButton(
                      key: const ValueKey('pick-time'),
                      icon: Icons.schedule_rounded,
                      label: '${two(_kickoff.hour)}:${two(_kickoff.minute)}',
                      semantics: 'Hora del saque inicial',
                      onPressed: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RefSpace.m),
              _Field(
                key: _keys[SetupField.venue],
                fieldKey: const ValueKey('venue'),
                controller: _venue,
                label: 'Campo / estadio',
                error: errors[SetupField.venue],
                onChanged: _onEdit,
              ),
              const SizedBox(height: RefSpace.m),
              _Field(
                fieldKey: const ValueKey('competition'),
                controller: _competition,
                label: 'Competición y jornada (opcional)',
                helper: 'Si lo dejas vacío, se usa la categoría.',
                onChanged: _onEdit,
              ),

              // ─── Dificultad ───
              const SectionHeader(
                title: 'Dificultad estimada del partido',
                subtitle: 'Opcional y solo informativa: no modifica la evaluación. La dificultad real se indica al cerrar el informe.',
              ),
              ChoiceGrid<String>(
                keyPrefix: 'difficulty',
                selected: _difficulty,
                onSelected: (v) => setState(() => _difficulty = _difficulty == v ? null : v),
                options: [for (final d in const ['LOW', 'MEDIUM', 'HIGH', 'VERY_HIGH']) ChoiceOption(value: d, label: difficultyLabel(d))],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: c.background, border: Border(top: BorderSide(color: c.outline, width: 1))),
          padding: const EdgeInsets.fromLTRB(RefSpace.l, RefSpace.s, RefSpace.l, RefSpace.s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errors.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: RefSpace.s),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      errors.length == 1 ? 'Falta 1 dato obligatorio.' : 'Faltan ${errors.length} datos obligatorios.',
                      style: RefType.caption.copyWith(color: c.negative),
                    ),
                  ),
                ),
              SizedBox(
                height: RefTouch.control,
                child: FilledButton.icon(
                  key: const ValueKey('start-match'),
                  onPressed: _creating ? null : _start,
                  icon: _creating
                      ? SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 3, color: c.onPrimary))
                      : const Icon(Icons.sports_rounded),
                  label: const Text('Comenzar partido'),
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
    );
  }

  /// Tras el primer intento, los errores se actualizan al escribir.
  void _onEdit(String _) {
    if (_submitted) setState(() {});
  }
}

class _Field extends StatelessWidget {
  const _Field({super.key, required this.fieldKey, required this.controller, required this.label, this.error, this.helper, this.onChanged});
  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String? error;
  final String? helper;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return TextField(
      key: fieldKey,
      controller: controller,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      style: RefType.body.copyWith(color: c.onSurface),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 2,
        errorText: error,
        errorMaxLines: 2,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Campo con sugerencias de nombres ya usados (mismo árbitro = mismo historial).
class _AutocompleteField extends StatelessWidget {
  const _AutocompleteField({
    required this.fieldKey,
    required this.controller,
    required this.focusNode,
    required this.options,
    required this.label,
    this.helper,
    this.error,
    this.onChanged,
  });
  final Key fieldKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> options;
  final String label;
  final String? helper;
  final String? error;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (value) {
        final q = value.text.trim().toLowerCase();
        if (q.isEmpty) return const Iterable<String>.empty();
        return options.where((o) => o.toLowerCase().contains(q) && o.toLowerCase() != q).take(5);
      },
      onSelected: (v) => onChanged?.call(v),
      fieldViewBuilder: (context, ctl, focus, onSubmit) => TextField(
        key: fieldKey,
        controller: ctl,
        focusNode: focus,
        textCapitalization: TextCapitalization.words,
        style: RefType.body.copyWith(color: c.onSurface),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 2,
          errorText: error,
          errorMaxLines: 2,
          border: const OutlineInputBorder(),
        ),
      ),
      optionsViewBuilder: (context, onSelected, opts) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          color: c.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control), side: BorderSide(color: c.outline)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260, maxWidth: 360),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                for (final o in opts)
                  ListTile(
                    key: ValueKey('suggestion-$o'),
                    minTileHeight: RefTouch.minTarget + 8,
                    leading: Icon(Icons.history_rounded, color: c.onSurfaceMuted),
                    title: Text(o, style: RefType.body.copyWith(color: c.onSurface)),
                    onTap: () => onSelected(o),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({super.key, required this.icon, required this.label, required this.semantics, required this.onPressed});
  final IconData icon;
  final String label;
  final String semantics;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return Semantics(
      button: true,
      label: '$semantics: $label',
      excludeSemantics: true,
      child: SizedBox(
        height: RefTouch.control,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label, style: RefType.control.copyWith(fontFeatures: RefType.tabular)),
          style: OutlinedButton.styleFrom(
            foregroundColor: c.onSurface,
            side: BorderSide(color: c.outline, width: 2),
            textStyle: context.refText(RefType.control),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
          ),
        ),
      ),
    );
  }
}
