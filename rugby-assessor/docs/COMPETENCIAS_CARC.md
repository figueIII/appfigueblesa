# Competencias del CARC (v1.2.0)

Desde la versión 1.2.0 la evaluación usa las competencias de la hoja «Full avaluació arbitral» del
CARC en lugar de la rúbrica v2. **Este documento sustituye**, donde se contradigan, a las partes de
`ESPECIFICACION_EVALUADOR_ARBITRAL.md` y `UI_PANTALLA_3_EVALUACION.md` que hablan de las bandas
*Por debajo / En el nivel / Por encima*, de los criterios A1–D3 y de los requisitos de cierre.

## Rúbrica `CARC-COMPETENCIES` 3.0.0

Está en `domain/rubric-default.ts`. La versión Dart, `app/lib/domain/rubric_default.dart`, se
genera con `scripts/gen-rubric-dart.sh`. Tiene 6 áreas y 25 competencias. Cada competencia tiene su
nivel (N1 básico → N3 avanzado) y su texto en castellano y en catalán (el original).

| Área | Competencias (nivel) |
|---|---|
| A · Colocación (*Col·locació*) | A1 (N1) punto de partida en fases estáticas · A2 (N1) no interfiere · A3 (N2) ve balón y jugadores · A4 (N2) trayectorias en juego abierto · A5 (N3) llega a los puntos de encuentro · A6 (N3) se comunica desde su posición |
| B · Comunicación (*Comunicació*) | B1 (N1) señal primaria y silbato · B2 (N2) señal secundaria · B3 (N3) comunicación eficaz con los jugadores |
| C · Continuidad (*Continuïtat*) | C1 (N1) señaliza la ventaja y su fin · C2 (N2) solo sanciona faltas con efecto material · C3 (N3) ventaja con consistencia |
| D · Fases estáticas (*Fases estàtiques*) | D1 (N1) fase ordenada y formación correcta · D2 (N1) secuencia y seguridad en la melé · D3 (N2) detecta acciones peligrosas · D4 (N3) disputa justa en melé, touch y reinicios |
| E · Fases dinámicas (*Fases dinàmiques*) | E1 (N1) identifica placaje, ruck y maul · E2 (N1) placador y placado · E3 (N2) puertas y entradas al ruck/maul · E4 (N2) líneas de fuera de juego · E5 (N3) disputa de pie · E6 (N3) jugador pescador (*jackler*) |
| F · Disciplina | F1 (N1) juego peligroso · F2 (N2) juego sucio · F3 (N3) control del partido |

Todas las competencias pesan lo mismo dentro de su área, y todas las áreas pesan lo mismo en la
valoración global.

## Escala E / C / N / U

| Banda | Catalán | Código | Valor interno | Límite |
|---|---|---|---|---|
| Excelente | Excel·lent | `E` | 9 | > 8,0 |
| Competente | Competent | `C` | 7 | 6,0 – 8,0 |
| No competente todavía | No competent encara | `N` | 5 | 4,0 – < 6,0 |
| Revisión urgente | Urgent revisar | `U` | 3 | < 4,0 |

El motor de sugerencias no cambia (`scoring.ts`): sigue la misma fórmula, con la contracción hacia
*Competente* (7,0). Los dos topes (un error decisivo, o dos errores de impacto alto en la misma
competencia) limitan la sugerencia a **N**.

## Qué es obligatorio para cerrar: nada

- No es obligatorio valorar las competencias. Una competencia sin valorar no cuenta en la media, igual que una «no observada».
- La justificación es opcional. Si la banda elegida no coincide con la sugerida, la app solo aconseja justificarla.
- También son opcionales el resumen, las fortalezas, las áreas de mejora y las recomendaciones (con o sin indicador de logro), y la revisión de las recomendaciones anteriores. Las fortalezas, áreas de mejora y recomendaciones vacías se descartan al cerrar.
- «Antes de cerrar» solo **avisa** de lo que falta: marcas sin veredicto, competencias sin valorar y recomendaciones anteriores sin revisar. El diálogo de confirmación recuerda cuántos avisos quedan.

## Datos nuevos del informe

- **Dificultad estimada del partido.** Se indica en la preparación (`assessment.difficulty`).
- **Dificultad real del partido.** Se indica en el cierre (`report.actual_difficulty`).
- **Recomendación** del CARC (`report.level_recommendation`):
  - `UP`: ↑ probar partidos de más exigencia.
  - `SAME`: = mantener en partidos similares.
  - `DOWN`: ↓ reducir la exigencia.

Las dos últimas entran en el informe firmado (y en su huella), en el PDF y en el JSON, que pasa al
formato **2.2**. Los documentos 2.0 y 2.1 siguen siendo válidos con el esquema.

## Después de cerrar: resumen del partido

Al cerrar el informe, la evaluación se sustituye por el **resumen**. Lo mismo ocurre al abrir un
partido finalizado desde el inicio. El resumen muestra:

- árbitro y partido;
- la valoración: global, por áreas, recomendación y dificultad estimada y real;
- las decisiones clave y el recuento de marcas;
- el marcador y su desglose;
- los golpes de castigo, golpes francos y tarjetas de cada equipo;
- lo escrito en el informe.

Desde ahí se exporta, se abre el informe completo o se **vuelve al menú**.

Al cerrar, la pestaña de cierre vuelve arriba, donde aparecen el aviso de informe cerrado y la
exportación. Antes quedaban fuera de la vista.

## Idioma

El idioma por defecto es el castellano. En el menú de inicio (⋮ → Idioma) se puede cambiar a
catalán; la elección se guarda en `app_setting`. En catalán se ven:

- los textos del CARC: áreas, competencias, escala y recomendación;
- la pantalla de evaluación y la de cierre;
- el resumen;
- los textos de la rúbrica en el PDF.

El resto de la interfaz (directo, revisión, preparación) sigue en castellano.

## Base de datos v5 y partidos antiguos

- Se reconstruyen `report` y `criterion_score` para admitir `E/C/N/U` (sin perder datos ni triggers), y se añaden `actual_difficulty`, `level_recommendation` y `app_setting`.
- **Informes ya cerrados:** no se tocan. Conservan su banda, su huella y la rúbrica v2 (`rubric_legacy.dart`), con la que se abren y exportan. Al leerlos, `BELOW / AT / ABOVE` se muestran como `N / C / E`.
- **Partidos sin cerrar:** pasan a la rúbrica CARC.
  - Cada marca se reasigna a la competencia de su categoría.
  - Las bandas que ya estaban elegidas se descartan, porque eran de otros criterios.
  - Las fortalezas, áreas de mejora y recomendaciones pasan a la competencia equivalente (`kLegacyCriterionToCarc` en `migrations.dart`).
