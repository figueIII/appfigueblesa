// Port de domain/category-presets.ts (decisión R6). Valores exactos del responsable de dominio.

import 'model.dart';

const List<CategoryConfig> kCategoryPresets = [
  CategoryConfig(code: 'SM_DHCAT_1_2_3', name: 'Sénior masc. · DHCAT, 1ª, 2ª, 3ª', format: GameFormat.xv, periodLengthMin: 40, sinBinMin: 10),
  CategoryConfig(code: 'SM_3AB_4', name: 'Sénior masc. · 3ª grupo AB, 4ª', format: GameFormat.xv, periodLengthMin: 35, sinBinMin: 10),
  CategoryConfig(code: 'SF_DHCAT_1', name: 'Sénior fem. · DHCAT, 1ª', format: GameFormat.xv, periodLengthMin: 40, sinBinMin: 10),
  CategoryConfig(code: 'SF_ABC_2', name: 'Sénior fem. · grupo ABC, 2ª', format: GameFormat.xv, periodLengthMin: 35, sinBinMin: 10),
  CategoryConfig(code: 'M18', name: 'M18', format: GameFormat.xv, periodLengthMin: 35, sinBinMin: 5),
  CategoryConfig(code: 'M16', name: 'M16', format: GameFormat.xv, periodLengthMin: 35, sinBinMin: 5),
  CategoryConfig(code: 'M14', name: 'M14', format: GameFormat.xv, periodLengthMin: 30, sinBinMin: 5),
  CategoryConfig(code: 'SEVENS', name: 'Rugby 7s', format: GameFormat.sevens, periodLengthMin: 7, sinBinMin: 2),
];

CategoryConfig categoryPreset(String code) => kCategoryPresets.firstWhere(
      (c) => c.code == code,
      orElse: () => throw ArgumentError.value(code, 'code', 'UNKNOWN_CATEGORY_PRESET'),
    );
