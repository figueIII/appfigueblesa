# Fase 2 — Arquitectura del motor de cálculo y modelo de datos local

> **Estado:** borrador para validación.
> **Depende de:** [`ESPECIFICACION_TECNICA_MOTOR.md`](./ESPECIFICACION_TECNICA_MOTOR.md) v1.0 (resoluciones D1–D4).
> **Alcance:** capa de dominio pura, contratos de funciones, entidades, esquema SQLite y estrategia de pruebas. **Sin UI y sin implementación.** Los bloques de código de este documento son **contratos** (firmas y tipos) y DDL de esquema; no son código de producción.

---

## Índice

1. [Decisión de stack](#1-decisión-de-stack)
2. [Principios de diseño del motor](#2-principios-de-diseño-del-motor)
3. [Estructura de paquetes y dependencias](#3-estructura-de-paquetes-y-dependencias)
4. [Tipos base: unidades, resultados y avisos](#4-tipos-base-unidades-resultados-y-avisos)
5. [Contratos de los módulos de cálculo](#5-contratos-de-los-módulos-de-cálculo)
6. [Parámetros del motor versionados](#6-parámetros-del-motor-versionados)
7. [Modelo de dominio: entidades y agregados](#7-modelo-de-dominio-entidades-y-agregados)
8. [Esquema SQLite](#8-esquema-sqlite)
9. [Trazabilidad e integridad legal](#9-trazabilidad-e-integridad-legal)
10. [Estrategia de pruebas](#10-estrategia-de-pruebas)
11. [Preguntas abiertas para validar](#11-preguntas-abiertas-para-validar)

---

## 1. Decisión de stack

**Recomendación: Dart 3 (motor en paquete Dart puro) + Flutter para la app (fase posterior) + SQLite mediante `drift` con `sqlite3_flutter_libs`.**

| Criterio | Dart / Flutter + drift | TypeScript / React Native + op‑sqlite o expo‑sqlite |
|---|---|---|
| Funcionamiento 100 % offline | Nativo; binario AOT sin puente JS | Bueno; el motor corre en Hermes |
| Seguridad de unidades sin coste en ejecución | **Extension types** (Dart ≥ 3.3): `Celsius` y `Kelvin` son tipos distintos en compilación y `double` en ejecución | *Branded types*: solo en compilación, se pueden saltar con `as` |
| Enumeraciones y resultados exhaustivos | `sealed class` + `switch` exhaustivo comprobado por el compilador | Uniones discriminadas: buenas, pero `strict` es opcional |
| Versión de SQLite | `sqlite3_flutter_libs` empaqueta un SQLite reciente (≥ 3.45) en Android e iOS: permite tablas `STRICT`, `json_valid`, `RETURNING` | En Android, el SQLite del sistema varía con la versión del SO, salvo que se empaquete uno |
| Esquema, consultas y migraciones con tipos | drift: SQL comprobado al compilar, migraciones con *schema dumps* y tests de migración generados | Kysely o Drizzle: posible, menos integrado en móvil |
| Probar el motor sin dispositivo | `dart test` en CI, sin Flutter | `vitest` o `jest`, igual de fácil |
| Reutilizar el motor en un panel web futuro | Posible (Dart → JS/Wasm), menos habitual | **Ventaja de TS** |

El factor decisivo son los tipos de unidad sin coste, la exhaustividad comprobada y tener un SQLite fijo y moderno en todos los dispositivos. Con eso, una clase entera de errores (mezclar °C con K, o g con kg, olvidar un estado del semáforo) se queda en errores de compilación. Si el panel web de administración llega a ser prioritario, el motor en Dart puro se puede compilar a JS/Wasm; no hace falta reescribirlo.

---

## 2. Principios de diseño del motor

1. **Funciones puras y deterministas.** El paquete `motor_calculo` no hace E/S, no lee el reloj, no genera aleatorios y no tiene estado global mutable. La misma entrada produce siempre la misma salida, bit a bit.
2. **El tiempo es una entrada.** Los instantes (`t0` de la mezcla, momento de la lectura) llegan como parámetros. El reloj vive en la capa de casos de uso (puerto `Reloj`).
3. **Sin redondeos intermedios.** Se calcula en `double` (IEEE‑754). Solo se redondea en dos sitios: (a) las masas a pesar, al múltiplo de la resolución de la báscula, con política *half away from zero* (`double.round()` de Dart); (b) la presentación, que es cosa de la UI.
4. **Errores ≠ avisos.** Un **error** impide el resultado (dato inválido o fuera de dominio). Un **aviso** acompaña a un resultado válido. Ambos son **códigos** con parámetros, nunca texto: el texto lo pone la capa de presentación desde un catálogo i18n versionado.
5. **Parámetros versionados.** Los umbrales y constantes normativos (3,0 / 3,8 °C, 3 kg, 50 %, 2 %, coeficientes de Magnus, $E_a$ por familia) se agrupan en un objeto inmutable `ParametrosMotor` con versión semántica. Cada resultado guardado registra la versión del motor y la de los parámetros.
6. **Las fichas técnicas mandan.** El motor nunca inventa un dato del fabricante. Si falta un dato obligatorio, falla. Si usa un valor por defecto permitido (D4.a), lo marca con un aviso.
7. **Validar en la frontera.** Los constructores de los tipos de valor validan rangos físicos (HR en (0, 100], fracciones en (0, 1], densidades en [0,7; 2,5]). Dentro del motor, un valor tipado ya es válido.

---

## 3. Estructura de paquetes y dependencias

```
/docs
/packages
  /motor_calculo           Dart puro, sin dependencias de runtime (solo `meta`)
    lib/src/comun/          Resultado, Aviso, Error, ParametrosMotor, versión
    lib/src/unidades/       extension types de magnitudes físicas
    lib/src/psicrometria/   Magnus‑AERK, punto de rocío, semáforo D1
    lib/src/pot_life/       modelo Arrhenius por tramos D4.a, regla de masa D4
    lib/src/mezcla/         relación de mezcla, peso↔volumen, planificación de lote, báscula D3
    lib/src/rendimiento/    espesores, consumo, merma D2, kits, dilución
    test/golden/            fixtures JSON con los casos de la fase 1
  /dominio_obra            entidades, agregados, casos de uso, puertos (depende de motor_calculo)
  /persistencia_sqlite     drift: tablas, DAOs, migraciones, adaptadores de los puertos
/app                       Flutter (fuera del alcance de esta fase)
```

Regla de dependencias (arquitectura hexagonal):

```
app  ──►  persistencia_sqlite  ──►  dominio_obra  ──►  motor_calculo
 └──────────────────────────────►  dominio_obra
```

`motor_calculo` no conoce entidades ni la base de datos. `dominio_obra` define los puertos (`RepositorioFichas`, `RepositorioPartes`, `Reloj`, `GeneradorId`) y `persistencia_sqlite` los implementa. Un lint de CI (`dependency_validator` o una regla de import en `analysis_options.yaml`) impide los imports en sentido contrario.

---

## 4. Tipos base: unidades, resultados y avisos

### 4.1 Magnitudes (extension types)

| Tipo | Representación | Invariante (validado en el constructor) |
|---|---|---|
| `Celsius` | `double` | $-50 \le x \le 100$ |
| `Kelvin` | `double` | $x > 0$ (solo interno a `pot_life`) |
| `HumedadRelativa` | `double` (%) | $0 < x \le 100$ |
| `DiferenciaK` | `double` | — (márgenes $\Delta T$) |
| `Gramos` | **`int`** | $x \ge 0$ (masas a pesar y pesadas reales) |
| `Kilogramos` | `double` | $x \ge 0$ (masas de cálculo y pedidos) |
| `DensidadKgL` | `double` | $0.7 \le x \le 2.5$ |
| `Fraccion` | `double` | $0 < x \le 1$ (sólidos en volumen, fracciones másicas) |
| `Merma` | `double` | $0 \le x < 1$ |
| `Micrometros` | `double` | $x > 0$ |
| `MetrosCuadrados` | `double` | $x > 0$ |
| `EnergiaActivacion` | `double` (J/mol) | $x > 0$ |
| `Minutos` | `double` | $x > 0$ |
| `InstanteUtc` | `int` (ms desde epoch, UTC) | — |

Las conversiones son explícitas (`celsius.aKelvin()`, `gramos.aKilogramos()`). No hay operadores entre tipos distintos.

### 4.2 Resultado

```dart
// CONTRATO — no es implementación
sealed class Resultado<T> { }
final class Ok<T> extends Resultado<T> {
  final T valor;
  final List<Aviso> avisos;          // puede estar vacía
}
final class Fallo<T> extends Resultado<T> {
  final List<ErrorDominio> errores;  // nunca vacía
}

final class Aviso       { final CodigoAviso codigo; final Map<String, Object> params; }
final class ErrorDominio { final CodigoError codigo; final Map<String, Object> params; }
```

### 4.3 Catálogo de códigos (v1)

| Código | Tipo | Origen | Cuándo |
|---|---|---|---|
| `HR_FUERA_DE_RANGO` | Error | §1.5 | $\phi \le 0$ o $\phi > 100$ |
| `T_FUERA_DE_RANGO_VALIDADO` | Aviso | §1.5 | $T \notin [0, 50]$ °C |
| `T_ROCIO_BAJO_CERO` | Aviso | Amb. 1.1 | $T_d < 0$ °C |
| `MARGEN_ROCIO_INSUFICIENTE` | Motivo de ROJO | D1 | $\Delta T < U$ |
| `MARGEN_ROCIO_LIMITE` | Motivo de ÁMBAR | D1 | $U \le \Delta T < U + 0.8$ |
| `T_SUSTRATO_BAJO_MINIMO` | Motivo de ROJO | D1.b | $T_s < T_{s,min}$ |
| `HR_SOBRE_MAXIMO` | Motivo de ROJO | D1.b | $\phi > \phi_{max}$ |
| `HUMEDAD_SOPORTE_EXCESIVA` | Motivo de ROJO | D1.b | humedad > máximo de la ficha |
| `FICHA_INCONSISTENTE` | Error | D4.a | pot life no estrictamente decreciente con $T$ |
| `FICHA_SIN_PUNTO_TREF` | Error | Amb. 2.2 | no hay ningún punto en $T_{ref}$ |
| `FUERA_DE_RANGO_FICHA` | Error | D4.a | $T_{mat} \notin [T_{min}, T_{max}]$ de aplicación |
| `EXTRAPOLACION` | Aviso | D4.a | $T_{mat}$ fuera del intervalo de los puntos |
| `EA_ATIPICA` | Aviso | D4.a | $E_{a,i} \notin [25, 90]$ kJ/mol |
| `ESTIMACION_EA_FAMILIA` | Aviso | D4.a | solo 1 punto en la ficha |
| `ALERTA_EFECTO_MASA` | Aviso + temporizador | D4 | $m_{lote} > 3.0$ kg |
| `ERROR_RELACION_EXCEDIDO` | Error | D3 | $\lvert\varepsilon\rvert > 0.02$ tras redondear |
| `ALERTA_RESOLUCION_BASCULA` | Aviso | D3, D3.a | minoritario < $d/\varepsilon_{max}$ |
| `DOSIFICAR_POR_PESO` | Aviso | Amb. 3.2 | $\rho_i > 1.5$ kg/L |
| `SV_NO_DISPONIBLE` | Error | Amb. 3.5 | cálculo de espesor sin sólidos en volumen |
| `MERMA_ELEVADA` | Aviso (requiere confirmación) | D2 | $p \ge 0.5$ |
| `ENVASE_INSUFICIENTE` | Aviso | §3.3 | el modo "por envases" deja sobrante del otro componente |

---

## 5. Contratos de los módulos de cálculo

Todos son funciones de nivel superior o métodos de objetos inmutables, y todos reciben `ParametrosMotor` de forma explícita.

### 5.1 `psicrometria`

```dart
// CONTRATO
double presionSaturacionHpa(Celsius t, ParametrosMotor p);           // Magnus‑AERK
Resultado<Celsius> puntoRocio(Celsius tAire, HumedadRelativa hr, ParametrosMotor p);

final class LimitesSustrato {            // procede de la ficha (pueden ser null)
  final DiferenciaK? margenMinimoProducto;      // U_prod
  final Celsius? tSustratoMin;
  final HumedadRelativa? hrMax;
  final double? humedadSoporteMaxPct;
}
final class LecturaCondiciones {
  final Celsius tAire; final HumedadRelativa hr; final Celsius tSustrato;
  final double? humedadSoportePct;
}
enum Semaforo { rojo, ambar, verde }
final class EvaluacionSustrato {
  final Celsius tRocio; final DiferenciaK margen; final DiferenciaK umbralAplicado; // U
  final Semaforo estado; final List<CodigoAviso> motivos;   // por qué no es verde
}
Resultado<EvaluacionSustrato> evaluarSustrato(
    LecturaCondiciones l, LimitesSustrato lim, ParametrosMotor p);
```

Algoritmo de `evaluarSustrato`: (1) $T_d$; (2) $U = \max(p.margenBase, U_{prod})$; (3) se clasifica $\Delta T$ con $\varepsilon = 10^{-9}$ (D1); (4) se evalúan los límites duros (D1.b), que fuerzan ROJO; (5) el estado final es el peor de (3) y (4), y `motivos` acumula todos los códigos.

### 5.2 `pot_life`

```dart
// CONTRATO
final class PuntoPotLife { final Celsius t; final Minutos minutos; }
enum FamiliaQuimica { epoxiAmina, epoxiPoliamida, epoxiFenalcamina, pu2k, otro }

final class ModeloPotLife {               // inmutable, construido y validado una vez por ficha
  static Resultado<ModeloPotLife> desdeFicha({
    required List<PuntoPotLife> puntos,   // ≥ 1, debe incluir T_ref
    required Celsius tRef,                // 20 o 23 (obligatoria)
    required FamiliaQuimica familia,
    EnergiaActivacion? eaDeclarada,
    required Celsius tAplicacionMin, required Celsius tAplicacionMax,
    required ParametrosMotor p,
  });
  Resultado<PotLifeCalculado> potLife(Celsius tMaterial);
}
enum OrigenPotLife { puntosFicha, eaDeclarada, eaFamilia }
final class PotLifeCalculado {
  final Minutos minutos; final OrigenPotLife origen;
  final EnergiaActivacion eaAplicada; final bool extrapolado;
}

final class PlanTemporizadores {
  final InstanteUtc finPotLife;
  final InstanteUtc? alertaEfectoMasa;    // null si m ≤ 3 kg
}
PlanTemporizadores planificarTemporizadores({
  required InstanteUtc t0, required PotLifeCalculado potLife,
  required Kilogramos masaLote,           // total A+B(+C), D4.b
  required ParametrosMotor p,
});
```

Las notificaciones locales las programa la app con `PlanTemporizadores`. El motor solo calcula los instantes.

### 5.3 `mezcla`

```dart
// CONTRATO
enum Rol { a, b, c }
enum BaseRelacion { masa, volumen }
final class ComponenteDeclarado { final Rol rol; final double partes; final DensidadKgL densidad; }

final class RelacionMezcla {              // normalizada siempre a fracciones másicas
  static Resultado<RelacionMezcla> desdeDeclaracion(
      BaseRelacion base, List<ComponenteDeclarado> componentes);   // A y B obligatorios
  Map<Rol, Fraccion> get fraccionesMasa;
  Map<Rol, double>   get partesVolumen;   // normalizadas a A = 100
  DensidadKgL densidadMezclaIdeal();      // media armónica, §3.2
}

sealed class RestriccionLote { }
final class FijarComponente extends RestriccionLote { final Rol rol; final Kilogramos masa; }
final class FijarTotal      extends RestriccionLote { final Kilogramos masa; }
final class FijarVolumen    extends RestriccionLote { final Rol? rol; final double litros; } // rol null = volumen total
final class LimitarPorEnvases extends RestriccionLote { final Map<Rol, Kilogramos> disponible; }

final class Bascula { final Gramos resolucion; }

final class PlanLote {
  final Map<Rol, Gramos> masasAPesar;     // ya redondeadas a la resolución
  final Map<Rol, double> masasExactasKg;
  final Gramos masaTotal;
  final double errorRelacion;             // ε de §3.3 (peor par respecto de A)
  final Map<Rol, double>? volumenesL;     // solo informativos
}
Resultado<PlanLote> planificarLote(RelacionMezcla r, RestriccionLote c, Bascula b,
    {Fraccion? toleranciaProducto, required ParametrosMotor p});

/// Comprobación a posteriori con lo realmente pesado (se guarda en el parte).
Resultado<double> errorRelacionReal(RelacionMezcla r, Map<Rol, Gramos> pesadasReales);
```

### 5.4 `rendimiento`

```dart
// CONTRATO
Micrometros espesorHumedo(Micrometros seco, Fraccion sv);
double rendimientoTeoricoM2PorL(Micrometros seco, Fraccion sv);
double consumoKgM2PorEspesor(Micrometros seco, Fraccion sv, DensidadKgL rhoMezcla);
Fraccion solidosTrasDilucionVolumen(Fraccion sv, double fraccionDiluyenteVol);
Fraccion solidosTrasDilucionMasa(Fraccion sv, Kilogramos masaMezcla, DensidadKgL rhoMezcla,
    double fraccionDiluyenteMasa, DensidadKgL rhoDiluyente);

sealed class Consumo { }
final class ConsumoPorEspesor extends Consumo { final Micrometros seco; final Fraccion sv; final DensidadKgL rho; }
final class ConsumoDirecto    extends Consumo { final double kgM2; }   // imprimaciones, espolvoreos (Amb. 3.7)

final class Pedido {
  final double consumoKgM2; final Kilogramos teorico; final Kilogramos bruto;  // bruto = teórico/(1−p)
  final int? numeroKits; final Kilogramos? sobrante;
}
Resultado<Pedido> calcularPedido(MetrosCuadrados s, Consumo c, Merma p, {Kilogramos? masaKit});
```

### 5.5 Casos de uso (capa `dominio_obra`)

| Caso de uso | Entradas | Usa | Persiste |
|---|---|---|---|
| `PublicarFicha` | ficha en borrador | `ModeloPotLife.desdeFicha`, `RelacionMezcla.desdeDeclaracion` | estado `PUBLICADA` (a partir de ahí, inmutable) |
| `RegistrarLecturaAmbiental` | parte, lectura, ficha opcional | `evaluarSustrato` | `lectura_ambiental` + instantánea |
| `CalcularCapa` | parte, ficha, superficie, espesor o consumo, merma, kit | `calcularPedido` | `capa` + instantánea |
| `PlanificarLote` | parte, ficha, restricción, báscula, $T_{mat}$, `t0` del `Reloj` | `planificarLote`, `potLife`, `planificarTemporizadores` | `lote_mezcla`, `pesada` (objetivo) + instantánea |
| `RegistrarPesadaReal` | lote, pesadas reales, lote de fabricante | `errorRelacionReal` | `pesada.masa_real_g` + instantánea |
| `CerrarParte` | parte | hash canónico (§9) | estado `CERRADO`, `hash_cierre` |
| `CorregirParte` | parte cerrado, motivo | — | parte nuevo con `corrige_parte_id` |

---

## 6. Parámetros del motor versionados

`ParametrosMotor.v1` (constante en código, **no** en base de datos, para que el cálculo no dependa de datos editables):

| Clave | Valor v1 | Fuente |
|---|---|---|
| `magnus.a`, `magnus.b`, `magnus.c` | 17.625, 243.04 °C, 6.1094 hPa | §1.3 |
| `rocio.margenBase` | 3.0 K | D1 |
| `rocio.anchoAmbar` | 0.8 K | D1 |
| `comparacion.epsilon` | 1e‑9 | §1.4 |
| `R` | 8.314462618 J/(mol·K) | CODATA |
| `ea.familia` | epoxiAmina 55 000; epoxiPoliamida 50 000; epoxiFenalcamina 45 000; pu2k 50 000; otro 55 000 J/mol | §2.2 |
| `ea.rangoNormal` | [25 000, 90 000] J/mol | D4.a |
| `masa.umbralAlerta` | 3.0 kg (estricto >) | D4 |
| `masa.fraccionAlerta` | 0.5 | D4 |
| `mezcla.toleranciaMax` | 0.02 | D3 |
| `mezcla.rhoDosificarPorPeso` | 1.5 kg/L | Amb. 3.2 |
| `merma.umbralConfirmacion` | 0.5 | D2 |
| `textoLegal.disclaimerPotLife` | id `DISC-POTLIFE-1` | D4 |

Política de versiones: cambiar un valor o una fórmula sube la versión de `ParametrosMotor` y la del paquete del motor, y obliga a regenerar los fixtures golden con una revisión explícita. Los partes antiguos **no se recalculan**: conservan su instantánea (§9).

---

## 7. Modelo de dominio: entidades y agregados

```
CATÁLOGO                                   OBRA
────────                                   ────
Fabricante 1─* Producto                    Obra 1─* ParteTrabajo  (raíz de agregado)
Producto   1─* FichaTecnica (versionada)            ParteTrabajo 1─* LecturaAmbiental
FichaTecnica 1─* ComponenteFicha (A,B,C)            ParteTrabajo 1─* Capa
FichaTecnica 1─* PuntoPotLife                       ParteTrabajo 1─* LoteMezcla
FichaTecnica 1─* Kit 1─* KitComponente              LoteMezcla  1─* Pesada (por rol)
FichaTecnica 1─* ConsumoReferencia                  Lectura/Capa/Lote ──► FichaTecnica (versión exacta)
                                                    Lectura/Capa/Lote ──► InstantaneaCalculo
```

Reglas de agregado:

- **FichaTecnica** pasa por `BORRADOR → PUBLICADA → RETIRADA`. Solo una ficha en `BORRADOR` se puede editar. Para corregir una ficha publicada se crea una versión nueva. Una ficha retirada sigue resoluble para los partes antiguos.
- Invariantes al publicar: componentes A y B presentes; al menos un `PuntoPotLife` y uno de ellos en $T_{ref}$; $T_{ref} \in \{20, 23\}$; `ModeloPotLife.desdeFicha` devuelve `Ok`; $T_{min} < T_{max}$; si hay `ConsumoPorEspesor`, también $SV$.
- **ParteTrabajo** pasa por `ABIERTO → CERRADO`. Al cerrarlo, él y todos sus hijos quedan inmutables (triggers, §8). Las correcciones se hacen con un parte nuevo que referencia al original.
- Los registros de obra apuntan a la **versión concreta de la ficha** (`ficha_id`), no al producto, para que el cálculo sea reproducible.

---

## 8. Esquema SQLite

Convenciones:

- `PRAGMA foreign_keys = ON;` en cada conexión. Versión de esquema en `PRAGMA user_version` (gestionada por drift).
- Todas las tablas son `STRICT`.
- Identificadores `TEXT` con **UUIDv7**: se generan offline, se ordenan por tiempo y están preparados para una sincronización futura sin colisiones.
- Instantes: `INTEGER` en ms UTC. Fechas de calendario: `TEXT` en ISO‑8601 (`YYYY-MM-DD`). La zona horaria IANA se guarda en `obra`.
- Unidades en el nombre de la columna (`_c`, `_kg_l`, `_g`, `_um`, `_frac`, `_pct`, `_j_mol`, `_min`, `_m2`).
- Masas a pesar y pesadas reales en **gramos enteros**.
- Enumeraciones como `TEXT` con `CHECK`. JSON como `TEXT` con `CHECK (json_valid(...))`.

### 8.1 Catálogo

```sql
CREATE TABLE fabricante (
  id              TEXT PRIMARY KEY,
  nombre          TEXT NOT NULL UNIQUE,
  creado_en       INTEGER NOT NULL,
  actualizado_en  INTEGER NOT NULL
) STRICT;

CREATE TABLE producto (
  id               TEXT PRIMARY KEY,
  fabricante_id    TEXT NOT NULL REFERENCES fabricante(id),
  nombre_comercial TEXT NOT NULL,
  familia          TEXT NOT NULL CHECK (familia IN
                     ('EPOXI_AMINA','EPOXI_POLIAMIDA','EPOXI_FENALCAMINA','PU_2K','OTRO')),
  funcion          TEXT NOT NULL CHECK (funcion IN
                     ('IMPRIMACION','CAPA_BASE','AUTONIVELANTE','MORTERO','SELLADO','ACABADO','OTRO')),
  origen           TEXT NOT NULL CHECK (origen IN ('CATALOGO','USUARIO')),
  archivado        INTEGER NOT NULL DEFAULT 0 CHECK (archivado IN (0,1)),
  creado_en        INTEGER NOT NULL,
  actualizado_en   INTEGER NOT NULL,
  UNIQUE (fabricante_id, nombre_comercial)
) STRICT;

CREATE TABLE ficha_tecnica (
  id                       TEXT PRIMARY KEY,
  producto_id              TEXT NOT NULL REFERENCES producto(id),
  version_etiqueta         TEXT NOT NULL,                 -- p. ej. "Ed. 03/2025"
  fecha_emision            TEXT,                          -- ISO-8601
  fuente_uri               TEXT,
  fuente_sha256            TEXT,                          -- hash del PDF de la TDS original
  estado                   TEXT NOT NULL DEFAULT 'BORRADOR'
                             CHECK (estado IN ('BORRADOR','PUBLICADA','RETIRADA')),
  base_relacion            TEXT NOT NULL CHECK (base_relacion IN ('MASA','VOLUMEN')),
  densidad_mezcla_kg_l     REAL CHECK (densidad_mezcla_kg_l BETWEEN 0.7 AND 2.5),
  solidos_volumen_frac     REAL CHECK (solidos_volumen_frac > 0 AND solidos_volumen_frac <= 1),
  t_ref_c                  REAL NOT NULL CHECK (t_ref_c IN (20.0, 23.0)),
  ea_declarada_j_mol       REAL CHECK (ea_declarada_j_mol > 0),
  t_aplicacion_min_c       REAL NOT NULL,
  t_aplicacion_max_c       REAL NOT NULL,
  t_sustrato_min_c         REAL,
  hr_max_pct               REAL CHECK (hr_max_pct > 0 AND hr_max_pct <= 100),
  margen_rocio_min_k       REAL NOT NULL DEFAULT 3.0 CHECK (margen_rocio_min_k >= 3.0),
  humedad_soporte_max_pct  REAL CHECK (humedad_soporte_max_pct > 0),
  tolerancia_mezcla_frac   REAL NOT NULL DEFAULT 0.02
                             CHECK (tolerancia_mezcla_frac > 0 AND tolerancia_mezcla_frac <= 0.02),
  pot_life_condiciones     TEXT,                          -- informativo (masa/régimen), no se usa en cálculo (D4)
  publicada_en             INTEGER,
  creado_en                INTEGER NOT NULL,
  actualizado_en           INTEGER NOT NULL,
  CHECK (t_aplicacion_min_c < t_aplicacion_max_c),
  CHECK ((estado = 'BORRADOR') = (publicada_en IS NULL)),
  UNIQUE (producto_id, version_etiqueta)
) STRICT;

CREATE TABLE componente_ficha (
  id             TEXT PRIMARY KEY,
  ficha_id       TEXT NOT NULL REFERENCES ficha_tecnica(id) ON DELETE CASCADE,
  rol            TEXT NOT NULL CHECK (rol IN ('A','B','C')),
  descripcion    TEXT,
  partes         REAL NOT NULL CHECK (partes > 0),          -- en la base declarada (masa o volumen)
  densidad_kg_l  REAL NOT NULL CHECK (densidad_kg_l BETWEEN 0.7 AND 2.5),
  UNIQUE (ficha_id, rol)
) STRICT;

CREATE TABLE punto_pot_life (
  id             TEXT PRIMARY KEY,
  ficha_id       TEXT NOT NULL REFERENCES ficha_tecnica(id) ON DELETE CASCADE,
  temperatura_c  REAL NOT NULL,
  minutos        REAL NOT NULL CHECK (minutos > 0),
  UNIQUE (ficha_id, temperatura_c)
) STRICT;

CREATE TABLE kit (
  id           TEXT PRIMARY KEY,
  ficha_id     TEXT NOT NULL REFERENCES ficha_tecnica(id) ON DELETE CASCADE,
  descripcion  TEXT NOT NULL
) STRICT;

CREATE TABLE kit_componente (
  kit_id  TEXT NOT NULL REFERENCES kit(id) ON DELETE CASCADE,
  rol     TEXT NOT NULL CHECK (rol IN ('A','B','C')),
  masa_g  INTEGER NOT NULL CHECK (masa_g > 0),
  PRIMARY KEY (kit_id, rol)
) STRICT;

CREATE TABLE consumo_referencia (
  id                 TEXT PRIMARY KEY,
  ficha_id           TEXT NOT NULL REFERENCES ficha_tecnica(id) ON DELETE CASCADE,
  tipo               TEXT NOT NULL CHECK (tipo IN ('POR_ESPESOR','DIRECTO')),
  espesor_seco_um    REAL CHECK (espesor_seco_um > 0),
  consumo_kg_m2      REAL CHECK (consumo_kg_m2 > 0),
  notas              TEXT,
  CHECK ((tipo = 'POR_ESPESOR' AND espesor_seco_um IS NOT NULL)
      OR (tipo = 'DIRECTO'     AND consumo_kg_m2  IS NOT NULL))
) STRICT;

CREATE INDEX ix_producto_fabricante ON producto(fabricante_id);
CREATE INDEX ix_ficha_producto      ON ficha_tecnica(producto_id, estado);
```

### 8.2 Obra y partes

```sql
CREATE TABLE obra (
  id              TEXT PRIMARY KEY,
  nombre          TEXT NOT NULL,
  cliente         TEXT,
  direccion       TEXT,
  zona_horaria    TEXT NOT NULL,                 -- IANA, p. ej. "Europe/Madrid"
  latitud         REAL CHECK (latitud BETWEEN -90 AND 90),
  longitud        REAL CHECK (longitud BETWEEN -180 AND 180),
  archivado       INTEGER NOT NULL DEFAULT 0 CHECK (archivado IN (0,1)),
  creado_en       INTEGER NOT NULL,
  actualizado_en  INTEGER NOT NULL
) STRICT;

CREATE TABLE parte_trabajo (
  id                  TEXT PRIMARY KEY,
  obra_id             TEXT NOT NULL REFERENCES obra(id),
  fecha_local         TEXT NOT NULL,             -- YYYY-MM-DD en la zona de la obra
  responsable         TEXT,
  estado              TEXT NOT NULL DEFAULT 'ABIERTO' CHECK (estado IN ('ABIERTO','CERRADO')),
  corrige_parte_id    TEXT REFERENCES parte_trabajo(id),
  motivo_correccion   TEXT,
  cerrado_en          INTEGER,
  hash_cierre         TEXT,                      -- SHA-256 hex, §9
  notas               TEXT,
  creado_en           INTEGER NOT NULL,
  actualizado_en      INTEGER NOT NULL,
  CHECK ((estado = 'CERRADO') = (cerrado_en IS NOT NULL AND hash_cierre IS NOT NULL)),
  CHECK ((corrige_parte_id IS NULL) = (motivo_correccion IS NULL))
) STRICT;

CREATE TABLE instantanea_calculo (               -- append-only
  id                   TEXT PRIMARY KEY,
  tipo                 TEXT NOT NULL CHECK (tipo IN ('SUSTRATO','CAPA','LOTE','PESADA_REAL')),
  motor_version        TEXT NOT NULL,            -- semver del paquete motor_calculo
  parametros_version   TEXT NOT NULL,            -- versión de ParametrosMotor
  entradas_json        TEXT NOT NULL CHECK (json_valid(entradas_json)),
  salidas_json         TEXT NOT NULL CHECK (json_valid(salidas_json)),
  sha256               TEXT NOT NULL,            -- hash de entradas+salidas canónicas
  creado_en            INTEGER NOT NULL
) STRICT;

CREATE TABLE lectura_ambiental (
  id                    TEXT PRIMARY KEY,
  parte_id              TEXT NOT NULL REFERENCES parte_trabajo(id),
  ficha_id              TEXT REFERENCES ficha_tecnica(id),   -- límites de producto usados (opcional)
  instante              INTEGER NOT NULL,
  t_aire_c              REAL NOT NULL,
  hr_pct                REAL NOT NULL CHECK (hr_pct > 0 AND hr_pct <= 100),
  t_sustrato_c          REAL NOT NULL,
  metodo_t_sustrato     TEXT NOT NULL CHECK (metodo_t_sustrato IN ('CONTACTO','IR','DESCONOCIDO')),
  humedad_soporte_pct   REAL,
  instrumento           TEXT,
  -- resultados desnormalizados para consultas; la fuente de verdad es la instantánea
  t_rocio_c             REAL NOT NULL,
  margen_k              REAL NOT NULL,
  semaforo              TEXT NOT NULL CHECK (semaforo IN ('ROJO','AMBAR','VERDE')),
  instantanea_id        TEXT NOT NULL REFERENCES instantanea_calculo(id)
) STRICT;

CREATE TABLE capa (
  id                     TEXT PRIMARY KEY,
  parte_id               TEXT NOT NULL REFERENCES parte_trabajo(id),
  ficha_id               TEXT NOT NULL REFERENCES ficha_tecnica(id),
  orden                  INTEGER NOT NULL CHECK (orden >= 1),
  superficie_m2          REAL NOT NULL CHECK (superficie_m2 > 0),
  modo_consumo           TEXT NOT NULL CHECK (modo_consumo IN ('POR_ESPESOR','DIRECTO')),
  espesor_seco_um        REAL CHECK (espesor_seco_um > 0),
  consumo_kg_m2          REAL NOT NULL CHECK (consumo_kg_m2 > 0),
  merma_frac             REAL NOT NULL CHECK (merma_frac >= 0 AND merma_frac < 1),
  masa_teorica_g         INTEGER NOT NULL,
  masa_bruta_g           INTEGER NOT NULL,
  kits                   INTEGER,
  instantanea_id         TEXT NOT NULL REFERENCES instantanea_calculo(id),
  UNIQUE (parte_id, orden)
) STRICT;

CREATE TABLE lote_mezcla (
  id                      TEXT PRIMARY KEY,
  parte_id                TEXT NOT NULL REFERENCES parte_trabajo(id),
  capa_id                 TEXT REFERENCES capa(id),
  ficha_id                TEXT NOT NULL REFERENCES ficha_tecnica(id),
  instante_mezcla         INTEGER NOT NULL,       -- t0
  t_material_c            REAL NOT NULL,
  tipo_restriccion        TEXT NOT NULL CHECK (tipo_restriccion IN
                            ('FIJAR_COMPONENTE','FIJAR_TOTAL','FIJAR_VOLUMEN','LIMITAR_ENVASES')),
  resolucion_bascula_g    INTEGER NOT NULL CHECK (resolucion_bascula_g > 0),
  masa_total_objetivo_g   INTEGER NOT NULL CHECK (masa_total_objetivo_g > 0),
  pot_life_min            REAL NOT NULL CHECK (pot_life_min > 0),
  origen_pot_life         TEXT NOT NULL CHECK (origen_pot_life IN ('PUNTOS_FICHA','EA_DECLARADA','EA_FAMILIA')),
  instante_fin_pot_life   INTEGER NOT NULL,
  alerta_masa             INTEGER NOT NULL CHECK (alerta_masa IN (0,1)),
  instante_alerta_masa    INTEGER,
  error_relacion_real     REAL,                   -- se rellena tras registrar pesadas reales
  instantanea_id          TEXT NOT NULL REFERENCES instantanea_calculo(id),
  CHECK ((alerta_masa = 1) = (instante_alerta_masa IS NOT NULL)),
  CHECK (instante_fin_pot_life > instante_mezcla)
) STRICT;

CREATE TABLE pesada (
  lote_id            TEXT NOT NULL REFERENCES lote_mezcla(id),
  rol                TEXT NOT NULL CHECK (rol IN ('A','B','C')),
  masa_objetivo_g    INTEGER NOT NULL CHECK (masa_objetivo_g > 0),
  masa_real_g        INTEGER CHECK (masa_real_g > 0),
  lote_fabricante    TEXT,                        -- nº de lote impreso en el envase
  PRIMARY KEY (lote_id, rol)
) STRICT;

CREATE TABLE texto_legal (
  id               TEXT PRIMARY KEY,              -- p. ej. 'DISC-POTLIFE-1'
  idioma           TEXT NOT NULL,
  texto            TEXT NOT NULL,
  vigente_desde    INTEGER NOT NULL
) STRICT;

CREATE INDEX ix_parte_obra     ON parte_trabajo(obra_id, fecha_local);
CREATE INDEX ix_lectura_parte  ON lectura_ambiental(parte_id, instante);
CREATE INDEX ix_capa_parte     ON capa(parte_id);
CREATE INDEX ix_lote_parte     ON lote_mezcla(parte_id, instante_mezcla);
```

### 8.3 Triggers de inmutabilidad

```sql
-- Fichas: solo se editan en BORRADOR; de PUBLICADA solo se permite pasar a RETIRADA.
CREATE TRIGGER tr_ficha_inmutable
BEFORE UPDATE ON ficha_tecnica
WHEN OLD.estado <> 'BORRADOR'
 AND NOT (OLD.estado = 'PUBLICADA' AND NEW.estado = 'RETIRADA'
          AND NEW.t_ref_c IS OLD.t_ref_c AND NEW.base_relacion IS OLD.base_relacion
          AND NEW.densidad_mezcla_kg_l IS OLD.densidad_mezcla_kg_l
          AND NEW.solidos_volumen_frac IS OLD.solidos_volumen_frac
          AND NEW.ea_declarada_j_mol IS OLD.ea_declarada_j_mol
          AND NEW.t_aplicacion_min_c IS OLD.t_aplicacion_min_c
          AND NEW.t_aplicacion_max_c IS OLD.t_aplicacion_max_c
          AND NEW.t_sustrato_min_c IS OLD.t_sustrato_min_c
          AND NEW.hr_max_pct IS OLD.hr_max_pct
          AND NEW.margen_rocio_min_k IS OLD.margen_rocio_min_k
          AND NEW.humedad_soporte_max_pct IS OLD.humedad_soporte_max_pct
          AND NEW.tolerancia_mezcla_frac IS OLD.tolerancia_mezcla_frac)
BEGIN SELECT RAISE(ABORT, 'FICHA_NO_EDITABLE'); END;

-- Hijos de la ficha (patrón repetido para componente_ficha, punto_pot_life, kit, consumo_referencia):
CREATE TRIGGER tr_punto_pot_life_ins BEFORE INSERT ON punto_pot_life
WHEN (SELECT estado FROM ficha_tecnica WHERE id = NEW.ficha_id) <> 'BORRADOR'
BEGIN SELECT RAISE(ABORT, 'FICHA_NO_EDITABLE'); END;
-- (+ BEFORE UPDATE y BEFORE DELETE equivalentes con OLD.ficha_id)

-- Partes cerrados: ni el parte ni sus hijos se modifican.
CREATE TRIGGER tr_parte_cerrado BEFORE UPDATE ON parte_trabajo
WHEN OLD.estado = 'CERRADO'
BEGIN SELECT RAISE(ABORT, 'PARTE_CERRADO'); END;

CREATE TRIGGER tr_parte_cerrado_del BEFORE DELETE ON parte_trabajo
WHEN OLD.estado = 'CERRADO'
BEGIN SELECT RAISE(ABORT, 'PARTE_CERRADO'); END;
-- (+ BEFORE INSERT/UPDATE/DELETE en lectura_ambiental, capa, lote_mezcla y pesada,
--    resolviendo el parte por la FK correspondiente)

-- Instantáneas: solo inserción.
CREATE TRIGGER tr_instantanea_upd BEFORE UPDATE ON instantanea_calculo
BEGIN SELECT RAISE(ABORT, 'INSTANTANEA_INMUTABLE'); END;
CREATE TRIGGER tr_instantanea_del BEFORE DELETE ON instantanea_calculo
BEGIN SELECT RAISE(ABORT, 'INSTANTANEA_INMUTABLE'); END;
```

Las invariantes que SQL no puede expresar bien (A y B presentes, punto en $T_{ref}$, monotonía del pot life) las valida el caso de uso `PublicarFicha` con el motor, dentro de una transacción.

---

## 9. Trazabilidad e integridad legal

Pensado para el escenario de reclamación (D4):

1. **Instantánea por cálculo.** Cada evaluación guardada lleva sus entradas y salidas completas, la versión del motor y la de los parámetros. Recalcular con un motor más nuevo nunca cambia un registro histórico.
2. **JSON canónico** para el hash: claves ordenadas lexicográficamente, sin espacios, UTF‑8, números con la representación más corta que vuelve al mismo `double` (`double.toString()` de Dart), instantes como enteros. `sha256 = SHA-256(canónico(entradas) || 0x1E || canónico(salidas))`.
3. **Hash de cierre del parte** = SHA‑256 de la lista ordenada de los `sha256` de sus instantáneas, más los campos del parte. Se imprime en la exportación (PDF de fase posterior) junto con el disclaimer `DISC-POTLIFE-1` y la versión de la ficha técnica (con `fuente_sha256` del PDF original del fabricante).
4. **Lote de fabricante** en cada pesada: permite cruzar una incidencia con un lote defectuoso del proveedor.
5. **Pesadas reales frente a objetivo**, con $\varepsilon$ real guardado: documenta si el error de mezcla fue del aplicador o no.

Limitación honesta: un hash local demuestra **coherencia interna**, no la fecha frente a terceros (alguien con acceso al dispositivo podría regenerar la base completa). El sellado de tiempo de terceros (RFC 3161) o la sincronización con un servidor serían una fase posterior opcional.

---

## 10. Estrategia de pruebas

| Nivel | Herramienta | Contenido | Criterio |
|---|---|---|---|
| Golden (motor) | `dart test` + fixtures JSON en `test/golden/` | P1–P10, S1–S9, P‑K1–P‑K3, P‑K9–P‑K13, M1–M7, R1–R6 de la fase 1 | Tolerancias de la especificación; el fixture cita el ID del caso |
| Propiedades (motor) | Generadores con semilla fija | $T_d$ monótona en $T$ y en $\phi$; $\phi$ = 100 ⇒ $T_d = T$; $c = \rho/R$; $\sum m_i$ = total; $\lvert\varepsilon\rvert \le d/(2\,m_{min})$ tras redondear; pot life estrictamente decreciente en $T$ y exacto en los puntos de la ficha | 10 000 casos por propiedad |
| Fronteras | Tests de tabla | $\Delta T$ = U, U + 0.8, U + 0.8 − 1e‑12; masa = 3.000 / 3.001 kg; merma = 0 / 0.5 / 0.999 | Estado exacto |
| Cobertura | `coverage` | `motor_calculo` | 100 % de ramas |
| Dominio | Repositorios en memoria | Ciclo de vida de ficha y parte, casos de uso | — |
| Persistencia | drift + SQLite en memoria | Cada `CHECK` y trigger rechaza lo que debe; tests de migración con *schema dumps* | — |
| Regresión de versión | CI | Si cambia la salida de un golden, el CI falla salvo que se suba la versión de `ParametrosMotor` | — |

Los fixtures se guardan en JSON neutro (independiente del lenguaje): si algún día se porta el motor a TypeScript, la misma batería sirve.

---

## 11. Preguntas abiertas para validar

1. **$T_{ref}$ = 25 °C.** Algunas fichas americanas usan 77 °F (25 °C). El esquema solo admite 20 y 23 °C, como indicaste. ¿Se amplía a 25 °C o se rechazan esas fichas?
2. **Quién da de alta las fichas del catálogo.** Un error al transcribir una ficha es el mayor riesgo legal que queda. Propuesta: las fichas con `origen = CATALOGO` exigen doble verificación (quien la crea y quien la revisa) antes de `PUBLICADA`, y las del usuario llevan la marca "ficha introducida por el usuario" en la exportación. ¿Hace falta el rol de revisor desde el principio?
3. **Tricomponentes (A + B + C con árido).** El modelo de datos ya los admite (`rol = 'C'`) y la masa de alerta los cuenta (D4.b). ¿Entran en el alcance de la primera versión de planificación de lotes?
4. **Resolución de báscula por defecto.** ¿5 g? ¿O se guarda un perfil de báscula por usuario o equipo?
5. **Idiomas.** El catálogo de códigos permite i18n. ¿Solo español al principio, o también catalán, portugués o inglés?
6. **Sincronización futura.** El esquema está preparado (UUIDv7, marcas de tiempo, instantáneas inmutables). ¿Se prevé un backend o un sellado de tiempo de terceros a medio plazo? Condiciona si conviene añadir ya `eliminado_en` (borrado lógico) a las tablas de catálogo.

**Fin del diseño de la fase 2.** Con tu validación, la fase 3 sería implementar `motor_calculo` con TDD a partir de los fixtures golden, sin UI.
