# Pantalla 3: evaluación por criterios y bandas cualitativas

> **Estado:** v0.1 implementada en Flutter (`app/lib/features/evaluation/`) sobre Drift.
> **Comprobado:**
> - `flutter analyze` sin incidencias.
> - **144 tests** en verde en toda la app. Nuevos: 13 de paridad del motor y del hash con TypeScript, 15 de pantalla (incluida la regla "cero números visibles" y la accesibilidad) y 2 de Drift de extremo a extremo.
> - Capturas en `app/test/screenshots/goldens/20…22_*.png`.

## 1. Port del motor a Dart puro (paridad con TypeScript)

| Pieza TS | Pieza Dart | Cómo se garantiza la paridad |
|---|---|---|
| `domain/rubric-default.ts` | `lib/domain/rubric_default.dart` | **Generado** desde el TS por `scripts/gen-rubric-dart.sh`. No se transcribe a mano. |
| `domain/scoring.ts` | `lib/domain/scoring.dart` | Misma fórmula, topes, tolerancia (1e-9) y límites. `test/domain/scoring_test.dart` replica **caso a caso y número a número** `test/scoring.test.ts` (5,941…, 205/27, 129/15, 39/7, 5,90, límites 6,0 y 8,0). |
| `validateForFinalization` (`usecases.ts`) | `lib/domain/report.dart` → `criterionIssues` / `validateForClose` | Mismos códigos y reglas, más dos de robustez: hallazgo o recomendación con texto vacío. |
| `canonicalJson` + SHA-256 | `canonicalJson` / `contentHash` | Los números se escriben como en JavaScript (`7`, no `7.0`). **El test recalcula en Dart el hash que TypeScript escribió en `export/example-export.json` y coincide.** |

## 2. Interfaz (UI-UX-Pro-Max)

**Estructura:** pestañas **A · B · C · D · Cierre**. Cada pestaña de área lleva un indicador de completa o pendiente (icono, no número).

**Pestaña de área:** título, **banda del área** (calculada a partir de las bandas elegidas) y una tarjeta por criterio.

**Tarjeta de criterio**, en el orden en que se razona:
1. Qué se evalúa: código, nombre y descripción de la rúbrica.
2. **Sugerencia de la app**, como banda. Si no hay marcas valoradas, lo dice ("elige según lo observado").
3. **Tope automático** (🔒): "error grave en este criterio. Máximo «Por debajo del nivel»". Se activa con 1 error decisivo o 2 errores de impacto alto en **ese** criterio.
4. "Basada en": las marcas del partido que la sustentan (acción, minuto, veredicto, impacto).
5. **Tu valoración:** tres botones de 88 dp (Por debajo, En el nivel, Por encima). La sugerida lleva la etiqueta "Sugerida" y las que superan el tope, "Sobre el tope". La elegida va con relleno, borde de 4 dp y check.
6. "No se observó en este partido": su peso se reparte entre los demás criterios del área.
7. **Justificación obligatoria.** Si la banda contradice la sugerencia o supera el tope, la ayuda pide el mínimo ("faltan 25 caracteres") y el criterio **no cuenta como completo** hasta llegar a 40 caracteres (sin contar espacios de los extremos).
8. Estado: "Criterio completo", o lo que falta.

**Pestaña Cierre:**
- **Banda global del partido** en grande, con su descripción, marcada como "Provisional" mientras falten criterios.
- Banda de cada área.
- Decisiones clave acertadas ("x de y").
- Criterios completos ("x de 14").
- Resumen del partido (obligatorio).
- **Fortalezas** y **áreas de mejora** (de 1 a 3 cada una). Cada una ligada a un criterio, que por defecto es el primero valorado "Por encima" o "Por debajo".
- **Recomendaciones para el próximo informe** (de 1 a 3), con su **indicador de logro**.
- **Recomendaciones del informe anterior**, si las hay: Lograda / Parcial / No lograda / No observada, más un comentario.
- **"Antes de cerrar"**: lista de lo pendiente. Cada línea lleva a su sitio: el criterio (cambia de pestaña y desplaza hasta la tarjeta), la sección, o la revisión si quedan marcas sin revisar.
- **"Cerrar informe"**: desactivado (con la explicación) mientras quede algo pendiente. Pide confirmación, explicando que el informe queda congelado y solo se corrige con una enmienda.
- **Tras el cierre:** franja "Informe cerrado · fecha · huella SHA-256…". Todos los campos pasan a solo lectura, en la interfaz y en el controlador.

**Cero números visibles.** Un test recorre todas las pestañas, antes y después del cierre, y falla si aparece una cifra decimal, un porcentaje o una nota "x/10". Los valores internos (5 / 7 / 9 y las medias) solo existen en el motor y en el JSON firmado.

Lo único numérico en pantalla son **recuentos y referencias**, no valoraciones: minutos de las marcas, "x de 14 criterios", "x de y decisiones clave" y caracteres que faltan.

**Colores de banda:** Por debajo en ámbar, En el nivel en neutro oscuro y Por encima en verde. "Por debajo" **no** usa el rojo de error: es una valoración, no un fallo. Siempre van con icono (↘ → ↗) y texto.

**Checklist de la skill:**
- ✅ Objetivos ≥ 48 dp y etiquetados, contraste de texto en claro y oscuro (guías de Flutter).
- ✅ Sin desbordes con texto ×1,6 en 360×640 y en horizontal (las pestañas se reducen en vez de desbordar).
- ✅ Errores junto a su campo.
- ✅ Revelación progresiva: la exigencia de 40 caracteres solo aparece cuando aplica.

## 3. Persistencia (`lib/data/drift_evaluation_repository.dart`)

- **Borrador sin botón de guardar:**
  - Cada banda o marca de "no observado" se escribe al momento.
  - Los textos se escriben 400 ms después de dejar de teclear.
  - Al salir de la pantalla o al cerrar el informe se escribe todo lo pendiente; si el controlador se destruye antes, la escritura continúa igualmente.
  - Probado: tras cerrar y reabrir el archivo, las bandas, justificaciones, el "no observado", el resumen y los hallazgos siguen ahí.
- **Tablas:** `report` (v1, DRAFT), `criterion_score` (guarda también la banda sugerida y el tope con que se valoró), `finding`, `action_point` (DRAFT) y `action_point_review`.
- **Cierre en una sola transacción:**
  1. Las 14 filas de criterio.
  2. `report` pasa a FINALIZED con `canonical_json` y `content_hash`. El test comprueba que `sha256(canonical_json) == content_hash`.
  3. Las recomendaciones nuevas pasan de DRAFT a OPEN.
  4. Las del informe anterior marcadas "Lograda" pasan a CLOSED.
  5. La evaluación pasa a FINALIZED.
  6. Se añade una fila `REPORT_FINALIZED` a `outbox`.
- **Inmutabilidad garantizada por la base de datos:** tras el cierre, modificar el informe falla (`REPORT_LOCKED`) y modificar una incidencia también (`ASSESSMENT_LOCKED`).
- **Seguimiento entre partidos** (probado): el siguiente informe del mismo árbitro muestra la recomendación abierta, no deja cerrar sin revisarla y, si se marca "Lograda", la cierra.
- **Reanudación:** al abrir la app, también se retoma la evaluación que estaba en POST_MATCH (antes solo READY o LIVE), para que la revisión y la evaluación pendientes no se pierdan.

## 4. Pendiente

- ~~Exportación a JSON y PDF.~~ Hecha: ver [EXPORTACION.md](EXPORTACION.md).
- ~~Preparación del partido.~~ Hecha: ver [UI_SETUP_E_INICIO.md](UI_SETUP_E_INICIO.md).
- **Enmiendas** (versión 2 o posterior, con motivo): backlog v1.2, ver [PRUEBAS_DE_CAMPO.md](PRUEBAS_DE_CAMPO.md#3-backlog-v12).
- Historial por árbitro: sin prioridad asignada.
