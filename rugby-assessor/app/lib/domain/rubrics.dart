// Rúbricas que la app sabe abrir. Los partidos nuevos usan siempre kDefaultRubric (CARC); un
// informe cerrado se abre con la rúbrica con la que se cerró.

import 'rubric.dart';
import 'rubric_default.dart';
import 'rubric_legacy.dart';

AssessmentRubric rubricById(String? id) => id == kLegacyRubricV2Id ? kLegacyRubricV2 : kDefaultRubric;
