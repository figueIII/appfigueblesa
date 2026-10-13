import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/domain/category_presets.dart';
import 'package:ref_assess/domain/match_setup.dart';

void main() {
  final complete = MatchSetupDraft(
    category: categoryPreset('M16'),
    homeTeam: 'Club Local RC',
    awayTeam: 'Visitante RT',
    refereeName: 'Ana Árbitro',
    assessorName: 'Evaluadora',
    venue: 'Campo Municipal',
    kickoff: DateTime(2026, 10, 17, 17),
  );

  MatchSetupDraft copy({String? home, String? away, String? referee, String? venue}) => MatchSetupDraft(
        category: complete.category,
        homeTeam: home ?? complete.homeTeam,
        awayTeam: away ?? complete.awayTeam,
        refereeName: referee ?? complete.refereeName,
        assessorName: complete.assessorName,
        venue: venue ?? complete.venue,
        kickoff: complete.kickoff,
      );

  test('formulario completo: sin errores (asistentes, competición y dificultad son opcionales)', () {
    expect(validateSetup(complete), isEmpty);
  });

  test('formulario vacío: un error por campo obligatorio, en el orden del formulario', () {
    final errors = validateSetup(const MatchSetupDraft());
    expect(errors.keys, [
      SetupField.category,
      SetupField.homeTeam,
      SetupField.awayTeam,
      SetupField.referee,
      SetupField.assessor,
      SetupField.kickoff,
      SetupField.venue,
    ]);
    expect(errors[SetupField.referee], 'El árbitro principal es obligatorio.');
  });

  test('solo espacios cuenta como vacío', () {
    expect(validateSetup(copy(referee: '   ', venue: '  ')).keys, [SetupField.referee, SetupField.venue]);
  });

  test('local y visitante no pueden ser el mismo equipo (sin distinguir mayúsculas ni espacios)', () {
    final errors = validateSetup(copy(home: 'Club Local RC', away: '  club local rc '));
    expect(errors, {SetupField.awayTeam: 'Local y visitante no pueden ser el mismo equipo.'});
  });

  test('resumen del preset: duración de las partes y del sin-bin', () {
    expect(presetSummary(categoryPreset('SM_DHCAT_1_2_3')), '2 × 40 min · sin-bin 10 min');
    expect(presetSummary(categoryPreset('M14')), '2 × 30 min · sin-bin 5 min');
    expect(presetSummary(categoryPreset('SEVENS')), '2 × 7 min · sin-bin 2 min');
  });
}
