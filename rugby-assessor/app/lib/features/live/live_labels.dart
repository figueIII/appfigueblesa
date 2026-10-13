// Textos de la pantalla de directo (es-ES). Cortos y en mayúscula inicial: se leen de un vistazo.

import 'package:flutter/material.dart';

import '../../domain/model.dart';

const Map<IncidentCategory, String> kCategoryLabel = {
  IncidentCategory.tackle: 'Placaje',
  IncidentCategory.ruck: 'Ruck',
  IncidentCategory.offside: 'Fuera de juego',
  IncidentCategory.scrum: 'Scrum',
  IncidentCategory.lineout: 'Touch',
  IncidentCategory.maul: 'Maul',
  IncidentCategory.advantage: 'Ventaja',
  IncidentCategory.foulPlay: 'Juego desleal',
  IncidentCategory.card: 'Tarjeta',
  IncidentCategory.tryGrounding: 'Ensayo',
  IncidentCategory.knockOnForwardPass: 'Avant / pase',
  IncidentCategory.otherLaw: 'Otra ley',
  IncidentCategory.communication: 'Comunicación',
  IncidentCategory.captainMgmt: 'Capitanes',
  IncidentCategory.tmoProcess: 'Proceso TMO',
  IncidentCategory.positioning: 'Posicionamiento',
  IncidentCategory.fitness: 'Condición física',
  IncidentCategory.runningLine: 'Líneas de carrera',
};

/// Rejilla principal: 4 filas × 3. Las más frecuentes abajo, en la zona natural del pulgar.
/// `null` = tesela "Más…". Orden de arriba abajo.
const List<List<IncidentCategory?>> kPrimaryGrid = [
  [IncidentCategory.tryGrounding, IncidentCategory.knockOnForwardPass, null],
  [IncidentCategory.advantage, IncidentCategory.foulPlay, IncidentCategory.card],
  [IncidentCategory.scrum, IncidentCategory.lineout, IncidentCategory.maul],
  [IncidentCategory.tackle, IncidentCategory.ruck, IncidentCategory.offside],
];

/// Categorías poco frecuentes, en la hoja "Más…".
const List<IncidentCategory> kSecondaryCategories = [
  IncidentCategory.otherLaw,
  IncidentCategory.communication,
  IncidentCategory.captainMgmt,
  IncidentCategory.tmoProcess,
  IncidentCategory.positioning,
  IncidentCategory.fitness,
  IncidentCategory.runningLine,
];

String polarityLabel(QuickPolarity p) => switch (p) {
      QuickPolarity.positive => 'Bien',
      QuickPolarity.negative => 'Error',
      QuickPolarity.review => 'Por revisar',
    };

IconData polarityIcon(QuickPolarity p) => switch (p) {
      QuickPolarity.positive => Icons.check_circle_rounded,
      QuickPolarity.negative => Icons.cancel_rounded,
      QuickPolarity.review => Icons.flag_rounded,
    };
