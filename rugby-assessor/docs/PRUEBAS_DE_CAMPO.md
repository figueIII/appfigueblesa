# Prueba de campo y backlog v1.2

> **Estado:** versión **1.1.2** para pruebas de campo: el MVP 1.0 más marcador, sanciones y leyes ([MARCADOR_SANCIONES_LEYES.md](MARCADOR_SANCIONES_LEYES.md)). El APK 1.1 se instala encima del 1.0 y conserva los partidos guardados.

## 1. Antes del partido

1. Compila e instala el APK: `rugby-assessor/app/scripts/build_apk.sh release --install`. Los detalles están en [UI_SETUP_E_INICIO.md §4](UI_SETUP_E_INICIO.md#4-compilar-e-instalar-el-apk).
2. Haz un partido de ensayo en casa:
   1. Nuevo partido → Comenzar → inicio de la 1ª parte.
   2. Pon unas marcas y bloquea el móvil 5 minutos.
   3. Desbloquea: el reloj debe haber seguido corriendo.
   4. Final → revisión → evaluación → cerrar → Compartir PDF.
3. Carga la batería y desactiva el ahorro de energía agresivo para RefAssess si el fabricante lo aplica (Xiaomi, Huawei, Samsung…).

## 2. Qué comprobar en la banda

| # | Prueba | Cómo | Resultado esperado |
|---|---|---|---|
| 1 | Reloj bajo reposo | Bloquear la pantalla 2–3 min con el reloj en marcha y volver. | El reloj marca el tiempo real transcurrido, sin saltos ni aviso de integridad. |
| 2 | Cierre forzado | Quitar la app de recientes durante el juego y volver a abrirla → En curso → Continuar. | Mismo tiempo y mismas marcas; ninguna marca perdida. |
| 3 | Reinicio del móvil (opcional) | Apagar y encender con el reloj en marcha. | El reloj se estima y aparece el aviso de integridad. Es el comportamiento previsto. |
| 4 | Respuesta háptica | Marcar, valorar ✓/✗, deshacer y pausar el reloj. | Una vibración distinta por acción; la respuesta se percibe inmediata. |
| 5 | Luz solar | Usar el tema claro a pleno sol, con brillo automático. | Reloj, teselas y estados legibles sin buscar sombra. |
| 6 | Una mano | Marcar con el pulgar y el móvil en una mano, con guantes si hace frío. | Sin toques errados entre teselas vecinas. |
| 7 | Pantalla encendida | Dejar el directo abierto sin tocar 5 min. | La pantalla no se apaga en el directo y sí fuera de él. |
| 8 | Exportación | En el informe cerrado: Compartir PDF, luego PDF + JSON por WhatsApp, Telegram o correo. | Llegan los archivos. El PDF abre en el móvil del receptor y el texto incluye la huella SHA-256. |
| 9 | Seguimiento | Segundo partido del mismo árbitro (escrito con otra mayúscula o sin tilde). | La evaluación muestra la recomendación del informe anterior. |
| 10 | Marcador | Anotar ensayo + transformación, golpe a palos y drop de ambos equipos; deshacer uno. | El marcador de la cabecera coincide con el real y el resultado aparece en el PDF sin teclearlo. |
| 11 | Sanciones | Registrar cada GC/GF con su motivo durante una parte y valorarlo en la tira (Bien / Error); probar "Sin especificar" y completarlo en el descanso. | El contador por equipo cuadra con lo pitado, cada sanción aparece en la revisión con su valoración y el desglose ("3× Fuera de juego…") es legible a pleno sol. |
| 14 | Salir y volver | Con el reloj en marcha, menú del partido → «Salir al menú principal»; volver desde «En curso». | Sale sin preguntar; al volver, el reloj ha seguido contando. |
| 13 | Editar en directo | Con el reloj en marcha, pulsar **Editar** en la última marca y completarla; abrir la lista de marcas (icono de lista). | Se guarda sin parar el reloj y se vuelve al directo; la insignia de la lista baja. |
| 12 | Ley de una marca | Tras marcar un ruck, pulsar **Ley** y elegir la infracción antes de que pasen los 10 s (y una vez después). | La ley queda en la marca y se ve en la cola de revisión. |

**Anota por cada fallo:** número de prueba, modelo de móvil y versión de Android, minuto del partido y qué se veía (una captura si es posible).

## 3. Backlog v1.2

La versión 1.1 la ocupa el marcador con sanciones y leyes; estos tres puntos siguen pendientes, con el mismo orden:

| Prioridad | Función | Punto de partida |
|---|---|---|
| 1 | **Enmiendas de informes cerrados** (versión 2 o posterior, con motivo). | El esquema y la base de datos ya admiten versiones (clave `report(assessment_id, version)` en SQLite y `supersedesVersion` en el esquema JSON), y el pie del PDF muestra el número. Las enmiendas no reabren las incidencias del directo: solo cambian textos, notas y justificaciones. |
| 2 | **Notas de voz en directo** (mantener pulsado → adjuntar a la última marca). | Tabla `attachment` y escritura atómica de la especificación §3.1. Encaja como acción secundaria en la hoja *Más*. |
| 3 | **Ajuste fino del minuto** de una incidencia desde el editor. | `matchClockOverrideMs` en `domain/usecases.ts` y la columna `incident.time_manual_override` (especificación §2.1). El minuto original se conserva y el trigger `incident_audit` registra el cambio. |

Otras posibles mejoras, sin prioridad asignada:
- Archivar o borrar partidos desde la lista.
- Historial por árbitro.
- Política de conservación de datos (Q6 de la especificación, antes de publicar en Google Play).
