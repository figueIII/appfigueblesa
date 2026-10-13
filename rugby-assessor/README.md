# RefAssess · Evaluación de árbitros de rugby

App móvil, sin conexión, para que un evaluador valore al **árbitro principal** de un partido de rugby (XV y 7s):
- **Captura en directo** de un toque por incidencia.
- **Revisión** después del partido.
- **Evaluación por bandas cualitativas**: Por debajo, En el nivel o Por encima del nivel, sin notas numéricas visibles.
- **Informe firmado** (SHA-256) que se exporta en PDF y JSON.

**Estado:** MVP **1.0** congelado para pruebas de campo. Ver [docs/PRUEBAS_DE_CAMPO.md](docs/PRUEBAS_DE_CAMPO.md).

## Estructura

| Ruta | Contenido |
|---|---|
| `app/` | App Flutter + Drift (paquete `ref_assess`, Android `com.refassess.ref_assess`). |
| `app/lib/` | Código: `app/` (arranque y navegación), `features/` (inicio, preparación, directo, revisión, evaluación), `domain/` (reloj, puntuación, rúbrica), `data/` (SQLite), `export/` (JSON y PDF). |
| `app/test/` | Tests de Flutter (dominio, datos, pantallas, flujo completo, exportación, capturas en `test/screenshots/goldens/`). |
| `app/scripts/build_apk.sh` | **Compilar el APK** (debug o release, con instalación opcional por adb). |
| `docs/` | Especificación, una guía por pantalla, exportación y prueba de campo. |
| `domain/`, `test/` | Especificación ejecutable en TypeScript (modelo, reloj, puntuación, rúbrica) y sus tests. |
| `persistence/schema.sql` | Esquema SQLite de referencia (v2), del que se copia `app/lib/data/db/schema.drift`. |
| `export/` | Esquema JSON del informe (2.0), ejemplo y muestras reales en `export/samples/`. |
| `scripts/` | Generación de `rubric_default.dart` a partir de la rúbrica TypeScript. |

## Documentación

1. [Especificación](docs/ESPECIFICACION_EVALUADOR_ARBITRAL.md): modelo, reloj, puntuación, persistencia y decisiones R1–R6.
2. [Inicio y preparación del partido](docs/UI_SETUP_E_INICIO.md): incluye cómo compilar el APK.
3. [Pantalla 1 · Directo](docs/UI_PANTALLA_1_DIRECTO.md)
4. [Pantalla 2 · Revisión](docs/UI_PANTALLA_2_REVISION.md)
5. [Pantalla 3 · Evaluación](docs/UI_PANTALLA_3_EVALUACION.md)
6. [Exportación JSON/PDF](docs/EXPORTACION.md)
7. [Prueba de campo y backlog v1.1](docs/PRUEBAS_DE_CAMPO.md)

## Comandos

```bash
# App (Flutter 3.47+)
cd app
flutter pub get
flutter analyze && flutter test
./scripts/build_apk.sh release --install   # requiere Android SDK y JDK 17+

# Especificación TypeScript
npm test
```

Privacidad: todos los datos se guardan solo en el dispositivo del evaluador y salen de él únicamente cuando se comparte un informe.
