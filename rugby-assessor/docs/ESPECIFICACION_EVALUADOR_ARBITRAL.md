# Evaluador arbitral de rugby: base técnica y lógica (sin UI)

> **Estado:** borrador v0.1 para validar con el comité técnico de árbitros.
> **Producto:** app móvil offline-first para evaluadores e informadores arbitrales (*match observers / assessors*), derivada de la idea #1 (SinBin Ref).
> **Alcance:** modelo de datos, máquina de estados, motor de puntuación, persistencia, exportación y API de casos de uso. **La interfaz gráfica queda fuera.**
> **Comprobado:** los contratos compilan con `tsc --strict`, hay 14 tests del reloj y de la puntuación, el DDL se ha validado con triggers en SQLite 3.45 y el ejemplo de exportación pasa el JSON Schema (draft 2020-12).

## Contenido del paquete

```
rugby-assessor/
  domain/model.ts            §1  entidades y tipos (contratos)
  domain/rubric-default.ts   §1.2 rúbrica base v1.0.0 (pesos y bandas parametrizables)
  domain/clock.ts            §2.1 máquina de estados del reloj (event sourcing, pura)
  domain/scoring.ts          §2.3 nota sugerida, agregación ponderada y banda
  domain/usecases.ts         §4  API del repositorio + validación de cierre + JSON canónico
  persistence/schema.sql     §3.1 esquema SQLite con triggers de inmutabilidad
  export/assessment-export.schema.json  §3.2 formato de intercambio
  export/example-export.json            ejemplo válido (generado por scripts/)
  test/*.test.ts             reloj y puntuación (node --test)
```

Comandos: `tsc -p tsconfig.json` (comprobación de tipos) y `npm test`, que ejecuta `node --experimental-strip-types --test test/*.test.ts`.

**Stack de implementación.** Los contratos están en TypeScript porque así se pidió y sirven de lengua franca. La implementación recomendada es **Flutter con drift**, el mismo stack que el otro proyecto del repositorio. Así se reutilizan el conocimiento de drift, las migraciones probadas y los tipos exhaustivos (`sealed`). El DDL es SQLite estándar y vale tal cual para drift o para Room. Hay que traducir `clock.ts` y `scoring.ts` a Dart puro y portar estos mismos tests como *golden tests*.

### Principios

1. **El directo solo captura y lo demás espera.** Durante el juego el evaluador no clasifica nada: toca una etiqueta y sigue mirando. Todo el juicio (veredicto, impacto, decisión esperada) se hace después del partido.
2. **Append-only donde importa.** El reloj es un log de eventos inmutable. Las incidencias guardan auditoría de cada edición y un informe finalizado no se modifica nunca: se enmienda creando una versión nueva.
3. **El motor sugiere y el evaluador decide.** La nota de cada criterio la pone el evaluador. El motor calcula una nota sugerida con evidencias, y si el evaluador se aleja de ella tiene que justificarlo.
4. **Lógica pura y parámetros versionados.** `clock.ts` y `scoring.ts` no hacen E/S ni leen el reloj. Pesos, bandas y topes viven en la rúbrica versionada.

---

## 1. Modelo de dominio y datos

Las definiciones completas están en [`domain/model.ts`](../domain/model.ts). Resumen de entidades y relaciones:

```
Official 1───* AssessmentOfficial *───1 Assessment 1───1 MatchMetadata (embebido)
                                         │ 1
                                         ├──* ClockEvent        (append-only)
                                         ├──* Incident 1──* AttachmentRef
                                         └──* FinalReport (por oficial evaluado y versión)
                                               ├──* CriterionScore
                                               ├──* Finding (fortaleza / desarrollo)
                                               ├──* ActionPoint ──► vive por Official, cruza evaluaciones
                                               └──* ActionPointReview (de las ActionPoint OPEN anteriores)
AssessmentRubric (versionada, inmutable al publicarse) ◄── Assessment.rubricId
```

### 1.1 MatchMetadata

| Campo | Tipo | Notas |
|---|---|---|
| `competition`, `round` | texto | |
| `category` | `CategoryConfig` | **Copia fija (snapshot)**: formato (XV, 7s o 10s), duración de cada parte, descanso, prórroga, minutos de sin-bin y variaciones de ley. Si la federación cambia la duración de M16, los informes antiguos no cambian. |
| `kickoff` | `{ local, tz }` | Hora local con zona IANA. No se guarda en UTC porque el informe se lee en la hora local del campo. |
| `venue`, `home`, `away`, `finalScore` | | |
| `officials[]` | `{ role: REFEREE / AR1 / AR2 / TMO, officialId, assessed }` | El MVP evalúa solo al REFEREE, pero el modelo ya admite informes de asistentes. |
| `assessorId` | Id | |
| `observationMode` | LIVE / VIDEO / LIVE_AND_VIDEO | Ver §2.1.2. |
| `difficulty` | LOW … VERY_HIGH | **Solo contexto.** No modifica la nota (ver Q3). |

### 1.2 AssessmentRubric

La rúbrica es una entidad versionada (`code` + `version` semver). Al publicarse queda inmutable, y cada informe guarda el id y la versión que usó. Los valores por defecto están en [`rubric-default.ts`](../domain/rubric-default.ts) y **son una propuesta a validar** (Q1).

| Área (peso) | Criterio | Peso en el área | Etiquetas rápidas que lo alimentan |
|---|---|---|---|
| **A · Gestión de fases de juego (40)** | A1 Scrum | 25 | `SCRUM` |
| | A2 Touch y maul | 20 | `LINEOUT`, `MAUL` |
| | A3 Placaje y ruck | 35 | `TACKLE`, `RUCK` |
| | A4 Espacio y fuera de juego | 20 | `OFFSIDE` |
| **B · Comunicación y gestión (25)** | B1 Control verbal y preventivo | 30 | `COMMUNICATION` |
| | B2 Tono, señalización y presencia | 20 | — (se puntúa de forma global) |
| | B3 Capitanes y jugadores | 20 | `CAPTAIN_MGMT` |
| | B4 Ventaja | 30 | `ADVANTAGE` |
| **C · Leyes y disciplina (20)** | C1 Exactitud en la aplicación de las leyes | 30 | `TRY_GROUNDING`, `KNOCK_ON_FORWARD_PASS`, `OTHER_LAW` |
| | C2 Juego desleal | 40 | `FOUL_PLAY`, `TMO_PROCESS` |
| | C3 Consistencia disciplinaria (tarjetas) | 30 | `CARD` |
| **D · Condición física y posicionamiento (15)** | D1 Condición física | 30 | `FITNESS` |
| | D2 Posicionamiento | 40 | `POSITIONING` |
| | D3 Líneas de carrera | 30 | `RUNNING_LINE` |

- **Escala:** de 1 a 10 en pasos de 0,5.
- **Bandas sobre la nota global:** Excepcional ≥ 8,5 · Por encima del estándar ≥ 7,5 · Estándar del nivel ≥ 6,5 · Necesita mejorar ≥ 5,0 · Por debajo del estándar < 5,0.
- **Una etiqueta alimenta un solo criterio.** Así una incidencia no puntúa dos veces. Si el evaluador cree que un error de ruck es en realidad de posicionamiento, cambia `criterionCode` al redactar.

### 1.3 IncidentLog

| Campo | Contenido |
|---|---|
| `seq`, `capturedAt { sessionMs, wallUtc }` | Orden de captura y los dos relojes: el monotónico para calcular y el de pared para auditar. |
| `matchTime` | `{ period, phaseLabel, periodElapsedMs, matchClockMs, overtimeMs, integrity, manualOverride }`, calculado al capturar y guardado desnormalizado. |
| `category` → `criterionCode` | La etiqueta del tap y el criterio que alimenta (editable). |
| `officialRole` | A quién se atribuye; REFEREE por defecto. |
| `polarity` | POSITIVE / NEGATIVE / REVIEW, lo único que se decide en directo. |
| `gamePhase`, `fieldZone` | Opcionales: fase de juego y zona del campo (propia 22 … zona de ensayo). |
| `decisionTaken` / `decisionExpected` | `Decision { outcomes[], againstTeam, lawRef, description }`. `outcomes` es una lista porque puede haber golpe de castigo y amarilla a la vez. **La decisión esperada es obligatoria si el veredicto es INCORRECT o MISSED.** |
| `verdict` | PENDING · CORRECT · INCORRECT · MISSED (no pitó algo que debía) · DEBATABLE (decisión 50/50) · NOT_ASSESSABLE (el evaluador no lo vio bien). |
| `impact` + `impactConfirmed` | LOW · MEDIUM · HIGH · MATCH_DEFINING. `impactConfirmed = false` mientras sea el valor por defecto del tap. |
| `attachments[]` | VOICE_NOTE · PHOTO · VIDEO_CLIP · VIDEO_LINK (con `videoPositionMs`), con `sha256` y `status` PENDING_WRITE → COMMITTED / MISSING. |
| `source`, `status` | ONE_TAP / MANUAL / VIDEO_REVIEW · QUICK → ENRICHED, o VOID (anulación lógica, nunca borrado). |

**Una incidencia es clave (*key match incident*) si su impacto es HIGH o MATCH_DEFINING.** No se guarda como campo: se deriva del impacto.

### 1.4 FinalReport

Hay **un informe por oficial evaluado y por versión**.

| Bloque | Contenido |
|---|---|
| Puntuación por criterio | `CriterionScore { suggested, final, notObserved, justification, evidenceIncidentIds, capApplied }` |
| Agregados | `areaScores[]`, `overallScore` (1 decimal), `band` y `keyDecisionAccuracy` (aciertos sobre decisiones con impacto ≥ HIGH) |
| Texto | `summary`, `strengths` (1–3) y `developmentAreas` (1–3), cada una ligada a un criterio y a incidencias que la respaldan |
| **Recomendaciones obligatorias** | `actionPoints` (1–3), cada una con **`successIndicator` observable** (p. ej. "≥ 80 % de rucks vistos desde el lado defensor") |
| Seguimiento | `previousActionPointReviews`: **todas** las recomendaciones OPEN del oficial, procedentes de informes anteriores de cualquier evaluador, deben revisarse con ACHIEVED / PARTIAL / NOT_ACHIEVED / NOT_OBSERVED. Sin eso, el informe no se puede cerrar. |
| Control | `status` DRAFT → READY → FINALIZED (→ SUPERSEDED), `version`, `supersedesVersion`, `amendmentReason`, `finalizedAt` y `contentHash` |

Las `ActionPoint` pertenecen al **oficial**, no al informe. Con eso se consigue un seguimiento longitudinal: el siguiente evaluador las encuentra pendientes aunque sea otra persona.

---

## 2. Máquina de estados y lógica del partido

### 2.1 Reloj de partido ([`clock.ts`](../domain/clock.ts))

**Modelo.** El estado del reloj nunca se guarda como "contador": es el resultado de plegar (`fold`) un log de eventos inmutable. Cada evento lleva `t`, en milisegundos del eje monotónico de la sesión. Si la app se cierra o el sistema la mata, al volver se reconstruye el reloj exacto a partir del log. No hace falta ningún servicio que "mantenga" el tiempo.

```
                 PERIOD_START(H1)
   PRE_MATCH ─────────────────────► RUNNING ◄──────────┐
                                     │   ▲             │ TIME_ON
                            TIME_OFF │   │             │
                                     ▼   │             │
                                   STOPPED ────────────┘
          RUNNING|STOPPED ── PERIOD_END(INTERVAL) ──► INTERVAL ── PERIOD_START(siguiente) ──► RUNNING
          RUNNING|STOPPED ── PERIOD_END(FULL_TIME) ─► FULL_TIME      (no permitido desde H1)
          cualquier estado ── ABANDON ──────────────► ABANDONED      (salvo FULL_TIME / ABANDONED)
   ADJUST(±ms): solo en RUNNING/STOPPED · INTEGRITY_LOST: cualquiera · VOID(seq): deshace el último evento efectivo
```

| Regla | Comportamiento |
|---|---|
| Orden de periodos | H1 → H2 → (ET1 → ET2 → SD), estos últimos solo si `category.extraTime` existe y, para SD, si hay `suddenDeath`. Otro orden produce `WRONG_PERIOD_ORDER` o `NO_EXTRA_TIME_CONFIGURED`. |
| **Tiempo cumplido** | En rugby no hay "tiempo añadido" fijo: al llegar a los 40:00 el juego sigue hasta que el balón queda muerto. El reloj **no se detiene solo**: `overtimeMs > 0` marca "tiempo cumplido" y el evaluador cierra con `PERIOD_END` cuando el árbitro pita. |
| Tiempo parado | `TIME_OFF` / `TIME_ON` replican al árbitro (lesión, TMO, conmoción). El tiempo parado no cuenta y `timeOffCount` se guarda para el contexto. |
| Reloj tipo marcador | `matchClockMs = base del periodo + transcurrido`: H2 empieza en 40:00 y ET1 en 80:00 (con partes de 40 min). |
| Corrección | `ADJUST(deltaMs)` sincroniza con el reloj oficial y **solo actúa hacia delante**: las incidencias anteriores conservan su minuto. Para corregir una incidencia concreta se usa `matchClockOverrideMs`, que marca `manualOverride`. |
| Deshacer | `VOID(targetSeq)` solo sobre el último evento efectivo; el log nunca se borra. |
| Monotonía | Un evento con `t` menor que el anterior se rechaza (`NON_MONOTONIC_TIME`). |

#### 2.1.1 Eje de tiempo de sesión y reinicios del dispositivo

- **Fuente.** En Android se usa `SystemClock.elapsedRealtime()`, que sigue contando con el teléfono en reposo y no cambia si el usuario o la red tocan la hora. La hora de pared se guarda solo para auditar.
- **Reinicios.** `elapsedRealtime` vuelve a cero al reiniciar el teléfono. Por eso la plataforma guarda **anclas** (`session_time_anchor`): por cada `boot_id` (`Settings.Global.BOOT_COUNT`), la correspondencia entre el `mono` y el `t` de sesión.
- **Tras un reinicio**, el hueco se estima con la diferencia de hora de pared (marcada `estimated = 1`) y se emite `INTEGRITY_LOST`. Las incidencias capturadas a partir de ahí llevan `integrity = DEGRADED` hasta que el evaluador haga un `ADJUST` con el reloj oficial. La validación de cierre lo avisa como WARNING, no como error.

#### 2.1.2 Modo vídeo (v1.1)

El reductor no sabe de dónde viene `t`. En modo VIDEO, el eje de sesión es la posición del reproductor y la misma máquina de estados vale sin cambios. Lo único nuevo es que la plataforma debe evitar retrocesos (*seek* hacia atrás) mientras se registran eventos de reloj, o capturar las incidencias como VIDEO_REVIEW con `videoPositionMs` y el minuto manual.

### 2.2 Registro rápido con un tap

**En directo**, un tap equivale a una incidencia:

```
tap(categoría, polaridad)  ──►  t = SessionClock.now()          (primero se toma el instante)
                               matchTime = matchTimeAt(fold(log), t)
                               INSERT incident (status QUICK) + commit síncrono
                               ventana de deshacer 10 s  (undoLastIncident → VOID)
```

| Polaridad | Veredicto inicial | Impacto inicial | Para qué sirve |
|---|---|---|---|
| POSITIVE (✓) | CORRECT | LOW, sin confirmar | Buena decisión digna de mención. Cuenta como acierto aunque no se edite. |
| NEGATIVE (✗) | PENDING | MEDIUM, sin confirmar | Posible error. Hay que clasificarlo después. |
| REVIEW (●) | PENDING | MEDIUM, sin confirmar | Revisar luego (o en vídeo). |

- Si `logLiveIncident` recibe `severity`, se usa ese impacto y queda confirmado.
- **Nota de voz:** mantener pulsado un botón graba y adjunta el audio a la última incidencia de los últimos 30 s. Si no hay ninguna, crea una REVIEW de la categoría `OTHER_LAW`.
- Las incidencias se pueden registrar en el descanso o antes del partido (gestión de capitanes, calentamiento). En ese caso llevan `period = null` y `phaseLabel` = INTERVAL o PRE_MATCH.

**Después del partido** (POST_MATCH), la app ofrece una cola de trabajo ordenada:

1. Las PENDING, empezando por las de mayor impacto.
2. Las de impacto ≥ HIGH sin notas.
3. Las INCORRECT o MISSED sin decisión esperada.
4. Con todo resuelto, el cálculo de notas sugeridas (§2.3).

Cada edición pasa la incidencia a ENRICHED y deja una copia de la versión anterior en `incident_revision`.

### 2.3 Cálculo de notas ([`scoring.ts`](../domain/scoring.ts))

#### 2.3.1 Nota sugerida por criterio

Se usan solo las incidencias del criterio que no estén anuladas (VOID) y cuyo veredicto sea CORRECT, INCORRECT, MISSED o DEBATABLE. Las PENDING y NOT_ASSESSABLE no cuentan. Llamamos $w_i$ al peso de impacto y $c_i$ al crédito del veredicto.

| | LOW | MEDIUM | HIGH | MATCH_DEFINING |
|---|---|---|---|---|
| Peso de impacto $w_i$ | 1 | 2 | 4 | 8 |

| | CORRECT | DEBATABLE | INCORRECT | MISSED |
|---|---|---|---|---|
| Crédito $c_i$ | 1 | 0,5 | 0 | 0 |

$$
p=\frac{\sum w_i c_i}{\sum w_i}\qquad
s_p = 1 + 8p\qquad
n=\frac{\sum w_i}{w_{MEDIUM}}\qquad
s=\frac{k\cdot b + n\cdot s_p}{k+n}
$$

| Término | Significado |
|---|---|
| $p$ | Precisión ponderada por impacto. Fallar una decisión que decide el partido pesa 8 veces más que fallar una menor. |
| $s_p = 1 + 8p$ | Nota según la precisión: un 100 % da un **9**. El 10 lo reserva el evaluador para lo que no se refleja en las incidencias. |
| $n$ | Cantidad de evidencia, medida en "incidencias MEDIUM equivalentes". |
| $s$ | **Contracción hacia el estándar:** con poca evidencia la sugerida se queda cerca de $b = 7{,}0$ ("estándar del nivel"). Con $k = 3$ hacen falta unas 3 incidencias medias para que la evidencia pese lo mismo que el estándar. Así, un único tap positivo no convierte a nadie en excepcional. |

**Topes** (`capRules`), que se aplican después de la contracción:

| Condición en el criterio | Tope de la sugerida |
|---|---|
| ≥ 1 error (INCORRECT o MISSED) con impacto MATCH_DEFINING | 5,5 |
| ≥ 2 errores con impacto ≥ HIGH | 6,0 |

La nota resultante se redondea al paso de la escala (0,5) **sin superar nunca el tope**. Si no hay incidencias evaluadas, la sugerida es `null` y el evaluador puntúa sin ella.

#### 2.3.2 Nota final, agregación y banda

1. **El evaluador fija `final` en cada criterio**, o lo marca `notObserved` (por ejemplo, sin scrums disputados).
2. **La justificación es siempre obligatoria.** Si $|final - sugerida| > 1{,}0$, o si `final` supera un tope aplicado, debe tener **al menos 40 caracteres**. Así se audita la decisión humana sin bloquearla.
3. **Área** = media ponderada de sus criterios observados. Los no observados salen del cálculo y su peso se redistribuye.
4. **Global** = media ponderada de las áreas con nota. Se redondea a 1 decimal **solo al final** (sin redondeos intermedios) y la banda sale de esa nota global.
5. **Precisión en decisiones clave** = CORRECT / evaluadas con impacto ≥ HIGH. Se muestra aparte, como referencia, y no entra en la nota.

#### 2.3.3 Ejemplos comprobados (tests en `scoring.test.ts`)

| Caso | Datos | Resultado |
|---|---|---|
| A3 Placaje y ruck | 2× CORRECT MEDIUM, 1× CORRECT LOW, 1× INCORRECT HIGH, 1× DEBATABLE MEDIUM. Además una PENDING y una VOID, que no cuentan. | W = 11, C = 6, p = 0,545, $s_p$ = 5,36, n = 5,5. s = 50,5/8,5 = **5,94 → 6,0**. Sin tope. |
| A1 Scrum con error decisivo | 10× CORRECT HIGH + 1× MISSED MATCH_DEFINING | Sin tope saldría 7,59 → **tope 5,5** |
| Poca evidencia | 1× CORRECT LOW | s = 25,5/3,5 = 7,29 → **7,5**: apenas se mueve del estándar |
| Agregación | A1 5,5 · A3 6 · B4 8 · D2 8 · C2 no observado · resto 7 | Áreas 6,3 / 7,3 / 7,0 / 7,4. Global 6,846 → **6,8, "Estándar del nivel"** |

---

## 3. Persistencia y exportación

### 3.1 Almacenamiento offline-first ([`schema.sql`](../persistence/schema.sql))

| Decisión | Motivo |
|---|---|
| SQLite empaquetado (`sqlite3_flutter_libs` con drift) ≥ 3.37, tablas `STRICT` | Misma versión en todos los dispositivos y tipos comprobados por el propio motor. |
| `journal_mode=WAL` + **`synchronous=FULL`** | Con `NORMAL`, WAL puede perder las últimas transacciones si el teléfono se apaga por batería. Con `FULL` cada tap queda en disco. El coste es irrelevante: un tap cada pocos segundos. |
| **Una transacción por tap**, sin agrupar en memoria | Que el sistema mate la app no pierde nada. |
| IDs UUIDv7 generados en el cliente | No necesita servidor, se ordenan por tiempo y están listos para sincronizar. |
| `clock_event` append-only (triggers que impiden UPDATE y DELETE) | El reloj se puede auditar y reconstruir siempre. |
| `incident_revision` mediante trigger | Cada cambio de veredicto o impacto queda registrado. |
| Bloqueos por trigger (`ASSESSMENT_LOCKED`, `REPORT_LOCKED`, `RUBRIC_IMMUTABLE`) | La inmutabilidad la garantiza la base de datos, no solo la app. |
| `CHECK` de coherencia: un informe FINALIZED tiene hash y JSON canónico; la versión > 1 exige motivo de enmienda; la nota está entre 1 y 10 | |
| Snapshot JSON automático al final de cada periodo, en el almacenamiento privado | Punto de recuperación aunque la base de datos se corrompa. |
| Tabla `outbox` | Prepara una sincronización futura con un servidor de la federación sin rehacer el modelo. |

**Adjuntos (notas de voz, fotos).** El ciclo es: escribir en `tmp/` → `fsync` → renombrado atómico a `media/<assessmentId>/<attachmentId>.m4a` → `UPDATE status = COMMITTED` con su `sha256`. Al arrancar, un barrido revisa los adjuntos: los `PENDING_WRITE` sin archivo pasan a `MISSING` y los archivos sin fila se borran a las 24 h. La grabación se hace con la app en primer plano. Si se permite seguir grabando con la pantalla bloqueada, hace falta un *foreground service* de tipo `microphone`.

**Protección de datos.** Un informe arbitral es dato personal (RGPD). Por eso:
- Se excluyen la base de datos y `media/` de la copia automática de Android (`dataExtractionRules`), o se cifran con SQLCipher si se quiere copia de seguridad.
- El borrado de un oficial o de una evaluación es en cascada. `action_point` exige borrado explícito para no dejar recomendaciones huérfanas (Q6).
- Las notas de voz pueden grabar a terceros: se avisa en el primer uso.

Todas las restricciones y triggers se han probado con un script contra SQLite 3.45: rechazos esperados y borrado en cascada correcto.

### 3.2 Exportación JSON ([`assessment-export.schema.json`](../export/assessment-export.schema.json))

- **Un archivo por oficial y versión de informe:** `format = "rugby-referee-assessment"`, `formatVersion = "1.0"`.
- **Bloques:** `generator` · `match` · `official` · `assessor` · `rubric` (con copia de áreas, criterios y pesos, para que el comité pueda recalcular sin tener la rúbrica) · `report` · `incidents` (cronológicas, con el minuto como `"52:14"`) · `integrity`.
- El esquema exige `decisionExpected` cuando el veredicto es INCORRECT o MISSED, de 1 a 3 fortalezas, áreas de desarrollo y recomendaciones, y un hash SHA-256 de 64 caracteres hexadecimales.
- El ejemplo [`example-export.json`](../export/example-export.json) se genera con `scripts/build-example-export.ts` y pasa la validación del esquema.

### 3.3 Integridad del informe

Al finalizar se calcula `contentHash = SHA-256(canonicalJson(report sin "status"))`:
- **JSON canónico:** claves ordenadas, sin espacios y sin claves `undefined` (`canonicalJson` en `usecases.ts`).
- Se excluye `status` porque pasa de FINALIZED a SUPERSEDED tras una enmienda, y ese cambio no debe romper el hash.

El hash aparece en el pie del PDF y en el JSON, así que el comité puede comprobar que el PDF recibido corresponde al informe cerrado.

### 3.4 Plantilla del informe PDF

El PDF se genera en el dispositivo (paquete `pdf` de Flutter), en A4, con la fuente Noto Sans incrustada (acentos y ñ).

1. **Cabecera:** competición, jornada, categoría y formato, fecha y hora local, campo, resultado, árbitro y asistentes, evaluador, modo de observación y dificultad.
2. **Resumen ejecutivo:** nota global, banda (con color y texto, para que se entienda también impreso en blanco y negro), precisión en decisiones clave y resumen.
3. **Tabla de puntuación:** área → criterio → sugerida, final y justificación. Se marcan los topes aplicados y los desvíos de más de 1,0.
4. **Fortalezas** (1–3) y **áreas de desarrollo** (1–3), con referencia a los minutos que las respaldan.
5. **Recomendaciones para el próximo informe:** texto e indicador de logro.
6. **Seguimiento de recomendaciones anteriores:** estado y comentario de cada una.
7. **Anexo opcional:** cronología de incidencias evaluadas (minuto · fase · decisión tomada / esperada · veredicto · impacto · nota).
8. **Pie en cada página:** "Informe v{n} · Rúbrica {code} {version} · SHA-256 {primeros 16 caracteres}… · página x/y". Si es una enmienda: "Sustituye a v{n-1}: {motivo}".

---

## 4. Casos de uso y API funcional

El contrato completo está en [`usecases.ts`](../domain/usecases.ts). Todas las operaciones devuelven `Result<T>`: o bien `ok`, o bien `{ code, issues[] }` con códigos estables para traducir.

| Función | Precondiciones | Efecto / postcondiciones | Errores |
|---|---|---|---|
| `createMatchAssessment({ match, rubricId })` | Rúbrica PUBLISHED, aplicable al formato y al rol. Al menos un oficial con `assessed`. | Crea la evaluación en SETUP, o en READY si los datos están completos. Copia la categoría. Crea un informe DRAFT v1 por oficial evaluado con todos los criterios vacíos y **precarga las recomendaciones OPEN** de cada oficial. | `RUBRIC_NOT_PUBLISHED`, `VALIDATION_FAILED` |
| `recordClockEvent(id, body)` / `undoLastClockEvent(id)` | Evaluación READY o LIVE. | Añade un evento validado por `appendClockEvent`. El primer `PERIOD_START` pasa a LIVE y el `FULL_TIME` o `ABANDON` a POST_MATCH. | `CLOCK_RULE` (con el código del reloj) |
| **`logLiveIncident({ assessmentId, timestamp?, category, polarity?, severity?, notes?, officialRole? })`** | LIVE o POST_MATCH. | `t = timestamp ?? now()`. Calcula `matchTime`, aplica los valores del tap (`quickTagDefaults`), `criterionCode` sale del mapa de la rúbrica y se hace commit síncrono. | `INVALID_STATE` |
| `undoLastIncident(id, withinMs = 10000)` | La última incidencia tiene menos de `withinMs`. | Pasa a VOID con motivo `UNDO`. | `INVALID_STATE` |
| `enrichIncident(incidentId, patch)` | Evaluación no FINALIZED. | Actualiza la incidencia, la pasa a ENRICHED y guarda revisión. Si cambia el impacto, `impactConfirmed = true`. | `ASSESSMENT_LOCKED` |
| `attachMedia(incidentId, kind, source)` | | Sigue el ciclo de escritura atómica de §3.1. | `MEDIA_WRITE_FAILED`, `STORAGE_FULL` |
| `computeSuggestedScores(id, officialId)` | | `suggestCriterionScore` para cada criterio, filtrando por el rol del oficial. Escribe `suggested`, `capApplied` y la evidencia, **sin tocar `final`**. | |
| **`updateCriteriaScore(id, officialId, criterion, score \| 'NOT_OBSERVED', justification)`** | Informe en DRAFT o READY. La nota está en la escala y en pasos de 0,5. | Guarda la nota y la justificación y recalcula áreas, nota global y banda (`aggregate`). Una justificación corta en un desvío no impide guardar, pero bloqueará el cierre. Si el informe estaba en READY, vuelve a DRAFT. | `VALIDATION_FAILED`, `REPORT_LOCKED` |
| `upsertFinding`, `upsertActionPoint`, `reviewPreviousActionPoint` | Informe en DRAFT o READY. | Edición del bloque de texto. Las recomendaciones nuevas nacen en DRAFT. Un informe en READY vuelve a DRAFT. | `REPORT_LOCKED` |
| **`generateConsolidatedReport(assessmentId)`** | Estado POST_MATCH. | Por cada oficial evaluado: recalcula sugeridas y agregados y ejecuta `validateForFinalization`. Sin errores, el informe pasa a READY; con errores queda en DRAFT con la lista de *issues* (que sirve de lista de tareas). Devuelve los informes. | |
| `finalizeReport(id, officialId)` | Informe READY y validación sin errores. | En **una sola transacción**: JSON canónico, hash, estado FINALIZED, recomendaciones nuevas de DRAFT a OPEN, recomendaciones revisadas como ACHIEVED pasan a CLOSED, fila en el `outbox`, y la evaluación a FINALIZED cuando lo están todos sus informes. | `VALIDATION_FAILED` |
| `amendReport(id, officialId, reason)` | Informe FINALIZED. | La versión n pasa a SUPERSEDED y se crea la n+1 en DRAFT con copia del contenido y motivo obligatorio. Las incidencias **no** se reabren (Q5). | |
| `exportJson` / `exportPdf` | Informe FINALIZED (en DRAFT, el PDF lleva una marca de agua "BORRADOR"). | Genera el archivo y lo registra en `export_log` con su `sha256`. | |
| `getOfficialHistory(officialId)` | | Informes del oficial y recomendaciones abiertas, para el seguimiento entre partidos. | |

**Reglas de cierre** (`validateForFinalization`, probadas en los tests):

- Bloquean el cierre: incidencias PENDING; incidencias INCORRECT o MISSED sin decisión esperada o con el impacto sin confirmar; incidencias clave sin notas; criterios sin nota o sin justificación; desvíos o superación de topes con justificación corta; menos de 1 o más de 3 fortalezas, áreas de desarrollo o recomendaciones; recomendaciones sin indicador; recomendaciones anteriores sin revisar; resumen vacío.
- Solo avisan: adjuntos no guardados e incidencias con tiempo DEGRADED.

---

## Preguntas abiertas antes de conectar la UI

| ID | Pregunta | Propuesta actual |
|---|---|---|
| **Q1** | ¿Pesos de las áreas y los criterios, y cortes de las bandas? | A 40 · B 25 · C 20 · D 15. Bandas 8,5 / 7,5 / 6,5 / 5,0. |
| **Q2** | ¿Escala de 1 a 10 o bandas cualitativas puras (como algunas federaciones)? | Nota de 1 a 10 en pasos de 0,5, que se traduce a banda. Admite ambas. |
| **Q3** | ¿Debe la dificultad del partido modificar la nota? | No: solo contexto, para no esconder un ajuste opaco. Alternativa: ±0,5 explícito y justificado. |
| **Q4** | Topes por errores graves: ¿5,5 por un error decisivo y 6,0 por dos errores HIGH? ¿Se aplican también al área o a la nota global? | Solo por criterio. |
| **Q5** | Una enmienda, ¿puede reabrir las incidencias o solo la redacción y las notas? | Solo redacción y notas. |
| **Q6** | Conservación y borrado de datos de oficiales (RGPD), y quién es el responsable del tratamiento (federación o evaluador). | Pendiente de decidir. |
| **Q7** | ¿Se evalúa a los asistentes (AR1/AR2) y al TMO en el MVP? | El modelo lo admite; el MVP solo evalúa al REFEREE. |
| **Q8** | Duraciones por categoría (M14, M16, M18, 7s, 10s) según tu federación. | Configurables; no hay valores normativos fijados en el código. |
