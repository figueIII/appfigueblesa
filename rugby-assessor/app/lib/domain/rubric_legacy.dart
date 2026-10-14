// Rúbrica v2.0.0 (RUGBY-XV-BASE), sustituida por las competencias del CARC (v3.0.0).
// Solo sirve para ABRIR y EXPORTAR los informes que se cerraron con ella: ningún partido nuevo
// la usa y la migración v5 pasa a la rúbrica nueva los partidos que aún no estaban cerrados.

import 'model.dart';
import 'rubric.dart';
import 'rubric_default.dart';

/// Id de la rúbrica v2 (assessment.rubric_id de los partidos antiguos).
const String kLegacyRubricV2Id = '01929d6e-0000-7000-8000-000000000001';

final AssessmentRubric kLegacyRubricV2 = AssessmentRubric(
  id: '01929d6e-0000-7000-8000-000000000001',
  code: 'RUGBY-XV-BASE',
  version: '2.0.0',
  name: 'Evaluación del árbitro principal',
  scaleMin: 1.0,
  scaleMax: 10.0,
  // Los informes v2 se leen con la escala del CARC: BELOW → N, AT → C, ABOVE → E (ver decodeBand).
  bands: kDefaultRubric.bands,
  areas: [
    RubricArea(code: 'PHASES', name: 'Gestión de fases de juego', weight: 35.0, criteria: [
      Criterion(code: 'A1_SCRUM', name: 'Scrum', weight: 25.0, description: 'Secuencia de llamadas, estabilidad, ángulos de empuje, introducción, colapsos y lectura de la primera línea dominante.'),
      Criterion(code: 'A2_LINEOUT_MAUL', name: 'Touch y maul', weight: 20.0, description: 'Alineación, espacio entre líneas, lanzamiento recto, formación y obstrucción en el maul, uso de la ventaja en maul parado.'),
      Criterion(code: 'A3_TACKLE_RUCK', name: 'Placaje y ruck', weight: 35.0, description: 'Secuencia placador → placado → llegadas; soltar al jugador, entrada por la puerta, juego sobre los pies, balón disponible.'),
      Criterion(code: 'A4_OFFSIDE_SPACE', name: 'Espacio y fuera de juego', weight: 20.0, description: 'Línea de ventaja en ruck/maul/scrum/touch, fuera de juego en juego abierto y en patadas, regla de los 10 m.'),
    ]),
    RubricArea(code: 'MANAGEMENT', name: 'Comunicación y gestión del partido', weight: 20.0, criteria: [
      Criterion(code: 'B1_VERBAL_CONTROL', name: 'Control verbal y preventivo', weight: 30.0, description: 'Llamadas claras y a tiempo que evitan infracciones (“suelta”, “fuera manos”).'),
      Criterion(code: 'B2_TONE_PRESENCE', name: 'Tono, señalización y presencia', weight: 20.0, description: 'Señales correctas, tono adecuado a la situación, credibilidad y calma.'),
      Criterion(code: 'B3_CAPTAINS_PLAYERS', name: 'Gestión de capitanes y jugadores', weight: 20.0, description: 'Uso de los capitanes, avisos colectivos, gestión de la temperatura del partido.'),
      Criterion(code: 'B4_ADVANTAGE', name: 'Aplicación de la ventaja', weight: 30.0, description: 'Ventaja táctica y territorial, duración adecuada, llamada y cierre claros.'),
    ]),
    RubricArea(code: 'LAW_DISCIPLINE', name: 'Aplicación de leyes y consistencia disciplinaria', weight: 30.0, criteria: [
      Criterion(code: 'C1_LAW_ACCURACY', name: 'Exactitud en la aplicación de las leyes', weight: 50.0, description: 'Conocimiento y aplicación correcta del reglamento: decisiones de hecho (ensayo, avant, pase adelantado), sanción y reinicio correctos, errores teóricos de reglamento.'),
      Criterion(code: 'C2_FOUL_PLAY', name: 'Detección y sanción del juego desleal', weight: 30.0, description: 'Placajes altos, juego peligroso, proceso de decisión del árbitro (incluida la consulta al TMO cuando la hay; el TMO no se evalúa), factores agravantes y atenuantes.'),
      Criterion(code: 'C3_SANCTION_CONSISTENCY', name: 'Consistencia disciplinaria', weight: 20.0, description: 'Mismo criterio para ambos equipos y durante todo el partido; infracción repetida y tarjeta por acumulación.'),
    ]),
    RubricArea(code: 'FITNESS_POSITIONING', name: 'Condición física, posicionamiento y líneas de carrera', weight: 15.0, criteria: [
      Criterion(code: 'D1_FITNESS', name: 'Condición física', weight: 30.0, description: 'Capacidad para llegar a cada fase durante los 80 minutos; caída de rendimiento al final.'),
      Criterion(code: 'D2_POSITIONING', name: 'Posicionamiento', weight: 40.0, description: 'Ángulo de visión en el breakdown, el scrum y la touch; posición ante las patadas y en la zona de ensayo.'),
      Criterion(code: 'D3_RUNNING_LINES', name: 'Líneas de carrera', weight: 30.0, description: 'No obstruir el juego, anticipar, transiciones entre fases.'),
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
