# Instrucciones del proyecto

El proyecto es RefAssess, una app Flutter de evaluación de árbitros de rugby. Está en `rugby-assessor/` (ver `rugby-assessor/README.md`).

## Entrega de cada modificación

- **Tras cada cambio en la app, entregar un HTML de pruebas, no un APK.** Se genera con `rugby-assessor/app/scripts/build_html.sh` y se envía al usuario el archivo `build/html/RefAssess-<versión>-pruebas.html`.
  - Es un único archivo que se abre en el navegador, sin servidor.
  - Antes de enviarlo, comprobar que arranca (por ejemplo, abrirlo con Playwright y Chromium desde `file://`).
- **No compilar el APK** (`scripts/build_apk.sh`) salvo que el usuario lo pida expresamente: los cambios pueden no ser definitivos y compilarlo es perder tiempo.
- **Antes de entregar:**
  - `flutter analyze` sin incidencias;
  - `flutter test` en verde;
  - `npm test` en `rugby-assessor/`;
  - commit y push a la rama de trabajo.
- **Idioma:** español, para el usuario y para la documentación del proyecto.
