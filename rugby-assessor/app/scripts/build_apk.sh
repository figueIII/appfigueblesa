#!/usr/bin/env bash
# Compila el APK de RefAssess para probarlo en un Android físico.
#
# Uso (desde cualquier carpeta):
#   rugby-assessor/app/scripts/build_apk.sh            # APK debug (por defecto)
#   rugby-assessor/app/scripts/build_apk.sh release    # APK release (firmado con la clave debug)
#   rugby-assessor/app/scripts/build_apk.sh debug --install   # además lo instala por adb
#   SKIP_TESTS=1 rugby-assessor/app/scripts/build_apk.sh      # sin pasar antes los tests
#
# Requisitos: Flutter 3.47+ en el PATH, Android SDK (platform-tools y build-tools; lo instala
# Android Studio) y JDK 17 o posterior. Comprueba el entorno con `flutter doctor`.
set -euo pipefail

MODE="${1:-debug}"
INSTALL="${2:-}"
case "$MODE" in
  debug|release) ;;
  *) echo "Modo no válido: '$MODE' (usa debug o release)" >&2; exit 2 ;;
esac

cd "$(dirname "$0")/.."

command -v flutter >/dev/null || { echo "No encuentro 'flutter' en el PATH." >&2; exit 1; }

echo "▸ Dependencias"
flutter pub get

if [[ "${SKIP_TESTS:-0}" != "1" ]]; then
  echo "▸ Análisis estático y tests"
  flutter analyze
  flutter test
fi

echo "▸ Compilando APK ($MODE)"
flutter build apk "--$MODE"

APK="build/app/outputs/flutter-apk/app-$MODE.apk"
[[ -f "$APK" ]] || { echo "No se generó $APK" >&2; exit 1; }
echo
echo "✔ APK listo: $(pwd)/$APK ($(du -h "$APK" | cut -f1))"

if [[ "$INSTALL" == "--install" ]]; then
  command -v adb >/dev/null || { echo "No encuentro 'adb' (Android SDK platform-tools)." >&2; exit 1; }
  echo "▸ Instalando en el dispositivo conectado"
  adb install -r "$APK"
else
  echo "Para instalarlo con el móvil conectado por USB (depuración USB activada):"
  echo "  adb install -r \"$(pwd)/$APK\""
  echo "o copia el archivo al móvil y ábrelo (permite instalar apps de origen desconocido)."
fi
