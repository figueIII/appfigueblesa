import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildRefTheme(Brightness brightness) {
  final c = brightness == Brightness.light ? RefColors.light : RefColors.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    secondary: c.primary,
    onSecondary: c.onPrimary,
    error: c.negative,
    onError: c.onNegative,
    surface: c.background,
    onSurface: c.onSurface,
    outline: c.outline,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    extensions: [c],
    // Splash instantáneo y sin ondas largas: el estado pulsado lo pinta cada componente.
    splashFactory: NoSplash.splashFactory,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    textTheme: Typography.material2021(platform: TargetPlatform.android)
        .black
        .apply(bodyColor: c.onSurface, displayColor: c.onSurface),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.background,
      showDragHandle: true,
      dragHandleColor: c.outline,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.onSurface,
      contentTextStyle: RefType.body.copyWith(color: c.background),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

extension RefThemeX on BuildContext {
  RefColors get refColors => Theme.of(this).extension<RefColors>()!;
}

extension RefTextX on BuildContext {
  /// Estilo de token completado con la familia tipográfica del tema de la plataforma.
  /// Necesario en `ButtonStyle.textStyle`, que sustituye (no hereda) el estilo del tema.
  TextStyle refText(TextStyle token) => Theme.of(this).textTheme.bodyMedium!.merge(token);
}
