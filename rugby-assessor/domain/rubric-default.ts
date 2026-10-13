// Rúbrica por defecto v2.0.0, validada por el responsable de dominio (decisiones R1–R5):
// prioridad al conocimiento reglamentario (área C al 30 %, C1 al 50 %), bandas cualitativas
// como única cara visible y topes limitados al criterio. Ver docs/…/ESPECIFICACION… §0 y §1.2.

import type { AssessmentRubric } from './model.ts';

export const DEFAULT_RUBRIC: AssessmentRubric = {
  id: '01929d6e-0000-7000-8000-000000000001',
  code: 'RUGBY-XV-BASE',
  version: '2.0.0',
  name: 'Evaluación del árbitro principal',
  appliesTo: { formats: ['XV', 'TENS', 'SEVENS'] },
  scale: { min: 1, max: 10 },
  bands: [
    { code: 'ABOVE', label: 'Por encima del nivel', representative: 9, lower: 8, lowerInclusive: false,
      description: 'Rendimiento superior al exigible para el nivel de este partido.' },
    { code: 'AT', label: 'En el nivel', representative: 7, lower: 6, lowerInclusive: true,
      description: 'Rendimiento acorde al nivel de este partido.' },
    { code: 'BELOW', label: 'Por debajo del nivel', representative: 5, lower: -Infinity, lowerInclusive: true,
      description: 'Rendimiento inferior al exigible para el nivel de este partido.' },
  ],
  areas: [
    {
      code: 'PHASES', name: 'Gestión de fases de juego', weight: 35,
      criteria: [
        { code: 'A1_SCRUM', name: 'Scrum', weight: 25, description: 'Secuencia de llamadas, estabilidad, ángulos de empuje, introducción, colapsos y lectura de la primera línea dominante.' },
        { code: 'A2_LINEOUT_MAUL', name: 'Touch y maul', weight: 20, description: 'Alineación, espacio entre líneas, lanzamiento recto, formación y obstrucción en el maul, uso de la ventaja en maul parado.' },
        { code: 'A3_TACKLE_RUCK', name: 'Placaje y ruck', weight: 35, description: 'Secuencia placador → placado → llegadas; soltar al jugador, entrada por la puerta, juego sobre los pies, balón disponible.' },
        { code: 'A4_OFFSIDE_SPACE', name: 'Espacio y fuera de juego', weight: 20, description: 'Línea de ventaja en ruck/maul/scrum/touch, fuera de juego en juego abierto y en patadas, regla de los 10 m.' },
      ],
    },
    {
      code: 'MANAGEMENT', name: 'Comunicación y gestión del partido', weight: 20,
      criteria: [
        { code: 'B1_VERBAL_CONTROL', name: 'Control verbal y preventivo', weight: 30, description: 'Llamadas claras y a tiempo que evitan infracciones (“suelta”, “fuera manos”).' },
        { code: 'B2_TONE_PRESENCE', name: 'Tono, señalización y presencia', weight: 20, description: 'Señales correctas, tono adecuado a la situación, credibilidad y calma.' },
        { code: 'B3_CAPTAINS_PLAYERS', name: 'Gestión de capitanes y jugadores', weight: 20, description: 'Uso de los capitanes, avisos colectivos, gestión de la temperatura del partido.' },
        { code: 'B4_ADVANTAGE', name: 'Aplicación de la ventaja', weight: 30, description: 'Ventaja táctica y territorial, duración adecuada, llamada y cierre claros.' },
      ],
    },
    {
      code: 'LAW_DISCIPLINE', name: 'Aplicación de leyes y consistencia disciplinaria', weight: 30,
      criteria: [
        { code: 'C1_LAW_ACCURACY', name: 'Exactitud en la aplicación de las leyes', weight: 50, description: 'Conocimiento y aplicación correcta del reglamento: decisiones de hecho (ensayo, avant, pase adelantado), sanción y reinicio correctos, errores teóricos de reglamento.' },
        { code: 'C2_FOUL_PLAY', name: 'Detección y sanción del juego desleal', weight: 30, description: 'Placajes altos, juego peligroso, proceso de decisión del árbitro (incluida la consulta al TMO cuando la hay; el TMO no se evalúa), factores agravantes y atenuantes.' },
        { code: 'C3_SANCTION_CONSISTENCY', name: 'Consistencia disciplinaria', weight: 20, description: 'Mismo criterio para ambos equipos y durante todo el partido; infracción repetida y tarjeta por acumulación.' },
      ],
    },
    {
      code: 'FITNESS_POSITIONING', name: 'Condición física, posicionamiento y líneas de carrera', weight: 15,
      criteria: [
        { code: 'D1_FITNESS', name: 'Condición física', weight: 30, description: 'Capacidad para llegar a cada fase durante los 80 minutos; caída de rendimiento al final.' },
        { code: 'D2_POSITIONING', name: 'Posicionamiento', weight: 40, description: 'Ángulo de visión en el breakdown, el scrum y la touch; posición ante las patadas y en la zona de ensayo.' },
        { code: 'D3_RUNNING_LINES', name: 'Líneas de carrera', weight: 30, description: 'No obstruir el juego, anticipar, transiciones entre fases.' },
      ],
    },
  ],
  categoryToCriterion: {
    SCRUM: 'A1_SCRUM', LINEOUT: 'A2_LINEOUT_MAUL', MAUL: 'A2_LINEOUT_MAUL',
    TACKLE: 'A3_TACKLE_RUCK', RUCK: 'A3_TACKLE_RUCK', OFFSIDE: 'A4_OFFSIDE_SPACE',
    COMMUNICATION: 'B1_VERBAL_CONTROL', CAPTAIN_MGMT: 'B3_CAPTAINS_PLAYERS', ADVANTAGE: 'B4_ADVANTAGE',
    TRY_GROUNDING: 'C1_LAW_ACCURACY', KNOCK_ON_FORWARD_PASS: 'C1_LAW_ACCURACY', OTHER_LAW: 'C1_LAW_ACCURACY',
    FOUL_PLAY: 'C2_FOUL_PLAY', TMO_PROCESS: 'C2_FOUL_PLAY', CARD: 'C3_SANCTION_CONSISTENCY',
    FITNESS: 'D1_FITNESS', POSITIONING: 'D2_POSITIONING', RUNNING_LINE: 'D3_RUNNING_LINES',
  },
  scoring: {
    impactWeights: { LOW: 1, MEDIUM: 2, HIGH: 4, MATCH_DEFINING: 8 },
    verdictCredit: { CORRECT: 1, DEBATABLE: 0.5, INCORRECT: 0, MISSED: 0 },
    accuracyToScore: { atZero: 1, atOne: 9 },
    baseline: 7.0,
    priorStrength: 3,
    capRules: [
      { minImpact: 'MATCH_DEFINING', minCount: 1, capBand: 'BELOW' },
      { minImpact: 'HIGH', minCount: 2, capBand: 'BELOW' },
    ],
    minJustificationChars: 40,
  },
  status: 'PUBLISHED',
};
