# Marcador, sanciones y leyes (v1.1)

> **Estado:** implementado en la app **1.1.0**, con base de datos **v3** y exportación **2.1**.
>
> **Comprobado:**
> - `flutter analyze` sin incidencias.
> - 245 tests de Flutter en verde (1 omitido). Antes eran 200; ninguno de los anteriores se ha tocado salvo para cubrir lo nuevo.
> - Los 22 tests de TypeScript siguen en verde.

## 1. Qué añade

| Requisito | En el directo | En la revisión | En el informe |
|---|---|---|---|
| **Marcador** | Arriba, "Local 12 – 7 Visitante". Un toque abre la hoja de anotación. | — | Resultado del partido (cabecera del PDF y `match.finalScore`), más el detalle en "Marcador y disciplina" y en `matchStats.score`. |
| **Sanciones** (GC, GF, amarillas, rojas) | Contador fijo bajo el reloj, por equipo. Un toque abre el panel con el desglose y el registro. | — | Tabla por equipo, golpes por motivo y lista de tarjetas en el PDF; `matchStats.sanctions` en el JSON. |
| **Ley o infracción** de cada acción | Botón **Ley** en la tira de valoración (junto a Bien / Error / Deshacer). | Campo **Ley / infracción** en el editor, también para las acciones correctas. La tarjeta de la cola lo muestra. | `incidents[].infraction` en el JSON y la ley en el anexo del PDF. |

## 2. Marcador

- **Tantos:** ensayo **+5**, transformación **+2**, golpe a palos **+3** y drop **+3**, en dos columnas (local y visitante) de botones de 64 dp.
- **Transformación:** solo se puede pulsar **justo después de un ensayo de ese equipo**. Ese botón se resalta en azul porque es lo siguiente que va a pasar.
  - Si la transformación se falla, no se anota nada: el siguiente tanto cierra la opción.
  - La regla vive en `conversionAvailable` (dominio puro) y la base de datos solo admite los puntos correctos de cada tanto.
- **La hoja queda abierta tras anotar**, para poder sumar la transformación sin volver a abrirla.
- **Deshacer** anula el último tanto e indica cuál ("Deshacer: Golpe a palos · Visitante RT · 15:00"). El tanto **no se borra**: queda anulado, como las marcas.
- **Guardado reactivo:** cada tanto se escribe en una transacción que también recalcula `assessment.final_score_home/away`.
  - Ese resultado es el que leen el informe y la exportación: no hay que teclearlo al final.
  - Si el guardado falla, el marcador en pantalla sigue al día y la escritura espera en la cola ordenada del directo, con el mismo aviso y «Reintentar» que las marcas.

## 3. Sanciones y desglose

- **Contador** (cabecera): columnas GC · GF · amarilla · roja, con una fila por equipo. Es una sola zona táctil con etiqueta accesible completa ("Club Local RC: 3 golpes de castigo, 1 golpe franco…").
- **Panel:**
  1. **Equipo infractor:** se elige con dos botones grandes que muestran cuántas sanciones lleva cada uno.
  2. **Recuento del equipo:** "GC 4 · GF 1 · TA 1 · TR 0".
  3. **Registro:** + Golpe de castigo, + Golpe franco, + Tarjeta amarilla, + Tarjeta roja. Cada uno abre el selector de leyes para el motivo.
     - El **minuto es el del toque**, aunque se tarde en elegir el motivo.
     - "**Sin especificar**" registra al momento y deja el motivo para después.
     - Cerrar el selector sin elegir **no registra nada**.
  4. **Golpes por motivo:** "3× Fuera de juego en ruck / maul · GC 2 · GF 1 · Leyes 15 y 16".
     - Orden: de más a menos frecuente; a igualdad, el que apareció antes. "Sin especificar" va siempre al final, con un botón **Completar**.
     - Las **tarjetas van aparte**, con minuto y motivo editable, porque suelen acompañar a un golpe por la misma acción y contarían dos veces.
  5. **Deshacer** la última sanción (también es una anulación, no un borrado).

## 4. Catálogo de leyes (`app/lib/domain/laws.dart`)

**23 infracciones en 6 grupos**, cada una con su término de World Rugby, su ley y la sanción habitual:

| Grupo | Infracciones |
|---|---|
| Ruck / suelo | No rodar / no apartarse (Ley 14) · No soltar el balón (Ley 14) · Entrada lateral (Ley 15) · Tirarse sobre el ruck / sellar (Ley 15) · Manos en el ruck (Ley 15) |
| Placaje | Placaje alto / contacto con la cabeza (Ley 9.13) · Placaje peligroso / volteo (Ley 9.18) · Placaje sin balón (Ley 9) · Placaje anticipado / tardío (Ley 9.13) |
| Fuera de juego | En ruck / maul (Leyes 15 y 16) · En juego abierto, 10 m tras patada (Ley 10) |
| Melé | Entrada antes de tiempo · Derrumbar · No empujar recto · Empuje prematuro (Ley 19) |
| Touch y maul | Saque no recto (Ley 18) · Derrumbar el maul (Ley 16) · Entrada antirreglamentaria (Ley 16) · Obstrucción / pantalla (Leyes 9 y 16) |
| Juego sucio y disciplina | Desobediencia / protestas · Lenguaje soez · Obstrucción intencionada · Retrasar el saque / perder tiempo (Ley 9) |

- **"Otra ley / infracción personalizada":** texto libre y ley opcional. Las personalizadas iguales (sin distinguir mayúsculas ni espacios) se agrupan en el desglose.
- **Cómo se citan las leyes:** se cita **el número de ley**, y el apartado solo donde es inequívoco (9.13 y 9.18). **Conviene revisar el catálogo contra el reglamento vigente de World Rugby** antes de usarlo como referencia oficial: es un selector rápido, no el reglamento.
- **Orden del selector:** primero los grupos probables para la categoría de la marca (en un ruck: Ruck y Fuera de juego), y después el resto.
- **Valoración:** la ley se asocia tanto a aciertos como a errores y **no cambia la valoración** de la marca.

## 5. Datos y migración

- **Esquema v3** (`persistence/schema.sql`, copiado literalmente en `schema.drift`):
  - Tablas **`score_event`** y **`sanction_event`**, de solo inserción.
    - Triggers: ni borrar, ni cambiar el tipo, el equipo o el minuto, ni reactivar lo anulado.
    - En las sanciones solo se puede completar el motivo.
    - Todo queda congelado con la evaluación finalizada.
  - Columnas `infraction_code / infraction_custom / infraction_law_ref` en `incident`; la auditoría (`incident_revision`) guarda la infracción anterior.
- **Migración v2 → v3 automática al abrir:** solo añade, así que los partidos del móvil de pruebas se conservan. La prueba un test que crea una base de datos v2 con el esquema de la versión 1.0.0, la abre con la app nueva y registra tantos y sanciones sobre un partido antiguo.
  - En una base migrada, la regla "CUSTOM exige texto" de `incident` la garantiza la app, no SQLite: un `ALTER TABLE` no puede añadir esa restricción de tabla.
- **Recuperación:** al reabrir el directo vuelven el marcador, la transformación pendiente y las sanciones. El reloj de sesión también tiene en cuenta los instantes de tantos y sanciones al recuperarse tras un reinicio.

## 6. Exportación 2.1

- **`formatVersion`** pasa a "2.1". El esquema acepta "2.0" y "2.1", y un documento 2.0 sigue siendo válido (hay un test).
- **`matchStats`:**
  - `score`: totales y tantos en orden.
  - `sanctions`: `totals`, `breakdown` y `events`.
  - Cada bloque **solo aparece si se registró algo**: un "0" sin registros afirmaría algo que el evaluador no anotó.
- **`incidents[].infraction`:** `{code, label, lawRef}`.
- **PDF:** sección **"Marcador y disciplina"** antes de la integridad (título y tabla nunca se separan entre páginas) y la ley de cada incidencia clave en el anexo.
- **El informe firmado no cambia:** marcador y sanciones son datos del partido y no entran en la huella. La muestra conserva la misma huella `46ab8bec…` que antes.

## 7. Tests nuevos

| Archivo | Qué prueba |
|---|---|
| `test/domain/match_facts_test.dart` (14) | Puntos; resultado sin anulados; transformación (solo tras ensayo del mismo equipo, fallada, deshecha); recuento; orden del desglose; tarjetas aparte; personalizadas agrupadas; catálogo completo por grupo; `InfractionRef`. |
| `test/data/match_facts_drift_test.dart` (6) | Resultado recalculado en la misma transacción; ida y vuelta de sanciones; infracción desde el directo y la revisión, con auditoría; triggers de solo inserción; bloqueo tras finalizar; **migración v2 → v3**. |
| `test/features/live/live_controller_facts_test.dart` (2) | Recuperación al reabrir; cola ordenada con fallo de guardado y reintento. |
| `test/features/live/match_facts_ui_test.dart` (13) | Hoja del marcador con transformación y deshacer; panel de sanciones con desglose; minuto del toque; cancelar; tarjetas y personalizada; completar motivo; deshacer; **Ley** en la tira; accesibilidad en claro y oscuro; texto ×1.6. |
| `test/features/review/review_screen_test.dart` (+2) | Asignar y quitar la ley en el editor; la cola la muestra. |
| `test/export/export_test.dart` (+3) | JSON 2.1 (marcador, totales, desglose, infracciones); sin registros no hay `matchStats`; compatibilidad con 2.0; textos nuevos del PDF. |
| `test/screenshots` | Capturas `08_*`: directo con marcador y sanciones (claro y oscuro), hoja del marcador, panel de sanciones y selector de leyes. Se actualizan las 01–07 (cabecera nueva). |
