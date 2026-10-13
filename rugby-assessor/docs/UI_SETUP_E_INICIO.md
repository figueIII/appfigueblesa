# Inicio, preparación del partido y APK de pruebas

> **Estado:** v0.1 implementada.
> - Pantalla de inicio: `app/lib/features/home/`.
> - Preparación del partido: `app/lib/features/setup/`.
> - Navegación: `app/lib/app/`.
> - Script del APK: `app/scripts/build_apk.sh`.
>
> **Comprobado:** `flutter analyze` sin incidencias y 199 tests en verde (1 omitido); los tests de TypeScript siguen en verde.
> **No comprobado aquí:** la compilación del APK. Este entorno no tiene Android SDK y la política de red bloquea `dl.google.com`.

## 1. Flujo

```
Inicio (lista) ──"Nuevo partido"──► Preparación ──"Comenzar partido"──► Directo (ANTES DEL INICIO · 00:00)
   │                                    (se crea el registro en Drift;      │
   │                                     el directo SUSTITUYE a la           ▼
   │                                     preparación: atrás → inicio)     Revisión → Evaluación
   ├─ En curso (READY/LIVE)         ──► Directo, con el reloj recuperado
   ├─ Pendientes de revisión        ──► Revisión → Evaluación
   └─ Finalizados (banda del informe) ─► Evaluación en solo lectura → Exportar PDF/JSON
```

- **Arranque:** la app abre en la lista de partidos y ya no crea un partido de ejemplo.
- **Recarga:** al volver de cualquier pantalla, la lista se recarga para reflejar estado, marcas y banda.
- **Partido nuevo:** el reloj **no** arranca solo. El partido queda en `READY`, sin eventos de reloj, hasta que el evaluador pulsa el inicio de la 1ª parte.

## 2. Preparación del partido

El formulario sigue el orden en que se conoce la información en el campo:

| Bloque | Campos | Notas |
|---|---|---|
| Categoría (obligatoria) | Los 8 presets R6 | Cada opción muestra "2 × N min · sin-bin M min". Elegirla carga duración y sin-bin. |
| Equipos (obligatorios) | Local, visitante | No pueden coincidir (sin distinguir mayúsculas ni espacios). |
| Árbitros | Principal (obligatorio), asistentes 1 y 2 (opcionales) | Solo se evalúa al principal (R5). Los asistentes son contexto. |
| Evaluador (obligatorio) | Nombre | Se rellena con el del último partido. |
| Cuándo y dónde | Fecha, hora (24 h) y campo (obligatorios); competición y jornada (opcional) | Hora por defecto: la actual redondeada a los 5 min siguientes. Sin competición se usa el nombre de la categoría. |
| Dificultad | Baja, Media, Alta, Muy alta (opcional) | Solo descriptiva (R3). Al volver a pulsarla se desmarca. |

- **Autocompletado del árbitro y del evaluador** con los nombres ya usados.
- **Mismo árbitro entre partidos:** la base de datos reutiliza al árbitro aunque el nombre llegue con otras mayúsculas, tildes o espacios.
  - De ello depende el **seguimiento de recomendaciones** de un informe al siguiente.
  - Antes se creaba un árbitro nuevo en cada partido; está corregido en `AssessmentSetup`.
- **Validación:** solo al pulsar "Comenzar partido". El error aparece junto a cada campo, debajo se lee "Faltan N datos obligatorios" y la vista se desplaza al primer error. Los errores se corrigen mientras se escribe.
- **Al crear:** el botón muestra progreso y queda bloqueado, para evitar crear el partido dos veces. Si falla el guardado, se avisa y el botón vuelve a estar disponible.

## 3. Pantalla de inicio

- **Tres secciones**, que solo aparecen si tienen partidos:
  1. **En curso**
  2. **Pendientes de revisión**
  3. **Finalizados**
- **Tarjeta:** equipos, fecha y hora, categoría, árbitro y campo. Debajo, el estado ("En directo · 7 marcas", "Sin empezar", "Terminado · 14 marcas") o la **banda** del informe cerrado, sin cifras (R2). A la derecha, la acción: Empezar, Continuar, Revisar o Ver y exportar.
- **Botón "Nuevo partido"** fijo abajo (64 dp), al alcance del pulgar.
- **Estado vacío:** recuerda que los datos se guardan solo en el dispositivo.

## 4. Compilar e instalar el APK

Requisitos:
- Flutter 3.47 o posterior.
- Android SDK (con Android Studio) y JDK 17 o posterior.
- `flutter doctor` sin errores en la parte de Android.

```bash
cd rugby-assessor/app
./scripts/build_apk.sh                  # pub get + analyze + tests + APK debug
./scripts/build_apk.sh release          # APK release (firmado con la clave debug de la plantilla)
./scripts/build_apk.sh debug --install  # además: adb install -r en el móvil conectado
SKIP_TESTS=1 ./scripts/build_apk.sh     # sin análisis ni tests
```

- **Salida:** `build/app/outputs/flutter-apk/app-debug.apk` (o `app-release.apk`).
- **Instalar a mano:** `adb install -r <apk>` con la depuración USB activada, o copia el APK al móvil y ábrelo.
- **Nombre en el lanzador:** **RefAssess** (`com.refassess.ref_assess`).
- **Versión release:** es más fluida para probar el reloj y la respuesta táctil. Para publicarla hará falta una clave de firma propia.

## 5. Tests

| Archivo | Qué prueba |
|---|---|
| `test/domain/match_setup_test.dart` (5) | Validación: campos obligatorios en orden, espacios, mismo equipo y resumen de preset. |
| `test/data/match_repository_test.dart` (6) | Alta con preset y datos limpios; reutilización de árbitro y evaluador por nombre normalizado; último evaluador; etapas, marcas (sin anuladas), banda y orden del listado. |
| `test/features/setup/match_setup_screen_test.dart` (12) | Presets, hora por defecto, errores y contador, mismo equipo, alta completa con `onStart`, dificultad opcional, autocompletado, selector de hora, fallo de guardado, accesibilidad en claro y oscuro, y texto ×1.6. |
| `test/features/home/home_screen_test.dart` (8) | Estado vacío, secciones y orden, textos de estado y banda, apertura y recarga, accesibilidad, y texto ×1.6. |
| `test/app/app_flow_test.dart` (2) | **De extremo a extremo con Drift real:** inicio → preparación → "Comenzar partido" → directo en ANTES DEL INICIO y 00:00, sin eventos de reloj → atrás vuelve al inicio con el partido en curso → continuar. Además, un informe finalizado abre la evaluación con la sección de exportación. |
| `test/screenshots` | Capturas 30 a 33: inicio, preparación, errores e inicio vacío. |

## 6. Pendiente

- Compilar y probar el APK en un Android físico: hoja de compartir, reloj de arranque tras reiniciar, vibración y pantalla siempre encendida.
- Enmiendas de informes cerrados (aplazadas).
- Archivar o borrar partidos desde la lista (hoy no hay borrado: el historial es local y completo).
