# Pantalla 1: registro en directo con un tap

> **Estado:** v0.1 implementada en Flutter (`app/`).
> **Comprobado:**
> - `flutter analyze` sin incidencias.
> - 66 tests en verde: port del reloj (los mismos casos que en TypeScript), contraste de color, comportamiento de la pantalla y accesibilidad.
> - Capturas de referencia en `app/test/screenshots/goldens/`.
>
> **Marco de diseño:** UI-UX-Pro-Max (sistema de diseño generado con su buscador y checklist *Pre-Delivery* de `pro-rules.md`). Las desviaciones están justificadas en §2.

## 1. Arquitectura de vistas

```
app/lib/
  main.dart                          arranque (demo en memoria: DHCAT, Club Local RC – Visitante RT)
  core/
    design_system/tokens.dart        colores por rol (claro/oscuro), espaciado 8 dp, tamaños táctiles, tiempos, tipografía
    design_system/theme.dart         ThemeData + extensiones context.refColors / context.refText
    platform_ports.dart              SessionClock · IdGenerator (UUIDv7) · Haptics · ScreenAwake
  domain/                            port Dart de domain/*.ts (puro, sin Flutter)
    clock.dart  model.dart  category_presets.dart
  data/live_session_repository.dart  puerto de persistencia + implementación en memoria
  features/live/
    live_controller.dart             estado de la pantalla (ChangeNotifier) y cola de escritura ordenada
    live_screen.dart                 composición, estados de carga/error, salida protegida, horizontal
    live_labels.dart                 textos y disposición de la rejilla
    widgets/
      match_clock_header.dart        reloj (repinta solo su texto), estado, aviso, acción de reloj
      tag_grid.dart                  rejilla 4 × 3 + hoja "Más…" con el minuto congelado
      tag_tile.dart                  tesela: instante en el primer contacto, estado pulsado inmediato
      refine_strip.dart              tira fija: pista vacía · ✓/✗/Deshacer 10 s · resumen
      clock_menu_sheet.dart          ajuste ±10 s/±1 min, fin de periodo, deshacer evento de reloj
      hold_to_confirm_button.dart    mantener 0,9 s para acciones irreversibles
```

**Flujo de dependencias:** `LiveScreen` → `LiveController` → (`domain/clock.dart`, `LiveSessionRepository`, puertos).

- La UI no conoce la base de datos. La capa Drift implementará `LiveSessionRepository` y la UI no cambiará.
- No se usa ningún paquete de gestión de estado: basta con `ChangeNotifier` + `ListenableBuilder`, y así hay menos dependencias que mantener.

### Distribución (vertical, uso con una mano)

```
┌───────────────────────────────────────┐
│ Club Local RC – Visitante RT     [⚙]  │  ← opciones del reloj (lejos del pulgar a propósito)
│ 1ª PARTE · EN JUEGO     ┌──────────┐  │
│ 25:03                   │ ‖ Parar  │  │  ← una sola acción de reloj, según el estado
│                         └──────────┘  │
│ [⏱ Tiempo cumplido +01:07]            │  ← aviso; su altura está siempre reservada
│ 5 marcas · 5 por revisar              │
├───────────────────────────────────────┤
│ Ensayo     │ Avant/pase │ Más…        │  ← lo menos frecuente, arriba
│ Ventaja    │ J. desleal │ Tarjeta     │
│ Scrum      │ Touch      │ Maul        │
│ Placaje    │ Ruck       │ Fuera juego │  ← lo más frecuente, en la zona del pulgar
├───────────────────────────────────────┤
│ Marcado: Ruck · 25:01      Por revisar│  ← tira de altura fija (120 dp)
│ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬░░░░░ (cuenta atrás 10 s)│
│ [✓ Bien]   [✗ Error]   [↶ Deshacer]   │
└───────────────────────────────────────┘
```

En horizontal, la cabecera y la tira van a una columna izquierda (2/5) y la rejilla ocupa la derecha (3/5).

## 2. Sistema de diseño (UI-UX-Pro-Max)

| Decisión | Valor | Origen |
|---|---|---|
| Estilo | *Minimalism & Swiss*: alto contraste, sin decoración, jerarquía por tamaño y peso | `--design-system "field data capture utility app sunlight"`. El primer intento ("sports officiating…") devolvió un estilo *Vibrant & Block-based* de marketing con rojo como color primario; lo descarté porque el rojo debe significar "error". |
| Paleta | Roles semánticos en `RefColors`: primario azul, ✓ verde, ✗ rojo, revisar ámbar, aviso. Tema **claro de referencia para sol directo** y tema oscuro para partidos con focos. | Base de la skill (azul de confianza `#2563EB`), **oscurecida a AAA**: `#1E40AF`, `#166534`, `#991B1B`, `#92400E`. |
| Contraste | **Todo el texto ≥ 7:1 (AAA) en ambos temas**; bordes y estados ≥ 3:1 | La skill pide 4,5:1. Subo a 7:1 por la lectura a pleno sol. Lo comprueba `test/design_system/contrast_test.dart`. |
| Tipografía | Fuente del sistema (Roboto en Android) en pesos 500–800; cifras tabulares en el reloj y los minutos | La skill propone Outfit/Work Sans, pero cargarlas de Google Fonts en ejecución rompe el funcionamiento sin conexión. Se pueden empaquetar como asset más adelante sin tocar los tokens. |
| Tamaños táctiles | Mínimo 48 dp (Material). Controles de 64 dp, teselas ≥ 88 dp, 8–10 dp entre objetivos | Skill: `touch-target-size`, `touch-spacing`. Los subo por dedos fríos o mojados y por tocar sin mirar. Lo comprueban `androidTapTargetGuideline` y un test de alto ≥ 88 dp. |
| Espaciado | Ritmo de 4/8 dp (`RefSpace`) | `pro-rules`: *8dp spacing rhythm* |
| Movimiento | Estado pulsado **en el mismo frame** (0 ms), destello de confirmación de 220 ms y progreso de "mantener" de 900 ms. Sin animaciones decorativas. | Dial de movimiento 2/10 (sutil). El progreso es información, no decoración, así que se muestra también con movimiento reducido. |
| Iconos | Material Icons redondeados, una sola familia, nunca emoji; los decorativos quedan excluidos de la semántica | `pro-rules`: *No Emoji*, *Contextual Semantics* |

## 3. Interacción

| Situación | Comportamiento | Por qué |
|---|---|---|
| **Tap en una tesela** | El **instante se captura en el primer contacto** (`onTapDown`) y la marca se confirma al levantar el dedo. Si el dedo se desliza fuera, no se registra. | El minuto es el del hecho, no el del gesto. Probado: un dedo que tarda 1,5 s en levantarse sigue marcando el instante del contacto. |
| Respuesta | Mismo frame: color pulsado → háptica media + destello del borde + la tira muestra "Marcado: Ruck · 25:01" y el contador sube. La escritura en disco va después, en cola. | Respuesta percibida por debajo de 50 ms: no depende de que termine la escritura. |
| Valoración rápida | Opcional, durante 10 s: **✓ Bien** (acierto), **✗ Error** (pendiente de clasificar) o **Deshacer**. Si no se toca nada, la marca queda "Por revisar". | Cumple "en directo solo se captura" (spec §2.2) sin obligar a mirar. |
| Deshacer | VOID lógico: la marca nunca se borra. Háptica ligera. | Spec §1.3. Deshacer es reversible, así que no pide confirmación. |
| "Más…" | Abre una hoja con 7 categorías poco frecuentes. **El minuto queda congelado** en el tap de "Más…" y el título lo muestra ("Marcar a las 64:00"). Tiene botón Cancelar. | Elegir sin prisa no desplaza la marca. |
| Reloj | Un único botón según el estado: Iniciar 1ª parte → Parar tiempo → Reanudar → … → Ir a revisión. Háptica fuerte, distinta de la de las marcas. | Una sola decisión a la vista. |
| Fin de periodo | En el menú del reloj, **mantener pulsado 0,9 s**. Un toque corto no hace nada. | Es irreversible en la práctica. Mantener sustituye a un diálogo y no obliga a leer. |
| Ajuste | Botones de −1:00, −0:10, +0:10 y +1:00 para cuadrar con el reloj oficial (evento ADJUST). | Spec §2.1 |
| Avisos | Tiempo cumplido (+mm:ss), tiempo parado (y cuántas veces) y reloj sin verificar (tocar para ajustar). Siempre con **icono + texto**, nunca solo color. Su altura está reservada, así que no hay saltos de layout. | `color-not-only`; *reserve space* |
| Salir | Si el reloj está en marcha, pide confirmación ("El reloj sigue contando…"). | Evita salir por accidente con el botón atrás. |
| Pantalla | Se mantiene encendida durante el directo (`wakelock_plus`). | Uso en la banda. |

### Hápticas con significado

| Evento | Patrón |
|---|---|
| Marca registrada | `mediumImpact` |
| Valoración ✓/✗ | `selectionClick` |
| Deshacer | `lightImpact` |
| Cambio de reloj | `heavyImpact` |
| Fallo de guardado o acción no permitida | `vibrate` |

Así se distinguen sin mirar. La skill pide no abusar de la háptica; aquí cada patrón confirma una acción importante, como pediste.

## 4. Estados de la pantalla

| Estado | Qué se ve |
|---|---|
| Cargando | Indicador + "Recuperando el partido…" |
| Error de carga | Icono, "No se ha podido abrir el partido", tranquilizador ("tus marcas no se han perdido") y Reintentar (64 dp) |
| Vacío (sin marcas) | Pista en la tira: "Toca una acción para marcarla con el minuto. La valorarás con calma después del partido." Contador: "Sin marcas todavía". |
| Fallo de guardado | Banda roja: "No se ha podido guardar (n pendientes). Siguen en el móvil." + **Reintentar**. La captura **no se bloquea**: las marcas siguen visibles y en cola, y se escriben en orden al reintentar. |
| Partido recuperado | Al reabrir, el reloj se reconstruye desde el registro de eventos y sigue exacto (probado: 25:00 tras reabrir). |

## 5. Checklist Pre-Delivery (pro-rules.md)

| Punto | Resultado |
|---|---|
| Objetivos ≥ 48 dp y etiquetados | ✅ `androidTapTargetGuideline` + `labeledTapTargetGuideline`, en tema claro y oscuro |
| Contraste de texto | ✅ `textContrastGuideline` en ambos temas + test propio de AAA (≥ 7:1) |
| Color no es el único indicador | ✅ ✓/✗ con icono y texto; la opción elegida lleva borde grueso e icono de selección |
| Estado pulsado sin cambio de geometría | ✅ grosor de borde fijo (3 dp); solo cambia el color |
| Tamaño de texto dinámico | ✅ sin desbordes con texto ×1,6 en 360×640, 844×390 (horizontal) y 800×1280 (tableta). Las líneas de una fila se reducen en lugar de empujar la rejilla. |
| Zonas seguras | ✅ `SafeArea` + hojas con `useSafeArea` |
| Lector de pantalla | ✅ teselas con etiqueta, nº de marcas y pista; reloj y avisos como regiones vivas; doble toque confirma "mantener" |
| Tema oscuro comprobado por separado | ✅ tests de contraste y guías en ambos temas; capturas `*_dark.png` |
| Movimiento reducido | ✅ no hay animaciones decorativas; el único progreso es informativo |

## 6. Persistencia en campo real (Drift + reloj tolerante a reinicios)

### 6.1 Base de datos

| Pieza | Implementación |
|---|---|
| Esquema | `lib/data/db/schema.drift` es una **copia literal** de `persistence/schema.sql` v2, con las mismas tablas, CHECK y triggers. Un test compara las dos sentencia a sentencia. La única diferencia es el nombre Dart de una columna `text`. |
| Conexión | `AppDatabase.onDevice()` (`drift_flutter`): SQLite empaquetado y consultas en un *isolate* de fondo, así que una escritura nunca retrasa un frame. |
| Durabilidad | Al abrir se fijan `foreign_keys=ON`, `journal_mode=WAL` y **`synchronous=FULL`** (comprobado por test). |
| Taps | **Una transacción por tap**, en orden estricto a través de la cola del controlador. Cuando el `Future` completa, el dato está en disco. Medido en el anfitrión de pruebas: 40 taps confirmados en unos 50 ms (≈ 1,2 ms por tap). |
| Reloj | `appendClockEvent` inserta el evento (con `boot_id`, `mono_ms` y hora de pared para auditar) y actualiza `assessment.status` (READY → LIVE → POST_MATCH) **en la misma transacción**. |
| Segundo plano | `AppLifecycleListener` vacía la cola al ocultarse o pausarse la app (llamada, bloqueo, cambio de app). |
| Reglas en la base de datos | Probadas contra el archivo real: log de reloj append-only, claves foráneas, enumerados por CHECK, auditoría de cada edición en `incident_revision`. |

### 6.2 Reloj de sesión (`lib/data/session_time.dart`)

| Situación | Resultado |
|---|---|
| **El sistema mata la app** (o el evaluador la cierra) | Mismo arranque del móvil, así que se reutiliza la misma ancla y el reloj vuelve **exacto**. Test: tras 7 min con la app muerta, el reloj marca 22:00 y las marcas conservan sus minutos. |
| **Reinicio del móvil** | Se crea un ancla nueva, estimada con la hora de pared desde el último instante guardado. Si el reloj de partido estaba en marcha, se registra `INTEGRITY_LOST`, la cabecera muestra "Reloj sin verificar" y las marcas se guardan como DEGRADED hasta un ajuste. Test: 20:00 + 4 min de reinicio da 24:00 estimado; ajuste −0:10 da 23:50 y el reloj vuelve a OK. |
| Reinicio en el descanso o con el tiempo parado | No hay tiempo de juego corriendo, así que no se marca la integridad. |
| Hora del sistema atrasada | El eje de sesión **nunca retrocede** (el hueco se acota a 0). |

- **Fuente monotónica por FFI** (síncrona, válida en cada frame):
  - Android: `clock_gettime(CLOCK_BOOTTIME)`, equivalente a `SystemClock.elapsedRealtime()`: sigue contando con el móvil en reposo.
  - iOS: `CLOCK_MONOTONIC`, que en Darwin también avanza en reposo.
- **Identificador de arranque:**
  - En Android se lee de `/proc/sys/kernel/random/boot_id`.
  - Si no se puede leer, se usa una aproximación (instante de arranque en hora de pared, con ±2 min de tolerancia).
  - Además, si la fuente retrocede, se trata como reinicio aunque el id coincida.

> **v1.1:** la cabecera incluye el **marcador** y el **contador de sanciones**, y la tira de valoración un botón **Ley**.
> **v1.1.2:** el icono de arriba a la derecha abre el **menú del partido**: «Salir al menú principal» (sin parar el reloj) y las opciones del reloj.
> **v1.1.1:** las sanciones son marcas valorables. **Editar** (en la tira) y el **icono de lista** permiten revisar y editar marcas durante el partido. Ver [MARCADOR_SANCIONES_LEYES.md](MARCADOR_SANCIONES_LEYES.md).

## 7. Pendiente

1. **Probar en un dispositivo Android e iOS reales** (protocolo en [PRUEBAS_DE_CAMPO.md](PRUEBAS_DE_CAMPO.md)). En este entorno no hay SDK de Android ni de iOS: lo comprobado es el análisis estático, los tests en el anfitrión (Linux, con la misma FFI `CLOCK_BOOTTIME`) y las capturas. Hay que confirmar en móvil que `/proc/.../boot_id` se puede leer (si no, entra la aproximación) y probar a pleno sol y con guantes.
2. **Nota de voz** (mantener pulsado → adjuntar a la última marca): backlog v1.2, ver [PRUEBAS_DE_CAMPO.md](PRUEBAS_DE_CAMPO.md#3-backlog-v12).
3. ~~Pantalla de preparación del partido.~~ Hecha: ver [UI_SETUP_E_INICIO.md](UI_SETUP_E_INICIO.md). La app arranca en la lista de partidos.
