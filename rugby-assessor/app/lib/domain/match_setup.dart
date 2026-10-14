// Validación pura del formulario de preparación del partido.

import 'model.dart';

enum SetupField { category, homeTeam, awayTeam, referee, assessor, venue, kickoff }

class MatchSetupDraft {
  const MatchSetupDraft({
    this.category,
    this.homeTeam = '',
    this.awayTeam = '',
    this.refereeName = '',
    this.ar1Name = '',
    this.ar2Name = '',
    this.assessorName = '',
    this.competition = '',
    this.venue = '',
    this.kickoff,
    this.difficulty,
  });
  final CategoryConfig? category;
  final String homeTeam;
  final String awayTeam;
  final String refereeName;
  final String ar1Name;
  final String ar2Name;
  final String assessorName;
  final String competition;
  final String venue;
  final DateTime? kickoff;
  final String? difficulty;
}

/// Errores por campo (vacío = se puede comenzar). Orden = orden del formulario.
Map<SetupField, String> validateSetup(MatchSetupDraft d) {
  String norm(String v) => v.trim().toLowerCase();
  return {
    if (d.category == null) SetupField.category: 'Elige la categoría del partido.',
    if (d.homeTeam.trim().isEmpty) SetupField.homeTeam: 'Escribe el equipo local.',
    if (d.awayTeam.trim().isEmpty)
      SetupField.awayTeam: 'Escribe el equipo visitante.'
    else if (norm(d.homeTeam) == norm(d.awayTeam))
      SetupField.awayTeam: 'Local y visitante no pueden ser el mismo equipo.',
    if (d.refereeName.trim().isEmpty) SetupField.referee: 'El árbitro principal es obligatorio.',
    if (d.assessorName.trim().isEmpty) SetupField.assessor: 'Indica quién evalúa.',
    if (d.kickoff == null) SetupField.kickoff: 'Indica la fecha y la hora.',
    if (d.venue.trim().isEmpty) SetupField.venue: 'Indica el campo.',
  };
}

/// "2 × 40 min · sin-bin 10 min": dato del preset, para elegir sin dudar.
String presetSummary(CategoryConfig c) => '2 × ${c.periodLengthMin} min · sin-bin ${c.sinBinMin} min';
