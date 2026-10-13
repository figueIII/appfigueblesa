// Catálogo de las infracciones más frecuentes, agrupadas por fase de juego, con su ley de World
// Rugby. Es un selector rápido, no el reglamento: la ley se cita por número (y apartado solo
// donde es inequívoco). Lo no listado se registra como "Otra ley / infracción personalizada".

import 'model.dart';

enum LawGroup { ruck, tackle, offside, scrum, lineoutMaul, discipline }

String lawGroupLabel(LawGroup g) => switch (g) {
      LawGroup.ruck => 'Ruck / suelo',
      LawGroup.tackle => 'Placaje',
      LawGroup.offside => 'Fuera de juego',
      LawGroup.scrum => 'Melé',
      LawGroup.lineoutMaul => 'Touch y maul',
      LawGroup.discipline => 'Juego sucio y disciplina',
    };

/// Sanción habitual (preselección; el evaluador registra lo que pitó el árbitro).
enum SanctionKind { penalty, freeKick, yellowCard, redCard }

class Infraction {
  const Infraction({
    required this.code,
    required this.group,
    required this.label,
    required this.english,
    required this.lawRef,
    this.usualSanction,
  });
  final String code;
  final LawGroup group;
  final String label;
  final String english; // término de World Rugby, para quien lo conoce así
  final String lawRef;
  final SanctionKind? usualSanction;
}

const List<Infraction> kInfractions = [
  // ─── Ruck / suelo ───
  Infraction(code: 'NOT_ROLLING_AWAY', group: LawGroup.ruck, label: 'No rodar / no apartarse', english: 'Not rolling away', lawRef: 'Ley 14', usualSanction: SanctionKind.penalty),
  Infraction(code: 'NOT_RELEASING', group: LawGroup.ruck, label: 'No soltar el balón', english: 'Not releasing', lawRef: 'Ley 14', usualSanction: SanctionKind.penalty),
  Infraction(code: 'SIDE_ENTRY', group: LawGroup.ruck, label: 'Entrada lateral', english: 'Side entry', lawRef: 'Ley 15', usualSanction: SanctionKind.penalty),
  Infraction(code: 'OFF_FEET_SEALING', group: LawGroup.ruck, label: 'Tirarse sobre el ruck / sellar', english: 'Off feet / sealing off', lawRef: 'Ley 15', usualSanction: SanctionKind.penalty),
  Infraction(code: 'HANDS_IN_RUCK', group: LawGroup.ruck, label: 'Manos en el ruck', english: 'Hands in the ruck', lawRef: 'Ley 15', usualSanction: SanctionKind.penalty),
  // ─── Placaje ───
  Infraction(code: 'HIGH_TACKLE', group: LawGroup.tackle, label: 'Placaje alto / contacto con la cabeza', english: 'Head contact process', lawRef: 'Ley 9.13', usualSanction: SanctionKind.penalty),
  Infraction(code: 'TIP_TACKLE', group: LawGroup.tackle, label: 'Placaje peligroso / volteo', english: 'Tip tackle', lawRef: 'Ley 9.18', usualSanction: SanctionKind.penalty),
  Infraction(code: 'TACKLE_WITHOUT_BALL', group: LawGroup.tackle, label: 'Placaje sin balón', english: 'Tackling without the ball', lawRef: 'Ley 9', usualSanction: SanctionKind.penalty),
  Infraction(code: 'EARLY_LATE_TACKLE', group: LawGroup.tackle, label: 'Placaje anticipado / tardío', english: 'Early / late tackle', lawRef: 'Ley 9.13', usualSanction: SanctionKind.penalty),
  // ─── Fuera de juego ───
  Infraction(code: 'OFFSIDE_RUCK_MAUL', group: LawGroup.offside, label: 'Fuera de juego en ruck / maul', english: 'Offside at ruck / maul', lawRef: 'Leyes 15 y 16', usualSanction: SanctionKind.penalty),
  Infraction(code: 'OFFSIDE_OPEN_PLAY', group: LawGroup.offside, label: 'Fuera de juego en juego abierto (10 m tras patada)', english: 'Offside in open play', lawRef: 'Ley 10', usualSanction: SanctionKind.penalty),
  // ─── Melé ───
  Infraction(code: 'SCRUM_EARLY_ENGAGEMENT', group: LawGroup.scrum, label: 'Entrada antes de tiempo', english: 'Early engagement', lawRef: 'Ley 19', usualSanction: SanctionKind.freeKick),
  Infraction(code: 'SCRUM_COLLAPSING', group: LawGroup.scrum, label: 'Derrumbar la melé', english: 'Collapsing', lawRef: 'Ley 19', usualSanction: SanctionKind.penalty),
  Infraction(code: 'SCRUM_NOT_STRAIGHT', group: LawGroup.scrum, label: 'No empujar recto', english: 'Not pushing straight', lawRef: 'Ley 19', usualSanction: SanctionKind.penalty),
  Infraction(code: 'SCRUM_EARLY_PUSH', group: LawGroup.scrum, label: 'Empuje prematuro', english: 'Early push', lawRef: 'Ley 19', usualSanction: SanctionKind.freeKick),
  // ─── Touch y maul ───
  Infraction(code: 'LINEOUT_NOT_STRAIGHT', group: LawGroup.lineoutMaul, label: 'Saque de touch no recto', english: 'Not straight', lawRef: 'Ley 18'),
  Infraction(code: 'MAUL_COLLAPSING', group: LawGroup.lineoutMaul, label: 'Derrumbar el maul', english: 'Collapsing a maul', lawRef: 'Ley 16', usualSanction: SanctionKind.penalty),
  Infraction(code: 'MAUL_ILLEGAL_ENTRY', group: LawGroup.lineoutMaul, label: 'Entrada antirreglamentaria en maul', english: 'Illegal maul entry', lawRef: 'Ley 16', usualSanction: SanctionKind.penalty),
  Infraction(code: 'OBSTRUCTION_SCREEN', group: LawGroup.lineoutMaul, label: 'Obstrucción / pantalla', english: 'Obstruction / truck and trailer', lawRef: 'Leyes 9 y 16', usualSanction: SanctionKind.penalty),
  // ─── Juego sucio y disciplina ───
  Infraction(code: 'DISSENT', group: LawGroup.discipline, label: 'Desobediencia / protestas', english: 'Dissent', lawRef: 'Ley 9', usualSanction: SanctionKind.penalty),
  Infraction(code: 'FOUL_LANGUAGE', group: LawGroup.discipline, label: 'Lenguaje soez', english: 'Foul language', lawRef: 'Ley 9', usualSanction: SanctionKind.penalty),
  Infraction(code: 'INTENTIONAL_OBSTRUCTION', group: LawGroup.discipline, label: 'Obstrucción intencionada', english: 'Intentional obstruction', lawRef: 'Ley 9', usualSanction: SanctionKind.penalty),
  Infraction(code: 'DELAYING_RESTART', group: LawGroup.discipline, label: 'Retrasar el saque / perder tiempo', english: 'Time wasting', lawRef: 'Ley 9', usualSanction: SanctionKind.freeKick),
];

const String kCustomInfractionCode = 'CUSTOM';

final Map<String, Infraction> _byCode = {for (final i in kInfractions) i.code: i};

Infraction? infractionByCode(String? code) => code == null ? null : _byCode[code];

List<Infraction> infractionsIn(LawGroup g) => [for (final i in kInfractions) if (i.group == g) i];

/// Infracción asociada a una incidencia o a una sanción: del catálogo o personalizada.
class InfractionRef {
  const InfractionRef._(this.code, this.customText, this.customLawRef);

  /// Del catálogo.
  factory InfractionRef.catalog(String code) {
    if (!_byCode.containsKey(code)) throw ArgumentError.value(code, 'code', 'no está en el catálogo');
    return InfractionRef._(code, null, null);
  }

  /// "Otra ley / infracción personalizada": texto libre y, opcionalmente, la ley.
  factory InfractionRef.custom(String text, {String? lawRef}) {
    final t = text.trim();
    if (t.isEmpty) throw ArgumentError.value(text, 'text', 'vacío');
    final l = lawRef?.trim();
    return InfractionRef._(kCustomInfractionCode, t, (l == null || l.isEmpty) ? null : l);
  }

  /// Desde el almacenamiento; null si no hay infracción o el código ya no existe.
  static InfractionRef? decode(String? code, String? customText, String? customLawRef) {
    if (code == null) return null;
    if (code == kCustomInfractionCode) {
      return (customText == null || customText.trim().isEmpty) ? null : InfractionRef.custom(customText, lawRef: customLawRef);
    }
    return _byCode.containsKey(code) ? InfractionRef._(code, null, null) : null;
  }

  final String code;
  final String? customText;
  final String? customLawRef;

  bool get isCustom => code == kCustomInfractionCode;
  Infraction? get catalog => _byCode[code];
  String get label => isCustom ? customText! : catalog!.label;
  String? get lawRef => isCustom ? customLawRef : catalog!.lawRef;

  /// Clave para agrupar: el código, o el texto normalizado si es personalizada.
  String get groupKey => isCustom ? 'CUSTOM:${customText!.toLowerCase().replaceAll(RegExp(r'\s+'), ' ')}' : code;

  @override
  bool operator ==(Object other) =>
      other is InfractionRef && other.code == code && other.customText == customText && other.customLawRef == customLawRef;

  @override
  int get hashCode => Object.hash(code, customText, customLawRef);
}

/// Grupos en el orden en que conviene ofrecerlos para una categoría de marca (el más probable
/// primero; los demás siguen en el orden del catálogo).
List<LawGroup> lawGroupsFor(IncidentCategory? c) {
  final first = switch (c) {
    IncidentCategory.ruck => [LawGroup.ruck, LawGroup.offside],
    IncidentCategory.tackle => [LawGroup.tackle, LawGroup.ruck],
    IncidentCategory.offside => [LawGroup.offside],
    IncidentCategory.scrum => [LawGroup.scrum],
    IncidentCategory.lineout || IncidentCategory.maul => [LawGroup.lineoutMaul, LawGroup.offside],
    IncidentCategory.foulPlay || IncidentCategory.card => [LawGroup.tackle, LawGroup.discipline],
    IncidentCategory.communication || IncidentCategory.captainMgmt => [LawGroup.discipline],
    _ => const <LawGroup>[],
  };
  return [...first, for (final g in LawGroup.values) if (!first.contains(g)) g];
}
