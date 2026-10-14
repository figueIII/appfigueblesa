// Tokens del sistema de diseño (UI-UX-Pro-Max: estilo "Minimalism & Swiss", ajustado a uso
// exterior). Toda la UI consume estos tokens: ningún widget usa un hex ni un número suelto.
//
// Contraste comprobado con tool/contrast_check.dart (WCAG 2.x):
//   texto principal ≥ 7:1 (AAA) en ambos temas, para leer a pleno sol;
//   bordes y estados ≥ 3:1 (no-texto); semántica nunca solo por color (siempre icono + texto).

import 'package:flutter/material.dart';

/// Paleta semántica de un tema. Los componentes piden roles, no colores.
@immutable
class RefColors extends ThemeExtension<RefColors> {
  const RefColors({
    required this.background,
    required this.surface,
    required this.surfacePressed,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.outline,
    required this.primary,
    required this.onPrimary,
    required this.positive,
    required this.onPositive,
    required this.negative,
    required this.onNegative,
    required this.review,
    required this.onReview,
    required this.warningSurface,
    required this.onWarningSurface,
  });

  final Color background;
  final Color surface;          // fondo de las teselas de etiqueta
  final Color surfacePressed;   // estado pulsado (sin cambiar el tamaño)
  final Color onSurface;
  final Color onSurfaceMuted;   // texto secundario: también ≥ 7:1
  final Color outline;          // borde de teselas: define el contorno con reflejos
  final Color primary;
  final Color onPrimary;
  final Color positive;         // ✓ bien
  final Color onPositive;
  final Color negative;         // ✗ error
  final Color onNegative;
  final Color review;           // ● revisar / tiempo parado
  final Color onReview;
  final Color warningSurface;   // banda de aviso (tiempo cumplido, integridad)
  final Color onWarningSurface;

  /// Tema claro: el de referencia a pleno sol (fondo blanco, tinta casi negra).
  static const light = RefColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF1F5F9),
    surfacePressed: Color(0xFFCBD5E1),
    onSurface: Color(0xFF0F172A),
    onSurfaceMuted: Color(0xFF334155),
    outline: Color(0xFF475569),
    primary: Color(0xFF1E40AF),
    onPrimary: Color(0xFFFFFFFF),
    positive: Color(0xFF166534),
    onPositive: Color(0xFFFFFFFF),
    negative: Color(0xFF991B1B),
    onNegative: Color(0xFFFFFFFF),
    review: Color(0xFF92400E),
    onReview: Color(0xFFFFFFFF),
    warningSurface: Color(0xFFFEF3C7),
    onWarningSurface: Color(0xFF78350F),
  );

  /// Tema oscuro: partidos nocturnos con focos. Mismos roles, contraste verificado por separado.
  static const dark = RefColors(
    background: Color(0xFF020617),
    surface: Color(0xFF1E293B),
    surfacePressed: Color(0xFF475569),
    onSurface: Color(0xFFF8FAFC),
    onSurfaceMuted: Color(0xFFCBD5E1),
    outline: Color(0xFF94A3B8),
    primary: Color(0xFF93C5FD),
    onPrimary: Color(0xFF0F172A),
    positive: Color(0xFF86EFAC),
    onPositive: Color(0xFF052E16),
    negative: Color(0xFFFCA5A5),
    onNegative: Color(0xFF450A0A),
    review: Color(0xFFFCD34D),
    onReview: Color(0xFF422006),
    warningSurface: Color(0xFF422006),
    onWarningSurface: Color(0xFFFDE68A),
  );

  @override
  RefColors copyWith() => this;

  @override
  RefColors lerp(ThemeExtension<RefColors>? other, double t) => t < 0.5 ? this : (other as RefColors? ?? this);
}

/// Ritmo de espaciado de 8 dp (con 4 para ajustes finos).
abstract final class RefSpace {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class RefRadius {
  static const double tile = 16;
  static const double control = 12;
  static const double pill = 999;
}

/// Tamaños táctiles. El mínimo de Material es 48 dp; en la banda (dedos fríos o mojados,
/// guantes, mirando al campo) se usa 64 dp para controles y ≥ 88 dp para las etiquetas.
abstract final class RefTouch {
  static const double minTarget = 48;
  static const double control = 64;
  static const double tileMinHeight = 88;
  static const double gap = 8;          // separación mínima entre objetivos (8 dp)
  static const double tileGap = 10;
}

abstract final class RefMotion {
  /// Respuesta del estado pulsado: inmediata (el cambio de color se pinta en el mismo frame).
  static const Duration press = Duration.zero;
  /// Destello de confirmación tras registrar una marca.
  static const Duration confirmFlash = Duration(milliseconds: 220);
  /// Mantener pulsado para confirmar acciones de reloj irreversibles (fin de parte).
  static const Duration holdToConfirm = Duration(milliseconds: 900);
  /// Ventana para valorar (✓/✗) o deshacer la última marca (usecases: undoLastIncident 10 s).
  static const Duration refineWindow = Duration(seconds: 10);
  static const Duration sheet = Duration(milliseconds: 200);
}

/// Escala tipográfica. Fuente del sistema (Roboto en Android): no depende de red ni de assets,
/// coherente con offline-first. Cifras tabulares en todo lo que es tiempo.
abstract final class RefType {
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static const TextStyle clock = TextStyle(fontSize: 64, height: 1.0, fontWeight: FontWeight.w800, fontFeatures: tabular, letterSpacing: -1);
  static const TextStyle clockCompact = TextStyle(fontSize: 44, height: 1.0, fontWeight: FontWeight.w800, fontFeatures: tabular);
  static const TextStyle status = TextStyle(fontSize: 16, height: 1.25, fontWeight: FontWeight.w800, letterSpacing: 0.8);
  static const TextStyle tile = TextStyle(fontSize: 20, height: 1.15, fontWeight: FontWeight.w800);
  static const TextStyle control = TextStyle(fontSize: 18, height: 1.2, fontWeight: FontWeight.w800, letterSpacing: 0.3);
  static const TextStyle body = TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500);
  static const TextStyle caption = TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600, fontFeatures: tabular);
}

/// Colores de las tarjetas disciplinarias: son el objeto real (amarilla, roja), no un estado de
/// la interfaz. Siempre van con borde oscuro y con su nombre en texto o en la etiqueta accesible.
abstract final class RefCardColors {
  static const Color yellow = Color(0xFFFACC15);
  static const Color red = Color(0xFFDC2626);
  static const Color border = Color(0xFF0F172A);
}
