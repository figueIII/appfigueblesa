// GENERADO desde domain/rubric-default.ts (rúbrica v3.0.0) con scripts/gen-rubric-dart.sh.
// No editar a mano: test/domain/scoring_test.dart comprueba pesos, bandas y topes.

import 'model.dart';
import 'rubric.dart';

final AssessmentRubric kDefaultRubric = AssessmentRubric(
  id: '01929d6e-0000-7000-8000-000000000003',
  code: 'CARC-COMPETENCIES',
  version: '3.0.0',
  name: 'Competencias del árbitro (CARC)',
  scaleMin: 1.0,
  scaleMax: 10.0,
  bands: [
    PerformanceBand(code: BandCode.excellent, label: 'Excelente', labelCa: 'Excel·lent', description: 'Rendimiento excelente en esta competencia.', descriptionCa: 'Rendiment excel·lent en aquesta competència.', representative: 9.0, lower: 8.0, lowerInclusive: false),
    PerformanceBand(code: BandCode.competent, label: 'Competente', labelCa: 'Competent', description: 'Domina la competencia al nivel exigido.', descriptionCa: 'Domina la competència al nivell exigit.', representative: 7.0, lower: 6.0, lowerInclusive: true),
    PerformanceBand(code: BandCode.notYet, label: 'No competente todavía', labelCa: 'No competent encara', description: 'Todavía no domina la competencia: hay que trabajarla.', descriptionCa: 'Encara no domina la competència: cal treballar-la.', representative: 5.0, lower: 4.0, lowerInclusive: true),
    PerformanceBand(code: BandCode.urgent, label: 'Revisión urgente', labelCa: 'Urgent revisar', description: 'Hay que revisar esta competencia con urgencia.', descriptionCa: 'Cal revisar aquesta competència amb urgència.', representative: 3.0, lower: double.negativeInfinity, lowerInclusive: true),
  ],
  areas: [
    RubricArea(code: 'POSITIONING', name: 'Colocación', nameCa: 'Col·locació', weight: 1.0, criteria: [
      Criterion(code: 'A1_STATIC_START', level: 1, name: 'El punto de partida en las fases estáticas es adecuado para seguir el juego', nameCa: 'El punt de partida en les fases estàtiques és adequat per seguir el joc', weight: 1.0, description: ''),
      Criterion(code: 'A2_NO_INTERFERENCE', level: 1, name: 'Su posición no interfiere en el juego ni en los jugadores', nameCa: 'La seva posició no interfereix en el joc o jugadors', weight: 1.0, description: ''),
      Criterion(code: 'A3_SEES_PLAY', level: 2, name: 'Puede ver el balón, los jugadores cercanos y los jugadores alejados', nameCa: 'Pot veure la pilota, els jugadors a prop i els jugadors allunyats', weight: 1.0, description: ''),
      Criterion(code: 'A4_OPEN_PLAY_LINES', level: 2, name: 'Utiliza trayectorias adecuadas para seguir el juego abierto', nameCa: 'Utilitza trajectòries adequades per seguir el joc obert', weight: 1.0, description: ''),
      Criterion(code: 'A5_REACHES_CONTACT', level: 3, name: 'Llega a los puntos de encuentro adecuadamente durante todo el partido', nameCa: 'Arriba als punts d\'encontre adequadament durant tot el partit', weight: 1.0, description: ''),
      Criterion(code: 'A6_COMMUNICATES_FROM_POSITION', level: 3, name: 'Puede comunicarse eficazmente con los jugadores desde su posición', nameCa: 'Pot comunicar-se efectivament amb els jugadors des de la seva posició', weight: 1.0, description: ''),
    ]),
    RubricArea(code: 'COMMUNICATION', name: 'Comunicación', nameCa: 'Comunicació', weight: 1.0, criteria: [
      Criterion(code: 'B1_PRIMARY_SIGNAL_WHISTLE', level: 1, name: 'Usa correctamente la señal primaria y el silbato', nameCa: 'Fa servir correctament la senyal primària i el xiulet', weight: 1.0, description: ''),
      Criterion(code: 'B2_SECONDARY_SIGNAL', level: 2, name: 'Identifica la falta claramente con la señal secundaria', nameCa: 'Identifica la falta clarament amb la senyal secundària', weight: 1.0, description: ''),
      Criterion(code: 'B3_PLAYER_COMMUNICATION', level: 3, name: 'Establece una comunicación eficaz con los jugadores', nameCa: 'Estableix una comunicació efectiva amb els jugadors', weight: 1.0, description: ''),
    ]),
    RubricArea(code: 'CONTINUITY', name: 'Continuidad', nameCa: 'Continuïtat', weight: 1.0, criteria: [
      Criterion(code: 'C1_ADVANTAGE_SIGNAL', level: 1, name: 'Señaliza correctamente la ventaja y su final', nameCa: 'Senyalitza correctament l\'avantatge i la seva fi', weight: 1.0, description: ''),
      Criterion(code: 'C2_MATERIAL_EFFECT', level: 2, name: 'Sanciona solo las faltas con un efecto material en el juego', nameCa: 'Sanciona només les faltes amb un efecte material en el joc', weight: 1.0, description: ''),
      Criterion(code: 'C3_ADVANTAGE_CONSISTENCY', level: 3, name: 'Aplica la ley de la ventaja con consistencia', nameCa: 'Aplica la llei de l\'avantatge amb consistència', weight: 1.0, description: ''),
    ]),
    RubricArea(code: 'SET_PIECE', name: 'Fases estáticas', nameCa: 'Fases estàtiques', weight: 1.0, criteria: [
      Criterion(code: 'D1_ORDERED_SET_PIECE', level: 1, name: 'Consigue que la fase estática sea ordenada y la formación correcta', nameCa: 'Aconsegueix que la fase estàtica sigui ordenada i la formació correcta', weight: 1.0, description: ''),
      Criterion(code: 'D2_SCRUM_SEQUENCE_SAFETY', level: 1, name: 'Aplica correctamente la secuencia de entrada y la seguridad básica en la melé', nameCa: 'Aplica correctament la seqüència d\'entrada i la seguretat bàsica a la melé', weight: 1.0, description: ''),
      Criterion(code: 'D3_DANGER_DETECTION', level: 2, name: 'Detecta las acciones peligrosas para la seguridad de los jugadores', nameCa: 'Detecta accions perilloses per a la seguretat dels jugadors', weight: 1.0, description: ''),
      Criterion(code: 'D4_FAIR_CONTEST', level: 3, name: 'Garantiza la disputa justa en melé, touch y reinicios', nameCa: 'Garanteix la disputa justa en melé, touch i reinicis', weight: 1.0, description: ''),
    ]),
    RubricArea(code: 'DYNAMIC_PHASES', name: 'Fases dinámicas', nameCa: 'Fases dinàmiques', weight: 1.0, criteria: [
      Criterion(code: 'E1_PHASE_IDENTIFICATION', level: 1, name: 'Identifica los distintos tipos de fase (placaje, ruck, maul)', nameCa: 'Identifica els diferents tipus de fases (placatge, ruck, mol)', weight: 1.0, description: ''),
      Criterion(code: 'E2_TACKLER_TACKLED', level: 1, name: 'Conoce y aplica las acciones del placador y del placado', nameCa: 'Coneix i aplica les accions del placador i placat', weight: 1.0, description: ''),
      Criterion(code: 'E3_GATES_ENTRIES', level: 2, name: 'Garantiza que los jugadores usen las puertas y entradas correctas al ruck o maul', nameCa: 'Garanteix que els jugadors usin les portes i entrades al ruck/mol correctes', weight: 1.0, description: ''),
      Criterion(code: 'E4_OFFSIDE_LINES', level: 2, name: 'Controla las líneas de fuera de juego en ruck y maul', nameCa: 'Controla les línies de fora de joc en ruck/mol', weight: 1.0, description: ''),
      Criterion(code: 'E5_CONTEST_ON_FEET', level: 3, name: 'Consigue que la disputa del balón sea de pie', nameCa: 'Aconsegueix que la disputa de la pilota sigui de peu', weight: 1.0, description: ''),
      Criterion(code: 'E6_JACKLER', level: 3, name: 'Conoce y aplica las acciones del jugador que disputa el balón en el suelo («jackler»)', nameCa: 'Coneix i aplica les accions del jugador pescador', weight: 1.0, description: ''),
    ]),
    RubricArea(code: 'DISCIPLINE', name: 'Disciplina', nameCa: 'Disciplina', weight: 1.0, criteria: [
      Criterion(code: 'F1_DANGEROUS_PLAY', level: 1, name: 'Identifica y sanciona las acciones de juego peligroso', nameCa: 'Identifica i sanciona les accions de joc perillós', weight: 1.0, description: ''),
      Criterion(code: 'F2_FOUL_PLAY', level: 2, name: 'Sanciona adecuadamente las acciones de juego sucio', nameCa: 'Sanciona adequadament les accions de Joc Brut', weight: 1.0, description: ''),
      Criterion(code: 'F3_MATCH_CONTROL', level: 3, name: 'Es capaz de mantener el control del partido', nameCa: 'És capaç de mantenir el control del partit', weight: 1.0, description: ''),
    ]),
  ],
  scoring: ScoringParams(
    impactWeights: {ImpactLevel.low: 1.0, ImpactLevel.medium: 2.0, ImpactLevel.high: 4.0, ImpactLevel.matchDefining: 8.0},
    verdictCredit: {Verdict.correct: 1.0, Verdict.debatable: 0.5, Verdict.incorrect: 0.0, Verdict.missed: 0.0},
    accuracyAtZero: 1.0,
    accuracyAtOne: 9.0,
    baseline: 7.0,
    priorStrength: 3.0,
    capRules: [
      CapRule(minImpact: ImpactLevel.matchDefining, minCount: 1, capBand: BandCode.notYet),
      CapRule(minImpact: ImpactLevel.high, minCount: 2, capBand: BandCode.notYet),
    ],
    minJustificationChars: 40,
  ),
);
