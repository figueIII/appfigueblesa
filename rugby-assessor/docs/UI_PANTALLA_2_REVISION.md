# Pantalla 2: revisión post-partido

> **Estado:** v0.1 implementada en Flutter (`app/lib/features/review/`) sobre la persistencia Drift.
> **Comprobado:**
> - `flutter analyze` sin incidencias.
> - 110 tests en verde en toda la app. De la revisión: 5 de lógica de la cola, 14 de pantalla y accesibilidad y 1 de persistencia Drift.
> - Capturas de referencia en `app/test/screenshots/goldens/10_…13_*.png`.

## 1. Qué resuelve

Después del partido, el evaluador convierte las marcas rápidas del directo en incidencias completas: veredicto, impacto, decisión tomada y esperada, notas, criterio y contexto.

La pantalla hace dos cosas:
- **Prioriza** qué revisar primero, con una cola ordenada por urgencia e impacto.
- **Garantiza** que, al vaciar la cola, todas las incidencias tienen veredicto, que es lo único obligatorio para cerrar el informe.

Las reglas por incidencia son las de `validateForFinalization` (`domain/usecases.ts`). **Desde 1.1.3 solo el veredicto es obligatorio**: lo demás es **recomendado**. Se muestra como sugerencia en gris, junto al campo y en la tarjeta, y no bloquea ni la cola ni el cierre del informe (en TypeScript, `WARNING` en lugar de `ERROR`).

| Regla | Código | Tipo | Texto |
|---|---|---|---|
| Sin veredicto | `INCIDENT_VERDICT_PENDING` | **Obligatorio** | "Elige un veredicto." |
| Impacto Alto o Decisivo sin notas | `KEY_INCIDENT_NOTES_REQUIRED` | Recomendado | "Recomendado en las de impacto alto o decisivo." |
| Incorrecta o No pitada sin decisión esperada | `INCIDENT_EXPECTED_DECISION_REQUIRED` | Recomendado | "Lo que debía pitar según el reglamento (recomendado)." |
| Incorrecta o No pitada con el impacto por defecto del tap | `INCIDENT_IMPACT_NOT_CONFIRMED` | Recomendado | "Recomendado en un error: confirma el impacto." |

## 2. Cola ordenada por impacto (`lib/domain/review.dart`, pura)

Desde 1.1.3 la cola solo contiene las marcas **sin veredicto**, ordenadas por impacto y minuto. Antes había tres niveles: sin veredicto, clave sin notas y error incompleto; los dos últimos ahora son recomendaciones.

Dentro de cada nivel, **impacto de mayor a menor** y, a igualdad, por minuto de partido. Una incidencia con varios problemas va a su nivel más urgente. Las anuladas no cuentan.

Al guardar, el veredicto alinea la polaridad (Correcta → ✓, Incorrecta o No pitada → ✗) y la incidencia pasa a ENRICHED.

## 3. Arquitectura

```
lib/domain/review.dart                 reglas, cola, progreso, applyReviewEdit (puro)
lib/data/live_session_repository.dart  puerto ReviewRepository (+ implementación en memoria)
lib/data/drift_live_session_repository.dart
                                       saveEnrichment (una transacción; auditoría por trigger),
                                       voidIncident (VOID + void_reason), loadReview
lib/data/codecs.dart                   Decision ⇄ JSON (mismo formato que model.ts y la exportación)
lib/features/review/
  review_controller.dart               estado; cada guardado se ESPERA (no optimista)
  review_screen.dart                   progreso + filtro + lista + estados vacíos
  incident_editor_screen.dart          editor de una incidencia
  review_labels.dart                   textos, iconos y criterios de la rúbrica v2.0.0
  widgets/choice_controls.dart         ChoiceGrid · ChipMultiSelect · SectionHeader
```

**Diferencia deliberada con el directo:** en la banda el guardado es optimista, con cola, para no esperar nunca. Aquí se espera a que termine cada guardado. El evaluador está sentado y debe saber que lo redactado ya está en disco. Si falla, el aviso aparece junto al botón y el borrador se conserva para reintentar.

## 4. Pantallas

### Lista (`ReviewScreen`)
- **Progreso:** cifra grande + "de N resueltas" + barra (verde al completar).
- **Filtro:** *Pendientes (n)* muestra la cola; *Todas (m)* muestra todas las marcas en orden cronológico.
- **Tarjeta:**
  - Minuto en cifras tabulares y periodo.
  - Categoría.
  - Etiqueta de veredicto (icono + texto + color).
  - Impacto, con "?" si está sin confirmar.
  - Lo que falta, una línea por problema, con icono.
  - Borde grueso si tiene pendientes.
  - Toda la tarjeta es el objetivo táctil, con una etiqueta de lector de pantalla que resume la información.
- **Estados:**
  - Cargando.
  - Error con "Reintentar".
  - **Sin marcas:** "No hubo marcas en este partido".
  - **Revisión completa:** "Revisión completa" con el botón "Ir a la evaluación por criterios", que lleva a la Pantalla 3.

### Editor (`IncidentEditorScreen`)
El orden de arriba abajo sigue el razonamiento: **qué pasó → veredicto → impacto → decisión esperada → decisión tomada → notas → contexto**.

| Bloque | Detalle |
|---|---|
| Qué pasó | Minuto grande, categoría y periodo. Avisa si el minuto es estimado por un reinicio. **Criterio reasignable** ("Cuenta en el criterio A3 · Placaje y ruck ›"): abre una lista agrupada por áreas. |
| Veredicto | Rejilla de 5 botones de 64 dp con una ayuda corta: Correcta (*decisión acertada*), Incorrecta (*pitó, pero mal*), No pitada (*debía pitar y no lo hizo*), Discutible (*50/50*), No evaluable (*no se vio bien*). La opción elegida lleva relleno + borde de 4 dp + check; los iconos de las opciones nunca son un check relleno, para que ninguna parezca ya marcada. |
| Impacto | Bajo, Medio, Alto o Decisivo, cada uno con su criterio ("Puntos, tarjeta o resultado"). Elegirlo **confirma** el impacto. Si sigue el valor del directo, se avisa. |
| Decisión esperada | **Solo aparece si el veredicto es Incorrecta o No pitada.** 6 decisiones frecuentes visibles y el resto tras "Más decisiones (9)"; lo ya elegido se ve siempre. Equipo sancionado y ley aplicable opcional ("15.4"). |
| Decisión tomada | Opcional, con las mismas pastillas. |
| Notas | Obligatorias si el impacto es Alto o Decisivo. |
| Contexto | Opcional: fase de juego y zona del campo, de selección única que se puede desmarcar. |
| Barra fija inferior | Resumen de lo pendiente ("Pendiente: Faltan notas · Falta la decisión esperada") o "Lista para el informe." + **"Guardar y siguiente"** (abre la siguiente pendiente de la cola) o "Guardar" si es la última. |
| Anular | Icono en la barra superior → diálogo → VOID con motivo `REVIEW` (nunca se borra). |
| Salir sin guardar | Diálogo "¿Descartar los cambios?". |

## 5. UI-UX-Pro-Max: checklist

| Punto | Resultado |
|---|---|
| Objetivos ≥ 48 dp y etiquetados | ✅ lista y editor, en tema claro y oscuro (`androidTapTargetGuideline`, `labeledTapTargetGuideline`) |
| Contraste de texto | ✅ `textContrastGuideline` en ambos temas; tokens AAA de la pantalla 1 |
| Errores junto al campo | ✅ cada `SectionHeader` muestra su error (icono + texto) y la barra inferior los resume |
| Color no es el único indicador | ✅ veredictos con icono + texto; selección con borde grueso + check; filtro con relleno invertido (cambio de luminancia) |
| Revelación progresiva | ✅ la decisión esperada solo aparece para errores; las decisiones poco frecuentes están plegadas |
| Texto dinámico | ✅ sin desbordes con texto ×1,6 en 360×640 y 844×390 (lista y editor) |
| Formulario accesible en orden | ✅ el editor usa `SingleChildScrollView`, no una lista perezosa: todos los campos existen y el lector de pantalla los recorre en orden |
| Salidas | ✅ volver atrás pide confirmación si hay cambios; cancelar en todos los diálogos |

## 6. Navegación

El botón "Ir a revisión" del directo (tras el final) **vacía primero la cola de escritura** del directo y abre la revisión. Al volver, el directo se recarga, por si se anuló o editó alguna marca.

## 7. Pendiente

- **Corregir el minuto** de una marca (`matchClockOverrideMs`, spec §2.1): backlog v1.2, ver [PRUEBAS_DE_CAMPO.md](PRUEBAS_DE_CAMPO.md#3-backlog-v12).
- **Adjuntos** (nota de voz) en el editor, junto con la nota de voz del directo: backlog v1.2.
- ~~Pantalla 3.~~ Hecha: ver [UI_PANTALLA_3_EVALUACION.md](UI_PANTALLA_3_EVALUACION.md).
