# RefAssess · Evaluación de árbitros de rugby

App móvil, sin conexión, para que un evaluador valore al **árbitro principal** de un partido de rugby (XV y 7s):
- **Captura en directo** de un toque por incidencia, con **marcador**, **contador de sanciones** (GC, GF y tarjetas por equipo) y la **ley** de cada acción.
- **Revisión** después del partido.
- **Evaluación por bandas cualitativas**: Por debajo, En el nivel o Por encima del nivel, sin notas numéricas visibles.
- **Informe firmado** (SHA-256) que se exporta en PDF y JSON.

**Estado:** versión **1.1.3** (marcador, sanciones valorables como marcas, leyes y edición durante el partido, sobre el MVP 1.0 de pruebas de campo). Ver [docs/MARCADOR_SANCIONES_LEYES.md](docs/MARCADOR_SANCIONES_LEYES.md) y [docs/PRUEBAS_DE_CAMPO.md](docs/PRUEBAS_DE_CAMPO.md).

## Estructura

| Ruta | Contenido |
|---|---|
| `app/` | App Flutter + Drift (paquete `ref_assess`, Android `com.refassess.ref_assess`). |
| `app/lib/` | Código: `app/` (arranque y navegación), `features/` (inicio, preparación, directo, revisión, evaluación), `domain/` (reloj, puntuación, rúbrica), `data/` (SQLite), `export/` (JSON y PDF). |
| `app/test/` | Tests de Flutter (dominio, datos, pantallas, flujo completo, exportación, capturas en `test/screenshots/goldens/`). |
| `app/scripts/build_html.sh` | **Versión HTML de pruebas**: la misma app en un único archivo que se abre en el navegador, sin servidor. Es lo que se entrega tras cada cambio. |
| `app/scripts/build_apk.sh` | **Compilar el APK** (debug o release, con instalación opcional por adb), solo cuando se pida. |
| `docs/` | Especificación, una guía por pantalla, exportación y prueba de campo. |
| `domain/`, `test/` | Especificación ejecutable en TypeScript (modelo, reloj, puntuación, rúbrica) y sus tests. |
| `persistence/schema.sql` | Esquema SQLite de referencia (v4), del que se copia `app/lib/data/db/schema.drift`. |
| `export/` | Esquema JSON del informe (2.1), ejemplo y muestras reales en `export/samples/`. |
| `scripts/` | Generación de `rubric_default.dart` a partir de la rúbrica TypeScript. |

## Documentación

1. [Especificación](docs/ESPECIFICACION_EVALUADOR_ARBITRAL.md): modelo, reloj, puntuación, persistencia y decisiones R1–R6.
2. [Inicio y preparación del partido](docs/UI_SETUP_E_INICIO.md): incluye cómo compilar el APK.
3. [Pantalla 1 · Directo](docs/UI_PANTALLA_1_DIRECTO.md)
4. [Pantalla 2 · Revisión](docs/UI_PANTALLA_2_REVISION.md)
5. [Pantalla 3 · Evaluación](docs/UI_PANTALLA_3_EVALUACION.md)
6. [Exportación JSON/PDF](docs/EXPORTACION.md)
7. [Marcador, sanciones y leyes](docs/MARCADOR_SANCIONES_LEYES.md)
8. [Prueba de campo y backlog v1.2](docs/PRUEBAS_DE_CAMPO.md)

## Comandos

```bash
# App (Flutter 3.47+)
cd app
flutter pub get
flutter analyze && flutter test
./scripts/build_html.sh                    # HTML de pruebas → build/html/RefAssess-<versión>-pruebas.html
./scripts/build_apk.sh release --install   # APK (requiere Android SDK y JDK 17+)

# Especificación TypeScript
npm test
```

## Versión HTML de pruebas

`app/scripts/build_html.sh` compila la app para web y la empaqueta en **un único HTML** de unos 7 MB:
- **Qué lleva dentro:** el código, el motor gráfico, SQLite en WebAssembly y las fuentes, comprimidos (`app/scripts/pack_single_html.py`).
- **Cómo se usa:** se abre con doble clic o desde el móvil (Chrome, Safari, Firefox), sin servidor y sin conexión.
- **Lo que comparte con el APK:** es el mismo código Dart, con las mismas pantallas, reglas y base de datos.
- **Diferencias con el APK:**
  - los datos se guardan en el navegador;
  - el reloj usa la hora del sistema en lugar del reloj de arranque del dispositivo;
  - «Compartir» descarga el PDF/JSON;
  - no hay vibración.
- **Uso previsto:** probar cambios, no evaluar partidos reales.

Privacidad: todos los datos se guardan solo en el dispositivo del evaluador y salen de él únicamente cuando se comparte un informe.
