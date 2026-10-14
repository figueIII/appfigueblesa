// Rúbrica por defecto v3.0.0: competencias del CARC (hoja «Full avaluació arbitral»).
// Seis áreas y 25 competencias, cada una con su nivel (N1 básico → N3 avanzado) y la escala
// E / C / N / U. Los textos catalanes son los originales del CARC; los castellanos, su traducción.
// Pesos iguales: todas las competencias cuentan lo mismo dentro de su área y todas las áreas lo
// mismo en la valoración global. La rúbrica v2.0.0 (RUGBY-XV-BASE) sigue en el código solo para
// abrir los informes que se cerraron con ella.

import type { AssessmentRubric, Criterion } from './model.ts';

const c = (code: Criterion['code'], level: 1 | 2 | 3, name: string, nameCa: string): Criterion =>
  ({ code, level, name, nameCa, description: '', weight: 1 });

export const DEFAULT_RUBRIC: AssessmentRubric = {
  id: '01929d6e-0000-7000-8000-000000000003',
  code: 'CARC-COMPETENCIES',
  version: '3.0.0',
  name: 'Competencias del árbitro (CARC)',
  appliesTo: { formats: ['XV', 'TENS', 'SEVENS'] },
  scale: { min: 1, max: 10 },
  bands: [
    { code: 'E', label: 'Excelente', labelCa: 'Excel·lent', representative: 9, lower: 8, lowerInclusive: false,
      description: 'Rendimiento excelente en esta competencia.', descriptionCa: 'Rendiment excel·lent en aquesta competència.' },
    { code: 'C', label: 'Competente', labelCa: 'Competent', representative: 7, lower: 6, lowerInclusive: true,
      description: 'Domina la competencia al nivel exigido.', descriptionCa: 'Domina la competència al nivell exigit.' },
    { code: 'N', label: 'No competente todavía', labelCa: 'No competent encara', representative: 5, lower: 4, lowerInclusive: true,
      description: 'Todavía no domina la competencia: hay que trabajarla.', descriptionCa: 'Encara no domina la competència: cal treballar-la.' },
    { code: 'U', label: 'Revisión urgente', labelCa: 'Urgent revisar', representative: 3, lower: -Infinity, lowerInclusive: true,
      description: 'Hay que revisar esta competencia con urgencia.', descriptionCa: 'Cal revisar aquesta competència amb urgència.' },
  ],
  areas: [
    {
      code: 'POSITIONING', name: 'Colocación', nameCa: 'Col·locació', weight: 1,
      criteria: [
        c('A1_STATIC_START', 1, 'El punto de partida en las fases estáticas es adecuado para seguir el juego',
          "El punt de partida en les fases estàtiques és adequat per seguir el joc"),
        c('A2_NO_INTERFERENCE', 1, 'Su posición no interfiere en el juego ni en los jugadores',
          'La seva posició no interfereix en el joc o jugadors'),
        c('A3_SEES_PLAY', 2, 'Puede ver el balón, los jugadores cercanos y los jugadores alejados',
          'Pot veure la pilota, els jugadors a prop i els jugadors allunyats'),
        c('A4_OPEN_PLAY_LINES', 2, 'Utiliza trayectorias adecuadas para seguir el juego abierto',
          'Utilitza trajectòries adequades per seguir el joc obert'),
        c('A5_REACHES_CONTACT', 3, 'Llega a los puntos de encuentro adecuadamente durante todo el partido',
          "Arriba als punts d'encontre adequadament durant tot el partit"),
        c('A6_COMMUNICATES_FROM_POSITION', 3, 'Puede comunicarse eficazmente con los jugadores desde su posición',
          'Pot comunicar-se efectivament amb els jugadors des de la seva posició'),
      ],
    },
    {
      code: 'COMMUNICATION', name: 'Comunicación', nameCa: 'Comunicació', weight: 1,
      criteria: [
        c('B1_PRIMARY_SIGNAL_WHISTLE', 1, 'Usa correctamente la señal primaria y el silbato',
          'Fa servir correctament la senyal primària i el xiulet'),
        c('B2_SECONDARY_SIGNAL', 2, 'Identifica la falta claramente con la señal secundaria',
          'Identifica la falta clarament amb la senyal secundària'),
        c('B3_PLAYER_COMMUNICATION', 3, 'Establece una comunicación eficaz con los jugadores',
          'Estableix una comunicació efectiva amb els jugadors'),
      ],
    },
    {
      code: 'CONTINUITY', name: 'Continuidad', nameCa: 'Continuïtat', weight: 1,
      criteria: [
        c('C1_ADVANTAGE_SIGNAL', 1, 'Señaliza correctamente la ventaja y su final',
          "Senyalitza correctament l'avantatge i la seva fi"),
        c('C2_MATERIAL_EFFECT', 2, 'Sanciona solo las faltas con un efecto material en el juego',
          'Sanciona només les faltes amb un efecte material en el joc'),
        c('C3_ADVANTAGE_CONSISTENCY', 3, 'Aplica la ley de la ventaja con consistencia',
          "Aplica la llei de l'avantatge amb consistència"),
      ],
    },
    {
      code: 'SET_PIECE', name: 'Fases estáticas', nameCa: 'Fases estàtiques', weight: 1,
      criteria: [
        c('D1_ORDERED_SET_PIECE', 1, 'Consigue que la fase estática sea ordenada y la formación correcta',
          'Aconsegueix que la fase estàtica sigui ordenada i la formació correcta'),
        c('D2_SCRUM_SEQUENCE_SAFETY', 1, 'Aplica correctamente la secuencia de entrada y la seguridad básica en la melé',
          "Aplica correctament la seqüència d'entrada i la seguretat bàsica a la melé"),
        c('D3_DANGER_DETECTION', 2, 'Detecta las acciones peligrosas para la seguridad de los jugadores',
          'Detecta accions perilloses per a la seguretat dels jugadors'),
        c('D4_FAIR_CONTEST', 3, 'Garantiza la disputa justa en melé, touch y reinicios',
          'Garanteix la disputa justa en melé, touch i reinicis'),
      ],
    },
    {
      code: 'DYNAMIC_PHASES', name: 'Fases dinámicas', nameCa: 'Fases dinàmiques', weight: 1,
      criteria: [
        c('E1_PHASE_IDENTIFICATION', 1, 'Identifica los distintos tipos de fase (placaje, ruck, maul)',
          'Identifica els diferents tipus de fases (placatge, ruck, mol)'),
        c('E2_TACKLER_TACKLED', 1, 'Conoce y aplica las acciones del placador y del placado',
          'Coneix i aplica les accions del placador i placat'),
        c('E3_GATES_ENTRIES', 2, 'Garantiza que los jugadores usen las puertas y entradas correctas al ruck o maul',
          'Garanteix que els jugadors usin les portes i entrades al ruck/mol correctes'),
        c('E4_OFFSIDE_LINES', 2, 'Controla las líneas de fuera de juego en ruck y maul',
          'Controla les línies de fora de joc en ruck/mol'),
        c('E5_CONTEST_ON_FEET', 3, 'Consigue que la disputa del balón sea de pie',
          'Aconsegueix que la disputa de la pilota sigui de peu'),
        c('E6_JACKLER', 3, 'Conoce y aplica las acciones del jugador que disputa el balón en el suelo («jackler»)',
          'Coneix i aplica les accions del jugador pescador'),
      ],
    },
    {
      code: 'DISCIPLINE', name: 'Disciplina', nameCa: 'Disciplina', weight: 1,
      criteria: [
        c('F1_DANGEROUS_PLAY', 1, 'Identifica y sanciona las acciones de juego peligroso',
          'Identifica i sanciona les accions de joc perillós'),
        c('F2_FOUL_PLAY', 2, 'Sanciona adecuadamente las acciones de juego sucio',
          'Sanciona adequadament les accions de Joc Brut'),
        c('F3_MATCH_CONTROL', 3, 'Es capaz de mantener el control del partido',
          'És capaç de mantenir el control del partit'),
      ],
    },
  ],
  categoryToCriterion: {
    SCRUM: 'D2_SCRUM_SEQUENCE_SAFETY', LINEOUT: 'D4_FAIR_CONTEST', MAUL: 'E3_GATES_ENTRIES',
    TACKLE: 'E2_TACKLER_TACKLED', RUCK: 'E3_GATES_ENTRIES', OFFSIDE: 'E4_OFFSIDE_LINES',
    COMMUNICATION: 'B3_PLAYER_COMMUNICATION', CAPTAIN_MGMT: 'F3_MATCH_CONTROL', ADVANTAGE: 'C3_ADVANTAGE_CONSISTENCY',
    TRY_GROUNDING: 'A3_SEES_PLAY', KNOCK_ON_FORWARD_PASS: 'C2_MATERIAL_EFFECT', OTHER_LAW: 'C2_MATERIAL_EFFECT',
    FOUL_PLAY: 'F1_DANGEROUS_PLAY', TMO_PROCESS: 'F2_FOUL_PLAY', CARD: 'F2_FOUL_PLAY',
    FITNESS: 'A5_REACHES_CONTACT', POSITIONING: 'A3_SEES_PLAY', RUNNING_LINE: 'A4_OPEN_PLAY_LINES',
  },
  scoring: {
    impactWeights: { LOW: 1, MEDIUM: 2, HIGH: 4, MATCH_DEFINING: 8 },
    verdictCredit: { CORRECT: 1, DEBATABLE: 0.5, INCORRECT: 0, MISSED: 0 },
    accuracyToScore: { atZero: 1, atOne: 9 },
    baseline: 7.0,
    priorStrength: 3,
    capRules: [
      { minImpact: 'MATCH_DEFINING', minCount: 1, capBand: 'N' },
      { minImpact: 'HIGH', minCount: 2, capBand: 'N' },
    ],
    minJustificationChars: 40,
  },
  status: 'PUBLISHED',
};
