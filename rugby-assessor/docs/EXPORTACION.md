# Exportación del informe cerrado: JSON y PDF

> **Estado:** v0.1 implementada (`app/lib/export/`) e integrada en la pestaña **Cierre** de la Pantalla 3.
> **Comprobado:**
> - `flutter analyze` sin incidencias.
> - 160 tests en verde en toda la app (16 nuevos de exportación). Los tests de TypeScript siguen en verde.
> - Muestras reales en [`export/samples/`](../export/samples/) (`informe-ejemplo.pdf` y `informe-ejemplo.json`), generadas por la app a partir de un partido cerrado.

## 1. Principio: una sola fuente de verdad

```
informe cerrado (report.canonical_json + content_hash, en SQLite)
        │  verifyIntegrity: SHA-256(canonical_json) == content_hash   ← si no cuadra, NO se exporta
        ▼
documento de exportación 2.0 (buildExportDocument, puro)
        │  validación contra assessment-export.schema.json            ← si no cumple, NO se exporta
        ├──────────────► JSON (tal cual, con sangría)
        └──────────────► PDF  (buildReportPdf renderiza ESE documento)
```

- El PDF y el JSON salen del **mismo documento validado**, así que no pueden contar cosas distintas.
- El informe del documento es el **JSON firmado al cerrar**, no se recalcula. Por eso la huella del PDF y del JSON es exactamente la del cierre.

## 2. JSON

- **Formato:** `rugby-referee-assessment` 2.0. Bloques: `match` (con dificultad descriptiva, asistentes y resultado), `referee`, `assessor`, `rubric` (bandas, áreas, criterios y pesos), `report` (firmado + `status`), `incidents` (no anuladas, en orden cronológico) e `integrity` (SHA-256, canonicalización, `/report` y la huella).
- **Validación en la app:** contra la copia empaquetada del esquema (`assets/export/`). Un test exige que sea idéntica a `export/assessment-export.schema.json`.
- **Validación cruzada:** el test también valida el archivo con el validador de referencia de Python (`jsonschema`, draft 2020-12).
- **Verificable por terceros:** quitando `status` de `report` y aplicando el JSON canónico, el SHA-256 coincide con `integrity.contentHash`. Lo prueba un test con una implementación independiente.

## 3. PDF (paquete `pdf`, A4)

- **Tipografía:** Roboto incrustada (Regular, Medium, Bold, Italic; licencia Apache 2.0 en `assets/fonts/`). No se descarga nada, así que funciona sin conexión. Un test comprueba con `pdffonts` que **todas** las fuentes están incrustadas.
- **Indicador de banda:** tres casillas dibujadas (Por debajo · En el nivel · Por encima) más la etiqueta. Se lee impreso en blanco y negro. Roboto no tiene flechas, así que el indicador es vectorial, no tipográfico.
- **Estructura:**
  1. **Cabecera oficial:** equipos, competición, jornada y categoría, árbitro, asistentes (no evaluados), evaluador, fecha y hora con zona, campo, resultado, **dificultad** ("Alta, descriptiva: no modifica la evaluación"), modo de observación, fecha de cierre y una caja "Informe vN · Cerrado".
  2. **Resumen ejecutivo:** banda global destacada con su descripción, banda de cada área, decisiones clave acertadas ("1 de 2") y resumen del evaluador.
  3. **Desglose por áreas y criterios:** tabla por área con criterio, banda (o "No observado") y justificación. Debajo, cuando aplica, se indica en cursiva la sugerencia de la app (si no se siguió) y el tope automático. Cada área va **en un bloque que no se parte** entre páginas.
  4. **Fortalezas** y **áreas de mejora**, cada una con su criterio.
  5. **Recomendaciones para el próximo informe**, con **indicador de logro**.
  6. **Seguimiento de recomendaciones anteriores** (si las hay): recomendación, estado y comentario.
  7. **Integridad del informe:** huella SHA-256 completa y cómo verificarla.
  8. **Anexo opcional** (en página nueva): cronología de **incidencias clave** (impacto alto o decisivo) con minuto, acción y criterio, decisión tomada, decisión esperada (con equipo y ley), valoración e impacto, y notas.
- **Pie en todas las páginas:** "Informe v1 · Rúbrica RUGBY-XV-BASE 2.0.0 · SHA-256 46ab8bec…9d82ba77 · Página x de y". Un test comprueba que aparece una vez por página.
- **Cero notas numéricas:** un test extrae el texto del PDF y falla si aparece alguno de los valores internos no enteros del informe (medias de área y global, sugerencias) o cualquier cifra decimal (salvo el número de ley "19.10"). Lo numérico que sí aparece son datos del partido: fecha, minutos, resultado, duración de las partes y recuentos.

## 4. Integración

- **Pestaña Cierre** (solo con el informe cerrado): sección **"Exportar y enviar al comité"**, con:
  - Interruptor **"Incluir anexo de incidencias clave"** (activado por defecto).
  - **Compartir PDF** (acción principal), **JSON** y **PDF + JSON**.
  - Indicador de progreso en el botón pulsado; los demás quedan desactivados mientras tanto.
  - Al terminar, "Preparado: nombre de archivo". Si algo falla, un error explicado junto a los botones.
- **Hoja de compartir del sistema** (`share_plus`): asunto "Informe de evaluación arbitral · Local – Visitante" y texto con la **huella SHA-256** del informe, para el correo o la mensajería del comité.
- **Archivos:**
  - Nombre legible y seguro: `informe_2026-10-17_club-local-rc-visitante-rt_v1.pdf`.
  - **Escritura atómica** (temporal y renombrado): nunca se comparte un archivo a medias.
  - Se guardan en el almacenamiento privado de la app (`exports/`).
  - **Registro en `export_log`:** formato, versión, ruta y SHA-256 del propio archivo.
- **Errores tratados:**
  - Informe sin cerrar.
  - **Huella alterada**: no se exporta y se avisa de posible alteración del almacenamiento. Un test lo prueba manipulando el JSON guardado.
  - Documento fuera de esquema (con la ruta del error).
  - Fallo de escritura o al compartir.

## 5. Tests

| Grupo | Qué prueba |
|---|---|
| `test/export/export_test.dart` (11) | Esquema idéntico al de `export/`; JSON válido con la huella del cierre y **recalculable por terceros**; validación cruzada con Python; documento inválido rechazado; huella alterada rechazada; informe sin cerrar rechazado; PDF A4 con fuentes incrustadas, todas las secciones, pie en cada página y "Página x de y"; **cero notas numéricas**; anexo desactivable; `export_log`; mensaje de envío. |
| `test/export/export_ui_test.dart` (4) | Compartir PDF desde la pestaña Cierre (asunto, huella y archivo `%PDF-`); PDF + JSON en un envío y anexo desactivado; huella alterada (no se comparte y se explica); accesibilidad de la sección en claro y oscuro. |
| `test/screenshots` | Captura `23_exportacion_light.png`. |

## 6. Pendiente

- Probar la hoja de compartir en Android e iOS reales (`share_plus` usa su propio *FileProvider*; en este entorno no hay SDK móvil).
- Enmiendas (versión 2 o posterior): la exportación ya toma la versión vigente y el pie muestra su número.
