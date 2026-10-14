// Idioma de la app: castellano por defecto y catalán a elegir en el menú de inicio.
//
// En catalán se muestran los textos del CARC (áreas, competencias, escala E/C/N/U y
// recomendación de nivel), en pantalla y en el PDF. La elección se guarda en la base de datos
// (tabla app_setting) y se recupera al abrir la app.

import 'package:flutter/foundation.dart';

import '../domain/rubric.dart';

enum AppLanguage { es, ca }

/// Idioma actual. La pantalla de inicio lo cambia; el resto de pantallas lo leen al construirse.
final ValueNotifier<AppLanguage> appLanguage = ValueNotifier(AppLanguage.es);

bool get isCatalan => appLanguage.value == AppLanguage.ca;

/// Elige el texto según el idioma; si falta el catalán, se queda el castellano.
String tr(String es, [String? ca]) => isCatalan && ca != null && ca.isNotEmpty ? ca : es;

String encodeLanguage(AppLanguage l) => l.name;
AppLanguage decodeLanguage(String? s) => s == 'ca' ? AppLanguage.ca : AppLanguage.es;

String languageName(AppLanguage l) => switch (l) {
      AppLanguage.es => 'Español',
      AppLanguage.ca => 'Català',
    };

extension CriterionText on Criterion {
  String get label => tr(name, nameCa);

  /// "N1", "N2", "N3" o null (rúbrica v2).
  String? get levelLabel => level == null ? null : 'N$level';
}

extension AreaText on RubricArea {
  String get label => tr(name, nameCa);
}

extension BandText on PerformanceBand {
  String get text => tr(label, labelCa);
  String get help => tr(description, descriptionCa);
}

/// "E · Excelente" (o "E · Excel·lent").
String bandFullLabel(AssessmentRubric rubric, BandCode b) {
  final band = rubric.band(b);
  return '${band.letter} · ${band.text}';
}
