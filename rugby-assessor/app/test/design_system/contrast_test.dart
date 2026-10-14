// Verifica los contrastes que promete tokens.dart (WCAG 2.x, luminancia relativa).
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/core/design_system/tokens.dart';

double _lin(double c) => c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
double _lum(Color c) => 0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b);
double contrast(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final (name, t) in [('claro', RefColors.light), ('oscuro', RefColors.dark)]) {
    group('tema $name', () {
      final textPairs = {
        'texto/fondo': (t.onSurface, t.background),
        'texto/tesela': (t.onSurface, t.surface),
        'texto/tesela pulsada': (t.onSurface, t.surfacePressed),
        'secundario/fondo': (t.onSurfaceMuted, t.background),
        'secundario/tesela': (t.onSurfaceMuted, t.surface),
        'primario': (t.onPrimary, t.primary),
        'bien': (t.onPositive, t.positive),
        'error': (t.onNegative, t.negative),
        'revisar': (t.onReview, t.review),
        'aviso': (t.onWarningSurface, t.warningSurface),
        'snackbar': (t.background, t.onSurface),
      };
      for (final e in textPairs.entries) {
        test('${e.key} ≥ 7:1 (AAA, lectura a pleno sol)', () {
          expect(contrast(e.value.$1, e.value.$2), greaterThanOrEqualTo(7.0));
        });
      }
      test('borde de tesela ≥ 3:1 contra fondo y tesela (no-texto)', () {
        expect(contrast(t.outline, t.background), greaterThanOrEqualTo(3.0));
        expect(contrast(t.outline, t.surface), greaterThanOrEqualTo(3.0));
      });
      test('destello de confirmación (primario) ≥ 3:1 contra la tesela pulsada', () {
        expect(contrast(t.primary, t.surfacePressed), greaterThanOrEqualTo(3.0));
      });
    });
  }
}
