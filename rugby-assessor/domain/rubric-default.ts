// Rúbrica por defecto (propuesta v1). Los pesos, bandas y topes son PARÁMETROS a validar con el
// comité técnico de árbitros: ver docs/…/ESPECIFICACION… §1.2 y la pregunta abierta Q1.

import type { AssessmentRubric } from './model.ts';

export const DEFAULT_RUBRIC: AssessmentRubric = {
  id: '01929d6e-0000-7000-8000-000000000001',
  code: 'RUGBY-XV-BASE',
  version: '1.0.0',
  name: 'Evaluación de árbitro principal — XV (base)',
  appliesTo: { formats: ['XV', 'TENS', 'SEVENS'], roles: ['REFEREE'] },
  scale: { min: 1, max: 10, step: 0.5 },
  bands: [
    { code: 'EXCEPTIONAL', label: 'Excepcional', minInclusive: 8.5 },
    { code: 'ABOVE', label: 'Por encima del estándar', minInclusive: 7.5 },
    { code: 'STANDARD', label: 'Estándar del nivel', minInclusive: 6.5 },
    { code: 'IMPROVE', label: 'Necesita mejorar', minInclusive: 5.0 },
    { code: 'BELOW', label: 'Por debajo del estándar', minInclusive: 1.0 },
  ],
  areas: [
    {
      code: 'PHASES', name: 'Gestión de fases de juego', weight: 40,
      criteria: [
        { code: 'A1_SCRUM', name: 'Scrum', weight: 25, description: 'Secuencia de llamadas, estabilidad, ángulos de empuje, introducción, colapsos y lectura de la primera línea dominante.' },
        { code: 'A2_LINEOUT_MAUL', name: 'Touch y maul', weight: 20, description: 'Alineación, espacio entre líneas, lanzamiento recto, formación y obstrucción en el maul, uso de la ventaja en maul parado.' },
        { code: 'A3_TACKLE_RUCK', name: 'Placaje y ruck', weight: 35, description: 'Secuencia placador → placado → llegadas; soltar al jugador, entrada por la puerta, juego sobre los pies, balón disponible.' },
        { code: 'A4_OFFSIDE_SPACE', name: 'Espacio y fuera de juego', weight: 20, description: 'Línea de ventaja en ruck/maul/scrum/touch, fuera de juego en juego abierto y en patadas, regla de los 10 m.' },
      ],
    },
    {
      code: 'MANAGEMENT', name: 'Comunicación y gestión del partido', weight: 25,
      criteria: [
        { code: 'B1_VERBAL_CONTROL', name: 'Control verbal y preventivo', weight: 30, description: 'Llamadas claras y a tiempo que evitan infracciones (“suelta”, “fuera manos”).' },
        { code: 'B2_TONE_PRESENCE', name: 'Tono, señalización y presencia', weight: 20, description: 'Señales correctas, tono adecuado a la situación, credibilidad y calma.' },
        { code: 'B3_CAPTAINS_PLAYERS', name: 'Gestión de capitanes y jugadores', weight: 20, description: 'Uso de los capitanes, avisos colectivos, gestión de la temperatura del partido.' },
        { code: 'B4_ADVANTAGE', name: 'Aplicación de la ventaja', weight: 30, description: 'Ventaja táctica y territorial, duración adecuada, llamada y cierre claros.' },
      ],
    },
    {
      code: 'LAW_DISCIPLINE', name: 'Aplicación de leyes y consistencia disciplinaria', weight: 20,
      criteria: [
        { code: 'C1_LAW_ACCURACY', name: 'Exactitud en la aplicación de las leyes', weight: 30, description: 'Decisiones de hecho (ensayo, avant, pase adelantado) y sanción correcta en cada caso.' },
        { code: 'C2_FOUL_PLAY', name: 'Detección y sanción del juego desleal', weight: 40, description: 'Placajes altos, juego peligroso, proceso del árbitro y del TMO, factores agravantes y atenuantes.' },
        { code: 'C3_SANCTION_CONSISTENCY', name: 'Consistencia disciplinaria', weight: 30, description: 'Mismo criterio para ambos equipos y durante todo el partido; infracción repetida y tarjeta por acumulación.' },
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
      { minImpact: 'MATCH_DEFINING', minCount: 1, cap: 5.5 },
      { minImpact: 'HIGH', minCount: 2, cap: 6.0 },
    ],
    deviationRequiringJustification: 1.0,
    minJustificationChars: 40,
  },
  status: 'PUBLISHED',
};
