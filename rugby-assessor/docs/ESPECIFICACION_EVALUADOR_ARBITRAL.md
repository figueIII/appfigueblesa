# Evaluador arbitral de rugby: base técnica y lógica (sin UI)

> **v1.2.0:** la rúbrica, la escala y las reglas de cierre han cambiado. Ver [`COMPETENCIAS_CARC.md`](COMPETENCIAS_CARC.md), que prevalece sobre este documento donde se contradigan.

> **Ampliación v1.1:** marcador, sanciones del árbitro y ley de cada acción (esquema SQLite v3, exportación 2.1). Detalle en [MARCADOR_SANCIONES_LEYES.md](MARCADOR_SANCIONES_LEYES.md).

> **Estado:** **v0.2: base técnica aceptada** con las resoluciones R1–R6 de la [sección 0](#0-registro-de-resoluciones-vinculantes), que prevalecen sobre el resto del texto. Lista para empezar la UI.
> **Producto:** app móvil offline-first para evaluadores e informadores arbitrales (*match observers / assessors*), derivada de la idea #1 (SinBin Ref).
> **Alcance:** modelo de datos, máquina de estados, motor de puntuación, persistencia, exportación y API de casos de uso. **La interfaz gráfica queda fuera.**
> **Comprobado:** los contratos compilan con `tsc --strict`, hay 22 tests (reloj, puntuación por bandas y presets), el DDL v2 se ha validado con triggers en SQLite 3.45 y el ejemplo de exportación v2.0, generado con el motor real, pasa el JSON Schema (draft 2020-12).

## Contenido del paquete

```
rugby-assessor/
  domain/model.ts            §1  entidades y tipos (contratos)
  domain/rubric-default.ts   §1.2 rúbrica v2.0.0 (pesos R1, bandas R2, topes R4)
  domain/category-presets.ts §1.1 presets de tiempos y categorías (R6)
  domain/clock.ts            §2.1 máquina de estados del reloj (event sourcing, pura)
  domain/scoring.ts          §2.3 banda sugerida, agregación ponderada (interna) y bandas
  domain/usecases.ts         §4  API del repositorio + validación de cierre + JSON canónico
  persistence/schema.sql     §3.1 esquema SQLite con triggers de inmutabilidad
  export/assessment-export.schema.json  §3.2 formato de intercambio
  export/example-export.json            ejemplo válido (generado por scripts/)
  test/*.test.ts             reloj, puntuación y presets (node --test)
```

Comandos: `tsc -p tsconfig.json` (comprobación de tipos) y `npm test`, que ejecuta `node --experimental-strip-types --test test/*.test.ts`.

**Stack de implementación.** Los contratos están en TypeScript porque así se pidió y sirven de lengua franca. La implementación recomendada es **Flutter con drift**, el mismo stack que el otro proyecto del repositorio. Así se reutilizan el conocimiento de drift, las migraciones probadas y los tipos exhaustivos (`sealed`). El DDL es SQLite estándar y vale tal cual para drift o para Room. Hay que traducir `clock.ts` y `scoring.ts` a Dart puro y portar estos mismos tests como *golden tests*.

### Principios

1. **El directo solo captura y lo demás espera.** Durante el juego el evaluador no clasifica nada: toca una etiqueta y sigue mirando. Todo el juicio (veredicto, impacto, decisión esperada) se hace después del partido.
2. **Append-only donde importa.** El reloj es un log de eventos inmutable. Las incidencias guardan auditoría de cada edición y un informe finalizado no se modifica nunca: se enmienda creando una versión nueva.
3. **El motor sugiere y el evaluador decide.** La banda de cada criterio la elige el evaluador. El motor sugiere una banda a partir de las incidencias, y si el evaluador elige otra tiene que justificarlo.
5. **Bandas hacia fuera, números hacia dentro.** El evaluador y el informe solo ven bandas cualitativas relativas al nivel del partido. Los números son un detalle interno del motor, que se guarda solo para auditoría.
4. **Lógica pura y parámetros versionados.** `clock.ts` y `scoring.ts` no hacen E/S ni leen el reloj. Pesos, bandas y topes viven en la rúbrica versionada.

---

## 0. Registro de resoluciones vinculantes

Validadas por el responsable de dominio el 13‑10‑2026.

| ID | Resolución | Dónde se aplica |
|---|---|---|
| **R1** | Áreas: **A 35 · B 20 · C 30 · D 15**. Dentro de C: **C1 Exactitud en la aplicación de las leyes 50 · C2 Juego desleal 30 · C3 Consistencia disciplinaria 20**. Prioridad al conocimiento reglamentario. | `rubric-default.ts` v2.0.0, §1.2 |
| **R2** | La evaluación visible son **bandas cualitativas relativas al nivel del partido**: *Por debajo del nivel* · *En el nivel* · *Por encima del nivel*. El motor calcula con números internos que nunca se muestran. El evaluador **elige bandas**, no notas. | `scoring.ts`, `model.ts`, §2.3, §3.4 |
| **R3** | La dificultad del partido es **solo descriptiva**: ni bonus ni malus. | `MatchMetadata.difficulty`, §1.1 |
| **R4** | Los topes por errores graves afectan **solo al criterio** donde ocurrió la acción, nunca a otros criterios, al área ni a la global de forma directa. | `suggestCriterionScore`, §2.3.1 |
| **R5** | En todas las versiones se evalúa **exclusivamente al árbitro principal**. Asistentes y TMO no se evalúan; los nombres de los asistentes se guardan solo como dato del partido. | `model.ts`, `schema.sql` v2, API §4 |
| **R6** | Presets de tiempos y categorías con los valores exactos de §1.1. | `category-presets.ts` |

Decisiones derivadas (si alguna no encaja, se corrige antes de la UI):

| ID | Decisión derivada | Motivo |
|---|---|---|
| R2.a | Valores internos de cada banda: Por debajo = 5 · En el nivel = 7 · Por encima = 9. Límites: **Por encima si > 8,0; Por debajo si < 6,0**; los empates exactos (6,0 y 8,0) caen en *En el nivel*. | Puntos medios entre bandas. Ante la duda se elige la banda conservadora. |
| R2.b | Si la banda elegida no coincide con la sugerida, la justificación debe tener al menos 40 caracteres. | Antes la regla era "desvío > 1,0 puntos", que no tiene sentido con bandas. |
| R4.a | La regla de "≥ 2 errores HIGH en el mismo criterio" se mantiene y **también limita ese criterio a *Por debajo***, igual que un error MATCH_DEFINING. | En la v1 ambos topes (5,5 y 6,0) estaban por debajo del estándar; se traduce tal cual. |
| R6.a | Los presets no fijan duración del descanso ni prórroga. El descanso queda como dato opcional y ningún preset tiene prórroga. | No se inventan valores que la federación no ha dado. |

---

## 1. Modelo de dominio y datos

Las definiciones completas están en [`domain/model.ts`](../domain/model.ts). Resumen de entidades y relaciones:

```
Official (árbitro) 1───* Assessment 1───1 MatchMetadata (embebido, con snapshot de CategoryConfig)
                          │ 1
                          ├──* ClockEvent        (append-only)
                          ├──* Incident 1──* AttachmentRef
                          └──* FinalReport (una por versión: v1, v2…)
                                ├──* CriterionScore (banda sugerida / banda elegida)
                                ├──* Finding (fortaleza / desarrollo)
                                ├──* ActionPoint ──► vive por árbitro, cruza evaluaciones
                                └──* ActionPointReview (de las ActionPoint OPEN anteriores)
AssessmentRubric (versionada, inmutable al publicarse) ◄── Assessment.rubricId
```

### 1.1 MatchMetadata

| Campo | Tipo | Notas |
|---|---|---|
| `competition`, `round` | texto | |
| `category` | `CategoryConfig` | Se elige un **preset** (tabla siguiente) y se guarda una **copia fija (snapshot)**: formato, duración de cada parte, sin-bin y variaciones de ley. Si la federación cambia un preset, los informes antiguos no cambian. |
| `kickoff` | `{ local, tz }` | Hora local con zona IANA. No se guarda en UTC porque el informe se lee en la hora local del campo. |
| `venue`, `home`, `away`, `finalScore` | | |
| `refereeId` | Id | **Único oficial evaluado** (R5). |
| `assistants` | `{ ar1?, ar2? }` | Solo nombres, como dato del partido. **No se evalúan.** |
| `assessorId` | Id | |
| `observationMode` | LIVE / VIDEO / LIVE_AND_VIDEO | Ver §2.1.2. |
| `difficulty` | LOW … VERY_HIGH | **Solo descriptivo** (R3): no modifica la evaluación en ningún caso. |

**Presets de categoría** ([`category-presets.ts`](../domain/category-presets.ts), R6):

| Código | Categoría | Formato | Partes | Sin-bin |
|---|---|---|---|---|
| `SM_DHCAT_1_2_3` | Sénior masculino: DHCAT, 1ª, 2ª, 3ª | XV | 2 × 40 min | 10 min |
| `SM_3AB_4` | Sénior masculino: 3ª grupo AB, 4ª | XV | 2 × 35 min | 10 min |
| `SF_DHCAT_1` | Sénior femenino: DHCAT, 1ª | XV | 2 × 40 min | 10 min |
| `SF_ABC_2` | Sénior femenino: grupo ABC, 2ª | XV | 2 × 35 min | 10 min |
| `M18` | M18 | XV | 2 × 35 min | 5 min |
| `M16` | M16 | XV | 2 × 35 min | 5 min |
| `M14` | M14 | XV | 2 × 30 min | 5 min |
| `SEVENS` | Rugby 7s | 7s | 2 × 7 min | 2 min |

El reloj usa directamente la duración del preset: en M14 el tiempo cumplido llega a los 30:00 y la segunda parte arranca en 30:00; en 7s llega a los 07:00 (probado en `presets.test.ts`).

### 1.2 AssessmentRubric

La rúbrica es una entidad versionada (`code` + `version` semver). Al publicarse queda inmutable, y cada informe guarda el id y la versión que usó. La rúbrica por defecto es la **v2.0.0** de [`rubric-default.ts`](../domain/rubric-default.ts), con los pesos validados (R1).

| Área (peso) | Criterio | Peso en el área | Etiquetas rápidas que lo alimentan |
|---|---|---|---|
| **A · Gestión de fases de juego (35)** | A1 Scrum | 25 | `SCRUM` |
| | A2 Touch y maul | 20 | `LINEOUT`, `MAUL` |
| | A3 Placaje y ruck | 35 | `TACKLE`, `RUCK` |
| | A4 Espacio y fuera de juego | 20 | `OFFSIDE` |
| **B · Comunicación y gestión (20)** | B1 Control verbal y preventivo | 30 | `COMMUNICATION` |
| | B2 Tono, señalización y presencia | 20 | — (se puntúa de forma global) |
| | B3 Capitanes y jugadores | 20 | `CAPTAIN_MGMT` |
| | B4 Ventaja | 30 | `ADVANTAGE` |
| **C · Leyes y disciplina (30)** | **C1 Exactitud en la aplicación de las leyes** | **50** | `TRY_GROUNDING`, `KNOCK_ON_FORWARD_PASS`, `OTHER_LAW` |
| | C2 Juego desleal | 30 | `FOUL_PLAY`, `TMO_PROCESS` (cómo gestiona el árbitro la consulta; el TMO no se evalúa) |
| | C3 Consistencia disciplinaria (tarjetas) | 20 | `CARD` |
| **D · Condición física y posicionamiento (15)** | D1 Condición física | 30 | `FITNESS` |
| | D2 Posicionamiento | 40 | `POSITIONING` |
| | D3 Líneas de carrera | 30 | `RUNNING_LINE` |

Con estos pesos, **C1 por sí solo supone el 15 % de la evaluación global** (30 % × 50 %), tanto como toda el área D.

- **Bandas visibles** (R2), siempre relativas al nivel del partido evaluado:

| Banda | Código | Valor interno | Rango interno |
|---|---|---|---|
| Por encima del nivel | `ABOVE` | 9 | > 8,0 |
| En el nivel | `AT` | 7 | 6,0 – 8,0 (incluidos) |
| Por debajo del nivel | `BELOW` | 5 | < 6,0 |

- **Escala interna** de 1 a 10. Nunca se muestra.
- **Una etiqueta alimenta un solo criterio.** Así una incidencia no puntúa dos veces. Si el evaluador cree que un error de ruck es en realidad de posicionamiento, cambia `criterionCode` al redactar.

### 1.3 IncidentLog

| Campo | Contenido |
|---|---|
| `seq`, `capturedAt { sessionMs, wallUtc }` | Orden de captura y los dos relojes: el monotónico para calcular y el de pared para auditar. |
| `matchTime` | `{ period, phaseLabel, periodElapsedMs, matchClockMs, overtimeMs, integrity, manualOverride }`, calculado al capturar y guardado desnormalizado. |
| `category` → `criterionCode` | La etiqueta del tap y el criterio que alimenta (editable). |
| `polarity` | POSITIVE / NEGATIVE / REVIEW, lo único que se decide en directo. |
| `gamePhase`, `fieldZone` | Opcionales: fase de juego y zona del campo (propia 22 … zona de ensayo). |
| `decisionTaken` / `decisionExpected` | `Decision { outcomes[], againstTeam, lawRef, description }`. `outcomes` es una lista porque puede haber golpe de castigo y amarilla a la vez. **La decisión esperada es obligatoria si el veredicto es INCORRECT o MISSED.** |
| `verdict` | PENDING · CORRECT · INCORRECT · MISSED (no pitó algo que debía) · DEBATABLE (decisión 50/50) · NOT_ASSESSABLE (el evaluador no lo vio bien). |
| `impact` + `impactConfirmed` | LOW · MEDIUM · HIGH · MATCH_DEFINING. `impactConfirmed = false` mientras sea el valor por defecto del tap. |
| `attachments[]` | VOICE_NOTE · PHOTO · VIDEO_CLIP · VIDEO_LINK (con `videoPositionMs`), con `sha256` y `status` PENDING_WRITE → COMMITTED / MISSING. |
| `source`, `status` | ONE_TAP / MANUAL / VIDEO_REVIEW · QUICK → ENRICHED, o VOID (anulación lógica, nunca borrado). |

**Una incidencia es clave (*key match incident*) si su impacto es HIGH o MATCH_DEFINING.** No se guarda como campo: se deriva del impacto.

### 1.4 FinalReport

Hay **un informe por evaluación y versión**, siempre del árbitro principal.

| Bloque | Contenido |
|---|---|
| Evaluación por criterio | `CriterionScore { suggestedBand, finalBand, notObserved, justification, evidenceIncidentIds, capBand }`, más `suggested` y `final` internos |
| Agregados | `areaScores[]` con `band` por área, **`band` global (resultado visible)**, `overallScore` interno y `keyDecisionAccuracy` (aciertos sobre decisiones con impacto ≥ HIGH, mostrado como "n de m") |
| Texto | `summary`, `strengths` (1–3) y `developmentAreas` (1–3), cada una ligada a un criterio y a incidencias que la respaldan |
| **Recomendaciones obligatorias** | `actionPoints` (1–3), cada una con **`successIndicator` observable** (p. ej. "≥ 80 % de rucks vistos desde el lado defensor") |
| Seguimiento | `previousActionPointReviews`: **todas** las recomendaciones OPEN del árbitro, procedentes de informes anteriores de cualquier evaluador, deben revisarse con ACHIEVED / PARTIAL / NOT_ACHIEVED / NOT_OBSERVED. Sin eso, el informe no se puede cerrar. |
| Control | `status` DRAFT → READY → FINALIZED (→ SUPERSEDED), `version`, `supersedesVersion`, `amendmentReason`, `finalizedAt` y `contentHash` |

Las `ActionPoint` pertenecen al **árbitro**, no al informe. Con eso se consigue un seguimiento longitudinal: el siguiente evaluador las encuentra pendientes aunque sea otra persona.

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
4. Con todo resuelto, el cálculo de bandas sugeridas (§2.3).

Cada edición pasa la incidencia a ENRICHED y deja una copia de la versión anterior en `incident_revision`.

### 2.3 Cálculo de la evaluación ([`scoring.ts`](../domain/scoring.ts))

El motor trabaja en una escala interna de 1 a 10 y **solo expone bandas** (R2). Todo lo numérico de esta sección es interno.

#### 2.3.1 Banda sugerida por criterio

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
| $s_p = 1 + 8p$ | Valor según la precisión: un 100 % da un **9**, el representativo de *Por encima del nivel*. |
| $n$ | Cantidad de evidencia, medida en "incidencias MEDIUM equivalentes". |
| $s$ | **Contracción hacia "En el nivel":** con poca evidencia la sugerencia se queda cerca de $b = 7{,}0$. Con $k = 3$ hacen falta unas 3 incidencias medias para que la evidencia pese lo mismo que el nivel esperado. Así, un único tap positivo no sube a nadie a *Por encima*. |

La **banda sugerida** se obtiene de $s$ con los límites de R2.a.

**Topes** (`capRules`), que se aplican después de la contracción **y solo al criterio donde ocurrió la acción** (R4):

| Condición en el criterio | Banda máxima sugerida para ese criterio |
|---|---|
| ≥ 1 error (INCORRECT o MISSED) con impacto MATCH_DEFINING | *Por debajo del nivel* |
| ≥ 2 errores con impacto ≥ HIGH (R4.a) | *Por debajo del nivel* |

El tope no se propaga: un error decisivo en el scrum deja A1 *Por debajo* y no toca A3, el área A ni la global, salvo por el peso normal de A1 en la media. Si no hay incidencias evaluadas, la banda sugerida es `null` y el evaluador elige sin sugerencia.

#### 2.3.2 Banda final, agregación y banda global

1. **El evaluador elige la banda de cada criterio** (`finalBand`) o lo marca `notObserved` (por ejemplo, sin scrums disputados). No introduce números.
2. **La justificación es siempre obligatoria.** Si la banda elegida no coincide con la sugerida, o supera un tope, debe tener **al menos 40 caracteres** (R2.b). Así se audita la decisión humana sin bloquearla.
3. **Área:** cada banda elegida vale su representativo interno (5 / 7 / 9) y el área es la media ponderada de sus criterios observados. Los no observados salen del cálculo y su peso se redistribuye. La banda del área sale de esa media.
4. **Global:** media ponderada de las áreas con valor, **sin redondear**, y banda global con los límites de R2.a. **La dificultad no interviene** (R3).
5. **Precisión en decisiones clave** = CORRECT / evaluadas con impacto ≥ HIGH. Se muestra aparte como "n de m" y no entra en la evaluación.

#### 2.3.3 Ejemplos comprobados (tests en `scoring.test.ts`)

| Caso | Datos | Resultado |
|---|---|---|
| A3 Placaje y ruck | 2× CORRECT MEDIUM, 1× CORRECT LOW, 1× INCORRECT HIGH, 1× DEBATABLE MEDIUM. Además una PENDING y una VOID, que no cuentan. | W = 11, C = 6, p = 0,545, n = 5,5. s = 50,5/8,5 = 5,94 → **Por debajo**. Sin tope. |
| A1 Scrum con error decisivo (R4) | 10× CORRECT HIGH + 1× MISSED MATCH_DEFINING; en el mismo partido, 6× CORRECT HIGH en A3 | A1: sin tope saldría 7,59 (*En el nivel*) → **tope: Por debajo**. A3: 8,6 → **Por encima**, sin contagio del tope. |
| Dos errores HIGH en C1 | 8× CORRECT HIGH + 2× INCORRECT HIGH | 7,26 sin tope → **Por debajo** (R4.a) |
| Poca evidencia | 1× CORRECT LOW | s = 7,29 → **En el nivel**: apenas se mueve |
| Agregación | A1 y C1 *Por debajo* · B4 y D2 *Por encima* · C2 no observado · resto *En el nivel* | Áreas: A 6,5 *En el nivel* · B 7,6 *En el nivel* · **C 5,57 *Por debajo*** · D 7,8 *En el nivel*. Global 6,64 → **En el nivel** |
| Peso del reglamento | C1 y C3 *Por debajo*, resto *En el nivel* | Área C = 5,6 → *Por debajo*. Global 6,58 → *En el nivel*. Para que la global caiga *Por debajo* hace falta que también fallen A1, A2, A3 y B4: global 5,90. |
| Límites | 8,0 exacto · 6,0 exacto · 8,01 · 5,99 | En el nivel · En el nivel · Por encima · Por debajo |

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
| `CHECK` de coherencia: un informe FINALIZED tiene hash y JSON canónico; la versión > 1 exige motivo de enmienda; las bandas solo admiten `BELOW` / `AT` / `ABOVE`; un criterio no observado no tiene banda | |
| Snapshot JSON automático al final de cada periodo, en el almacenamiento privado | Punto de recuperación aunque la base de datos se corrompa. |
| Tabla `outbox` | Prepara una sincronización futura con un servidor de la federación sin rehacer el modelo. |

**Adjuntos (notas de voz, fotos).** El ciclo es: escribir en `tmp/` → `fsync` → renombrado atómico a `media/<assessmentId>/<attachmentId>.m4a` → `UPDATE status = COMMITTED` con su `sha256`. Al arrancar, un barrido revisa los adjuntos: los `PENDING_WRITE` sin archivo pasan a `MISSING` y los archivos sin fila se borran a las 24 h. La grabación se hace con la app en primer plano. Si se permite seguir grabando con la pantalla bloqueada, hace falta un *foreground service* de tipo `microphone`.

**Protección de datos.** Un informe arbitral es dato personal (RGPD). Por eso:
- Se excluyen la base de datos y `media/` de la copia automática de Android (`dataExtractionRules`), o se cifran con SQLCipher si se quiere copia de seguridad.
- El borrado de un árbitro o de una evaluación es en cascada. `action_point` exige borrado explícito para no dejar recomendaciones huérfanas (Q6).
- Las notas de voz pueden grabar a terceros: se avisa en el primer uso.

Todas las restricciones y triggers se han probado con un script contra SQLite 3.45: rechazos esperados y borrado en cascada correcto.

### 3.2 Exportación JSON ([`assessment-export.schema.json`](../export/assessment-export.schema.json))

- **Un archivo por evaluación y versión de informe:** `format = "rugby-referee-assessment"`, `formatVersion = "2.0"`.
- **Bloques:** `generator` · `match` (con `refereeName` y `assistants` solo descriptivos) · `referee` · `assessor` · `rubric` (con copia de bandas, áreas, criterios y pesos, para que el comité pueda recalcular sin tener la rúbrica) · `report` · `incidents` (cronológicas, con el minuto como `"52:14"`) · `integrity`.
- En `report` mandan las bandas (`band`, `areaScores[].band`, `criterionScores[].finalBand` y `suggestedBand`). Los números (`overallScore`, `score`, `suggested`) van marcados como internos y solo sirven para auditoría.
- El esquema exige `decisionExpected` cuando el veredicto es INCORRECT o MISSED, de 1 a 3 fortalezas, áreas de desarrollo y recomendaciones, y un hash SHA-256 de 64 caracteres hexadecimales.
- El ejemplo [`example-export.json`](../export/example-export.json) se genera con el motor real (`scripts/build-example-export.ts`, preset `SM_DHCAT_1_2_3`) y pasa la validación del esquema. Un valor de banda que no sea BELOW, AT o ABOVE se rechaza.

### 3.3 Integridad del informe

Al finalizar se calcula `contentHash = SHA-256(canonicalJson(report sin "status"))`:
- **JSON canónico:** claves ordenadas, sin espacios y sin claves `undefined` (`canonicalJson` en `usecases.ts`).
- Se excluye `status` porque pasa de FINALIZED a SUPERSEDED tras una enmienda, y ese cambio no debe romper el hash.

El hash aparece en el pie del PDF y en el JSON, así que el comité puede comprobar que el PDF recibido corresponde al informe cerrado.

### 3.4 Plantilla del informe PDF

El PDF se genera en el dispositivo (paquete `pdf` de Flutter), en A4, con la fuente Noto Sans incrustada (acentos y ñ).

**El PDF no muestra ningún número de evaluación: solo bandas** (R2).

1. **Cabecera:** competición, jornada, categoría (preset) y formato, fecha y hora local, campo, resultado, árbitro, evaluador, modo de observación y dificultad (como dato de contexto). Los asistentes aparecen solo como nombres en la ficha del partido.
2. **Resumen ejecutivo:** **banda global** (con color y texto, para que se entienda también impreso en blanco y negro), banda de cada área, precisión en decisiones clave ("3 de 4") y resumen.
3. **Tabla de evaluación:** área → criterio → banda sugerida, banda elegida y justificación. Se marcan los topes aplicados y los casos en que la banda elegida difiere de la sugerida.
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
| `createMatchAssessment({ match: { …, categoryPresetCode, refereeId }, rubricId })` | Rúbrica PUBLISHED y aplicable al formato del preset. Preset existente. | Crea la evaluación en SETUP, o en READY si los datos están completos. Copia el preset como snapshot. Crea el informe DRAFT v1 del árbitro con todos los criterios vacíos y **precarga sus recomendaciones OPEN**. | `RUBRIC_NOT_PUBLISHED`, `UNKNOWN_CATEGORY_PRESET`, `VALIDATION_FAILED` |
| `recordClockEvent(id, body)` / `undoLastClockEvent(id)` | Evaluación READY o LIVE. | Añade un evento validado por `appendClockEvent`. El primer `PERIOD_START` pasa a LIVE y el `FULL_TIME` o `ABANDON` a POST_MATCH. | `CLOCK_RULE` (con el código del reloj) |
| **`logLiveIncident({ assessmentId, timestamp?, category, polarity?, severity?, notes? })`** | LIVE o POST_MATCH. | `t = timestamp ?? now()`. Calcula `matchTime`, aplica los valores del tap (`quickTagDefaults`), `criterionCode` sale del mapa de la rúbrica y se hace commit síncrono. | `INVALID_STATE` |
| `undoLastIncident(id, withinMs = 10000)` | La última incidencia tiene menos de `withinMs`. | Pasa a VOID con motivo `UNDO`. | `INVALID_STATE` |
| `enrichIncident(incidentId, patch)` | Evaluación no FINALIZED. | Actualiza la incidencia, la pasa a ENRICHED y guarda revisión. Si cambia el impacto, `impactConfirmed = true`. | `ASSESSMENT_LOCKED` |
| `attachMedia(incidentId, kind, source)` | | Sigue el ciclo de escritura atómica de §3.1. | `MEDIA_WRITE_FAILED`, `STORAGE_FULL` |
| `computeSuggestedScores(id)` | | `suggestCriterionScore` para cada criterio. Escribe `suggestedBand`, `capBand` y la evidencia, **sin tocar la banda elegida**. | |
| **`updateCriteriaScore(id, criterion, band \| 'NOT_OBSERVED', justification)`** | Informe en DRAFT o READY. `band` ∈ {BELOW, AT, ABOVE}. | Guarda la banda y la justificación y recalcula las bandas de área y la global (`aggregate`). Una justificación corta en un desvío no impide guardar, pero bloqueará el cierre. Si el informe estaba en READY, vuelve a DRAFT. | `VALIDATION_FAILED`, `REPORT_LOCKED` |
| `upsertFinding`, `upsertActionPoint`, `reviewPreviousActionPoint` | Informe en DRAFT o READY. | Edición del bloque de texto. Las recomendaciones nuevas nacen en DRAFT. Un informe en READY vuelve a DRAFT. | `REPORT_LOCKED` |
| **`generateConsolidatedReport(assessmentId)`** | Estado POST_MATCH. | Recalcula sugerencias y agregados y ejecuta `validateForFinalization`. Sin errores, el informe pasa a READY; con errores queda en DRAFT con la lista de *issues* (que sirve de lista de tareas). Devuelve el informe. | |
| `finalizeReport(id)` | Informe READY y validación sin errores. | En **una sola transacción**: JSON canónico, hash, estado FINALIZED, recomendaciones nuevas de DRAFT a OPEN, recomendaciones revisadas como ACHIEVED pasan a CLOSED, fila en el `outbox` y evaluación a FINALIZED. | `VALIDATION_FAILED` |
| `amendReport(id, reason)` | Informe FINALIZED. | La versión n pasa a SUPERSEDED y se crea la n+1 en DRAFT con copia del contenido y motivo obligatorio. Las incidencias **no** se reabren (Q5). | |
| `exportJson` / `exportPdf` | Informe FINALIZED (en DRAFT, el PDF lleva una marca de agua "BORRADOR"). | Genera el archivo y lo registra en `export_log` con su `sha256`. | |
| `getRefereeHistory(refereeId)` | | Informes del árbitro y recomendaciones abiertas, para el seguimiento entre partidos. | |

**Reglas de cierre** (`validateForFinalization`, probadas en los tests):

- Bloquean el cierre: incidencias PENDING; incidencias INCORRECT o MISSED sin decisión esperada o con el impacto sin confirmar; incidencias clave sin notas; criterios sin banda o sin justificación; banda distinta de la sugerida o por encima del tope con justificación corta; menos de 1 o más de 3 fortalezas, áreas de desarrollo o recomendaciones; recomendaciones sin indicador; recomendaciones anteriores sin revisar; resumen vacío.
- Solo avisan: adjuntos no guardados e incidencias con tiempo DEGRADED.

---

## Preguntas abiertas

Q1–Q4, Q7 y Q8 quedan resueltas por R1–R6. Siguen abiertas, sin bloquear la UI:

| ID | Pregunta | Propuesta actual |
|---|---|---|
| **Q5** | Una enmienda, ¿puede reabrir las incidencias o solo la redacción y las bandas? | Solo redacción y bandas. |
| **Q6** | Conservación y borrado de datos de árbitros (RGPD), y quién es el responsable del tratamiento (federación o evaluador). | Pendiente de decidir antes de publicar en Google Play. |
