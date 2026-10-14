// Presets oficiales de tiempos y categorías (decisión R6). Valores exactos facilitados por el
// responsable de dominio; no se infieren ni se completan con datos de otras federaciones.
// El descanso (halfTimeMin) y la prórroga no forman parte de los presets: quedan sin fijar.

import type { CategoryConfig } from './model.ts';

const xv = (code: string, name: string, competitions: string[], periodLengthMin: number, sinBinMin: number): CategoryConfig => ({
  code, name, competitions, format: 'XV', periodLengthMin, extraTime: null, sinBinMin, lawVariations: [],
});

export const CATEGORY_PRESETS: readonly CategoryConfig[] = [
  xv('SM_DHCAT_1_2_3', 'Sénior masculino — DHCAT, 1ª, 2ª, 3ª', ['DHCAT', '1ª', '2ª', '3ª'], 40, 10),
  xv('SM_3AB_4', 'Sénior masculino — 3ª grupo AB, 4ª', ['3ª grupo AB', '4ª'], 35, 10),
  xv('SF_DHCAT_1', 'Sénior femenino — DHCAT, 1ª', ['DHCAT', '1ª'], 40, 10),
  xv('SF_ABC_2', 'Sénior femenino — grupo ABC, 2ª', ['grupo ABC', '2ª'], 35, 10),
  xv('M18', 'M18', ['M18'], 35, 5),
  xv('M16', 'M16', ['M16'], 35, 5),
  xv('M14', 'M14', ['M14'], 30, 5),
  { code: 'SEVENS', name: 'Rugby 7s', competitions: ['Rugby 7s'], format: 'SEVENS', periodLengthMin: 7, extraTime: null, sinBinMin: 2, lawVariations: [] },
];

export function categoryPreset(code: string): CategoryConfig {
  const preset = CATEGORY_PRESETS.find((c) => c.code === code);
  if (!preset) throw new Error(`UNKNOWN_CATEGORY_PRESET: ${code}`);
  // Copia profunda: el partido guarda un snapshot que no debe compartir referencias con el catálogo.
  return structuredClone(preset);
}
