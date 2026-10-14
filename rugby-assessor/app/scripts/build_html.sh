#!/usr/bin/env bash
# Genera la versión HTML de pruebas de RefAssess: UN archivo que se abre en cualquier navegador
# (Chrome, Safari, Firefox; móvil u ordenador), sin servidor y sin conexión.
#
# Uso:  rugby-assessor/app/scripts/build_html.sh
# Salida: rugby-assessor/app/build/html/RefAssess-<versión>-pruebas.html
#
# Es la misma app (mismo código Dart) compilada para web. Diferencias con el APK:
#  · los datos se guardan en el navegador (IndexedDB), no en el móvil;
#  · el reloj usa la hora del sistema en lugar del reloj de arranque del dispositivo;
#  · "Compartir" descarga el PDF/JSON; no hay vibración.
# Sirve para probar cambios; para evaluar partidos reales, el APK.
set -euo pipefail
cd "$(dirname "$0")/.."
command -v flutter >/dev/null || { echo "No encuentro 'flutter' en el PATH." >&2; exit 1; }

flutter pub get >/dev/null
flutter build web --release --no-web-resources-cdn
VERSION=$(sed -n 's/^version: *\([0-9.]*\).*/\1/p' pubspec.yaml)
OUT="build/html/RefAssess-${VERSION}-pruebas.html"
python3 scripts/pack_single_html.py build/web "$OUT" "RefAssess ${VERSION} · pruebas"
echo "✔ HTML listo: $(pwd)/$OUT"
