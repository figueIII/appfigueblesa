# Especificación técnica del motor de cálculo — Fase 1: Auditoría matemática y de dominio

> **Estado:** borrador para validación. No hay código de aplicación asociado.
> **Alcance:** (1) psicrometría y punto de rocío, (2) cinética de curado y pot life, (3) álgebra de mezclas bicomponente y rendimiento.
> **Convenciones:** SI salvo indicación. Temperaturas en °C en la interfaz de datos y en K dentro de Arrhenius ($T_K = T + 273{,}15$). Separador decimal en este documento: punto, para que coincida con los casos de prueba.
> **Verificación:** todos los valores numéricos de las tablas de prueba se han recalculado con un script independiente (doble precisión, IEEE‑754). Las tolerancias de aceptación se indican en cada tabla.

Las marcas **⚠ AMBIGÜEDAD** señalan puntos en los que una norma, una ficha técnica o la propia física dejan margen de interpretación. Cada una lleva una **propuesta de decisión** que debes validar o corregir.

---

## Índice

1. [Psicrometría y punto de rocío](#1-psicrometría-y-punto-de-rocío)
2. [Cinética de curado y modelado del pot life](#2-cinética-de-curado-y-modelado-del-pot-life)
3. [Álgebra de mezclas bicomponente (A + B) y rendimiento](#3-álgebra-de-mezclas-bicomponente-a--b-y-rendimiento)
4. [Resumen de decisiones pendientes de validación](#4-resumen-de-decisiones-pendientes-de-validación)

---

## 1. Psicrometría y punto de rocío

### 1.1 Variables de entrada

| Símbolo | Significado | Unidad | Rango válido del motor |
|---|---|---|---|
| $T$ | Temperatura del aire (bulbo seco) | °C | $0 \le T \le 50$ |
| $\phi$ | Humedad relativa del aire | % | $0 < \phi \le 100$ |
| $T_s$ | Temperatura superficial del sustrato (suelo) | °C | $-10 \le T_s \le 60$ |

### 1.2 Deducción de la forma de Magnus

La ecuación de Clausius‑Clapeyron para el equilibrio líquido–vapor del agua es

$$\frac{d \ln e_s}{dT_K} = \frac{L_v}{R_v\,T_K^2}$$

con $L_v \approx 2{,}5\cdot10^6\ \text{J/kg}$ (calor latente de vaporización) y $R_v = 461{,}5\ \text{J/(kg·K)}$ (constante específica del vapor de agua). Si $L_v$ fuese constante, la integración daría $e_s = e_0 \exp\!\left[\frac{L_v}{R_v}\left(\frac{1}{T_0} - \frac{1}{T_K}\right)\right]$. Como $L_v$ disminuye con la temperatura (~ −0,1 %/K), Magnus (1844) propuso la forma empírica

$$\boxed{e_s(T) = C \cdot \exp\!\left(\frac{a\,T}{b + T}\right)}\qquad (T\ \text{en °C},\ e_s\ \text{en hPa})$$

que es la solución de Clausius‑Clapeyron en la que el término $1/T_K$ se sustituye por $1/(b+T)$ con $b$ ajustado (≈ 243 °C en lugar de 273,15) para absorber la variación de $L_v$. El valor de $C$ es la presión de saturación a 0 °C.

La presión parcial real del vapor es

$$e = \frac{\phi}{100}\, e_s(T)$$

El **punto de rocío** $T_d$ es la temperatura a la que, enfriando a presión de vapor constante, el aire se satura: $e_s(T_d) = e$. Despejando:

$$\frac{a\,T_d}{b+T_d} = \ln\frac{e}{C} = \ln\frac{\phi}{100} + \frac{a\,T}{b+T} \equiv \gamma(T,\phi)$$

$$a\,T_d = \gamma\,(b + T_d) \;\Rightarrow\; \boxed{T_d = \frac{b\,\gamma}{a - \gamma}},\qquad \gamma = \ln\!\left(\frac{\phi}{100}\right) + \frac{a\,T}{b + T}$$

Observa que $C$ se cancela: **el punto de rocío depende solo de $a$ y $b$**. $C$ solo interviene si se quiere mostrar $e_s$ o $e$.

### 1.3 Coeficientes: elección para 0–50 °C

| Conjunto | $C$ (hPa) | $a$ | $b$ (°C) | Rango declarado | Comentario |
|---|---|---|---|---|---|
| Magnus‑Tetens (Tetens 1930, forma clásica) | 6.1078 | 17.27 | 237.3 | 0–35 °C | Histórica. Error mayor por encima de 35 °C. |
| Sonntag (1990) | 6.112 | 17.62 | 243.12 | −45 a 60 °C | Recomendada por la OMM (WMO‑No. 8) sobre agua. |
| **Alduchov & Eskridge (1996), "AERK"** | **6.1094** | **17.625** | **243.04** | **−40 a 50 °C** | **Propuesta por defecto.** Ajuste de mínimo error relativo en exactamente nuestro rango. |

**Arden Buck (1996, sobre agua)**, como referencia de mayor precisión:

$$e_s(T) = 6.1121\,\exp\!\left[\left(18.678 - \frac{T}{234.5}\right)\frac{T}{257.14 + T}\right]$$

La inversión de Buck no es lineal pero tiene solución cerrada (ecuación de segundo grado). Con $\gamma_B = \ln(e/6.1121)$:

$$\frac{T_d^2}{234.5} + (\gamma_B - 18.678)\,T_d + 257.14\,\gamma_B = 0 \;\Rightarrow\; T_d = \frac{-(\gamma_B - 18.678) - \sqrt{(\gamma_B - 18.678)^2 - 4\cdot\frac{257.14\,\gamma_B}{234.5}}}{2/234.5}$$

(se toma la raíz con signo negativo; la positiva es espuria, del orden de +4 000 °C).

**Decisión propuesta:** el motor usa **Magnus con coeficientes AERK** (forma cerrada, invertible, sin raíces espurias) y los tests cruzados verifican que la diferencia con Buck es < 0,1 °C en todo el rango de trabajo.

#### Exactitud de $e_s$ frente a la referencia IAPWS‑95 (presión de saturación del agua)

| $T$ (°C) | IAPWS (hPa) | AERK | Sonntag | Tetens | Buck 96 |
|---|---|---|---|---|---|
| 0 (0,01) | 6.117 | 6.1094 | 6.1120 | 6.1078 | 6.1121 |
| 10 | 12.282 | 12.2602 | 12.2603 | 12.2792 | 12.2786 |
| 20 | 23.393 | 23.3344 | 23.3260 | 23.3820 | 23.3834 |
| 30 | 42.470 | 42.3665 | 42.3372 | 42.4293 | 42.4513 |
| 40 | 73.849 | 73.7472 | 73.6746 | 73.7537 | 73.8236 |
| 50 | 123.52 | 123.6058 | 123.4516 | 123.3636 | 123.4940 |

Error máximo de AERK en el rango ≈ 0,25 %. Un error de 0,25 % en $e_s$ se traduce en ≈ 0,04 °C en $T_d$: despreciable frente al error del higrómetro.

⚠ **AMBIGÜEDAD 1.1 — agua o hielo por debajo de 0 °C.** Con $T \ge 0$ °C el punto de rocío calculado puede ser negativo (p. ej. 0 °C y 80 % → −3,04 °C). Físicamente sería un *punto de escarcha* (sobre hielo, coeficientes distintos: $a = 22.46$, $b = 272.62$). Pero la convención de la OMM es que los higrómetros expresan la HR **respecto al agua líquida** incluso bajo cero, y la regla de los 3 °C está pensada para condensación líquida.
**Propuesta:** usar siempre los coeficientes sobre agua. Si $T_d < 0$ °C, el motor lo devuelve tal cual y marca `T_d_bajo_cero = true` como información (no cambia la decisión).

### 1.4 Condición de seguridad del sustrato

$$\Delta T_{rocío} = T_s - T_d \qquad\qquad \text{APTO} \iff \Delta T_{rocío} \ge 3.0\ \text{°C}$$

Origen: práctica recogida en ISO 8502‑4 (estimación de la probabilidad de condensación antes de aplicar pintura) y en EN ISO 12944‑7; para pavimentos de resina la exigen prácticamente todas las fichas técnicas de los fabricantes, normalmente junto con un límite de HR (habitualmente 75–85 %) y una temperatura mínima de sustrato (habitualmente +8 a +10 °C).

⚠ **AMBIGÜEDAD 1.2 — ¿"≥ 3" o "> 3"?** Las normas dicen "al menos 3 K por encima" (≥), pero algunas fichas dicen "más de 3 °C" (>).
**Propuesta:** `≥` con tolerancia numérica de $10^{-9}$, y el umbral **parametrizable por producto** (algunos fabricantes exigen 4 °C o 5 °C).

⚠ **AMBIGÜEDAD 1.3 — redondeo.** Si se redondea $T_d$ a una décima antes de comparar, cambia el resultado en la frontera.
**Propuesta:** comparar siempre con valores sin redondear; redondear solo al mostrar (1 decimal).

⚠ **AMBIGÜEDAD 1.4 — incertidumbre de la medida.** Derivando la fórmula de $T_d$:

$$\frac{\partial T_d}{\partial \phi} = \frac{a\,b}{(a-\gamma)^2}\cdot\frac{1}{\phi}, \qquad \frac{\partial T_d}{\partial T} = \frac{a\,b}{(a-\gamma)^2}\cdot\frac{a\,b}{(b+T)^2}$$

| Condición | $\partial T_d/\partial\phi$ (°C por punto de HR) | $\partial T_d/\partial T$ |
|---|---|---|
| 20 °C, 60 % | 0.253 | 0.940 |
| 10 °C, 90 % | 0.164 | 0.988 |

Un higrómetro de obra típico (±3 % HR) produce una incertidumbre de ±0,5 a ±0,8 °C en $T_d$; un termómetro IR mal ajustado de emisividad puede errar ±1–2 °C en $T_s$. Es decir, el margen de 3 °C ya existe en buena parte para absorber estos errores.
**Propuesta:** el motor devuelve además una banda de incertidumbre $u(\Delta T) = \sqrt{(\partial T_d/\partial\phi \cdot u_\phi)^2 + (\partial T_d/\partial T \cdot u_T)^2 + u_{T_s}^2}$ con $u_\phi$, $u_T$, $u_{T_s}$ configurables (por defecto 3 %, 0,5 °C, 0,5 °C), y un estado intermedio **"APTO MARGINAL"** si $3 \le \Delta T < 3 + u$. Necesito que confirmes si quieres este tercer estado o un booleano estricto.

⚠ **AMBIGÜEDAD 1.5 — la condición es dinámica.** La norma se refiere al momento de la aplicación, pero el riesgo real (blushing aminado, pérdida de adherencia, velos blancos) se da durante las primeras horas de curado si la temperatura cae por la tarde/noche.
**Propuesta (fase posterior):** permitir evaluar la condición sobre una previsión horaria (T, HR) y una estimación de $T_s(t)$, y avisar si deja de cumplirse dentro de la ventana de curado "al tacto" del producto.

### 1.5 Reglas de validación de entrada

- $\phi \le 0$: error (logaritmo no definido). $\phi > 100$: error de medida; se rechaza (no se recorta silenciosamente).
- $T$ fuera de [0, 50] °C: se calcula, pero se marca `fuera_de_rango_validado = true`.
- Condición complementaria (no psicrométrica, pero obligatoria para emitir "APTO"): $T_s \ge T_{s,min}$ y $\phi \le \phi_{max}$ del producto, y humedad del soporte de hormigón ≤ límite del producto (típicamente ≤ 4 % CM). El motor solo comprueba los valores que existan en la ficha del producto.

### 1.6 Casos de prueba (Magnus‑AERK)

Tolerancia de aceptación: $|T_d - T_d^{ref}| \le 0.01$ °C. Columna Buck solo como control cruzado (|Δ| < 0,1 °C).

| # | $T$ (°C) | $\phi$ (%) | $T_d$ AERK (°C) | $T_d$ Buck 96 (°C) |
|---|---|---|---|---|
| P1 | 20 | 60 | 12.000 | 12.006 |
| P2 | 20 | 80 | 16.444 | 16.447 |
| P3 | 25 | 85 | 22.302 | 22.302 |
| P4 | 10 | 90 | 8.435 | 8.437 |
| P5 | 30 | 50 | 18.447 | 18.446 |
| P6 | 5 | 95 | 4.265 | 4.267 |
| P7 | 35 | 70 | 28.709 | 28.701 |
| P8 | 15 | 100 | 15.000 | 15.000 |
| P9 | 0 | 80 | −3.039 | −3.034 |
| P10 | 50 | 30 | 27.701 | 27.649 |

Casos de la regla de seguridad (aire 20 °C, 80 % → $T_d$ = 16.444 °C):

| # | $T_s$ (°C) | $\Delta T$ | Resultado esperado |
|---|---|---|---|
| S1 | 19.0 | 2.556 | NO APTO |
| S2 | 19.5 | 3.056 | APTO |
| S3 | 16.444… + 3.0 (exacto) | 3.000 | APTO (frontera, `≥`) |
| S4 | 15.0 | −1.444 | NO APTO (condensación activa) |

Invariante obligatorio: $\phi = 100 \Rightarrow T_d = T$ (P8). Monotonía: $T_d$ creciente estricta en $T$ y en $\phi$.

---

## 2. Cinética de curado y modelado del pot life

### 2.1 Química de base

La reacción principal epoxi‑amina es la adición nucleófila del hidrógeno activo de la amina al anillo oxirano:

- amina primaria + epóxido → amina secundaria + OH
- amina secundaria + epóxido → amina terciaria + OH
- (homopolimerización y eterificación OH‑epóxido: secundarias a temperatura ambiente)

Dos características condicionan el modelo:

1. **Es exotérmica:** $\Delta H \approx 100$–$110$ kJ por mol de grupo epóxido, lo que equivale a ~400–550 J/g en un sistema no cargado. Con $c_p \approx 1{,}6$–$1{,}9$ J/(g·K) la subida adiabática total posible es de **~200–300 K**. En un sistema cargado con árido se diluye proporcionalmente a la fracción de ligante.
2. **Es autocatalítica:** los OH generados catalizan la apertura del anillo, de modo que la velocidad crece con la conversión $\alpha$ hasta valores intermedios. El modelo de referencia es el de Kamal‑Sourour:

$$\frac{d\alpha}{dt} = \left(k_1 + k_2\,\alpha^{m}\right)(1-\alpha)^{n},\qquad k_i = A_i\,e^{-E_{a,i}/(R\,T_K)}$$

### 2.2 Arrhenius y factor de corrección por temperatura

$$k(T) = A\,\exp\!\left(-\frac{E_a}{R\,T_K}\right),\qquad R = 8.314462618\ \text{J/(mol·K)}$$

Definición operativa de pot life: tiempo hasta que la mezcla alcanza un grado de conversión $\alpha_{pl}$ en el que la viscosidad hace la mezcla inaplicable. **Hipótesis isoconversional:** el valor de $\alpha_{pl}$ es el mismo a cualquier temperatura. Entonces, en régimen **isotermo**,

$$\int_0^{\alpha_{pl}} \frac{d\alpha}{f(\alpha)} = k(T)\,t_{pl}(T) = \text{cte} \;\Rightarrow\; t_{pl}(T)\,k(T) = t_{ref}\,k(T_{ref})$$

$$\boxed{t_{pl}(T) = t_{ref}\cdot\exp\!\left[\frac{E_a}{R}\left(\frac{1}{T + 273.15} - \frac{1}{T_{ref} + 273.15}\right)\right]}$$

Esta fórmula es **independiente de $A$ y de $f(\alpha)$**: solo requiere $E_a$ y el dato del fabricante $(t_{ref}, T_{ref})$.

**La "regla del 10 °C" como caso particular.** "Cada 10 °C el pot life se reduce a la mitad" equivale a

$$E_a = \frac{R\ln 2}{\frac{1}{293.15} - \frac{1}{303.15}} = 51.2\ \text{kJ/mol}$$

que encaja con el intervalo publicado para epoxi‑amina a temperatura ambiente (≈ 45–65 kJ/mol). La regla no es exacta en todo el rango: con $E_a$ fijo, el factor por 10 °C es 2,2 entre 10 y 20 °C, y 1,9 entre 30 y 40 °C.

**Valores de $E_a$ propuestos por familia** (por defecto, sobrescribibles por producto):

| Familia de endurecedor | $E_a$ por defecto | Intervalo de literatura |
|---|---|---|
| Aminas alifáticas / cicloalifáticas (pavimentos epoxi estándar) | 55 kJ/mol | 45–65 |
| Poliamidas / amidoaminas | 50 kJ/mol | 40–60 |
| Fenalcaminas (curado a baja temperatura) | 45 kJ/mol | 35–55 |
| Poliuretano 2K (NCO–OH alifático/aromático, catalizado) | 50 kJ/mol | 35–65 (muy dependiente del catalizador) |

⚠ **AMBIGÜEDAD 2.1 — $E_a$ casi nunca aparece en la ficha técnica.** Si el fabricante da el pot life a dos temperaturas, $E_a$ se obtiene exactamente:

$$E_a = \frac{R\,\ln(t_1/t_2)}{\frac{1}{T_{1,K}} - \frac{1}{T_{2,K}}}$$

**Propuesta:** prioridad de datos → (1) $E_a$ calculada a partir de dos puntos de la ficha; (2) $E_a$ declarada por el fabricante; (3) valor por defecto de la familia con aviso "estimación".

⚠ **AMBIGÜEDAD 2.2 — $T_{ref}$ = 20 °C o 23 °C.** Las fichas europeas suelen usar 20 °C / 65 % HR (EN 23270), otras 23 °C / 50 % HR (ISO 291 / ASTM). **No es despreciable:** con $E_a$ = 55 kJ/mol, un pot life de 30 min declarado a 23 °C equivale a **37,7 min a 20 °C** (+26 %). $T_{ref}$ tiene que ser un campo obligatorio por producto; si no consta, el motor no debe suponerlo en silencio.

⚠ **AMBIGÜEDAD 2.3 — ¿qué temperatura es $T$?** La reacción la gobierna la **temperatura de la masa**, no la del aire. Al empezar, es la temperatura de los componentes en el momento de mezclar (bidones al sol en verano a 35–40 °C, o en una nave fría en invierno), que puede diferir mucho del ambiente.
**Propuesta:** entrada separada $T_{mat}$ (temperatura de los componentes), con valor por defecto $T_{aire}$ y aviso si no se ha medido.

⚠ **AMBIGÜEDAD 2.4 — definición de "pot life" según el fabricante.** Existen al menos tres magnitudes que las fichas llaman "pot life" o "tiempo de trabajabilidad":
- **Vida de la mezcla en el envase** (EN ISO 9514: tiempo hasta que la viscosidad u otra propiedad deja la mezcla inaplicable).
- **Tiempo de gel** (masa normalizada, p. ej. 100 g, a menudo en baño termostático).
- **Tiempo abierto o de trabajo sobre el soporte** (película extendida).
Los tres difieren hasta en un factor 2–4 para el mismo producto (ver §2.4). **Propuesta:** guardar el tipo de dato de referencia y su masa $m_{ref}$ como campos obligatorios de la ficha.

#### Límites de validez del modelo de Arrhenius

- **Por debajo de ~5–10 °C:** el curado se aproxima a la vitrificación ($T_g$ de la red ≈ $T$ de curado) y pasa a estar controlado por difusión; la velocidad cae más rápido de lo que predice Arrhenius. Además, las aminas absorben CO₂ y humedad (carbamatación, "blushing"). El modelo es **optimista** en ese rango. Propuesta: no extrapolar por debajo de $T_{min}$ del producto y bloquear el cálculo por debajo de 5 °C.
- **Por encima de ~35–40 °C:** el pot life lo domina la autoaceleración térmica (§2.3) y deja de ser isotermo.
- **Poliuretanos:** la reacción secundaria NCO + H₂O → urea + CO₂ depende de la humedad (espuma, burbujas, poros). Arrhenius sobre el pot life sigue siendo aplicable como primera aproximación, pero la HR es una variable de calidad adicional que este modelo no captura.

### 2.3 Factor de masa: por qué un cubo de 10 kg se acelera frente a 1 kg

#### Balance de energía del recipiente (modelo concentrado)

$$m\,c_p\,\frac{dT}{dt} = \underbrace{m\,Q_{tot}\,\frac{d\alpha}{dt}}_{\text{generación} \;\propto\; V \;\propto\; L^3} \;-\; \underbrace{U\,A\,(T - T_{amb})}_{\text{pérdidas} \;\propto\; A \;\propto\; L^2}$$

- $Q_{tot}$: calor total de reacción por kg de mezcla (J/kg)
- $U$: coeficiente global de transferencia (W/m²K)
- $A$: superficie de intercambio del recipiente

El calor generado escala con el volumen ($L^3$) y el evacuado con la superficie ($L^2$). Para recipientes de forma semejante:

$$\frac{A}{V} \propto \frac{1}{L} \propto m^{-1/3}$$

Pasar de 1 kg a 10 kg reduce la relación superficie/volumen en un factor $10^{1/3} = 2.15$.

Además, la resina conduce mal el calor ($\lambda \approx 0{,}2$ W/(m·K)). El número de Biot $Bi = h\,r/\lambda$ vale ≈ 2–6 en cubos de 1–20 kg, así que la hipótesis de temperatura uniforme **no se cumple**: el núcleo está más caliente que la media. Para un cilindro con generación uniforme en régimen cuasi‑estacionario, $T_{centro} - T_{pared} = \dot q\,r^2/(4\lambda)$, de donde el coeficiente efectivo entre **núcleo** y ambiente es

$$\frac{1}{U_{núcleo}} = \frac{1}{h} + \frac{r}{2\lambda}$$

**Propuesta:** usar $U_{núcleo}$ (conservador: modela toda la masa a la temperatura del núcleo, que es donde gelifica primero). Con este $U$, el efecto del tamaño es aún más fuerte: $U$ también disminuye con $m$.

#### Criterio adimensional (Semenov)

Linealizando Arrhenius alrededor de $T_0$, la estabilidad térmica la gobierna el número de Semenov

$$\psi = \frac{Q_{tot}\,\dot\alpha_0\,m}{U\,A}\cdot\frac{E_a}{R\,T_{0,K}^2}$$

con el valor crítico $\psi_c = 1/e \approx 0.368$. Para $\psi > \psi_c$ el recipiente no encuentra un estado estacionario y entra en **embalamiento térmico** (calentamiento autoacelerado, humo, deformación del cubo, en el límite autoignición de componentes). Como $\psi \propto m/(U A) \propto m^{1/3}/U$, **existe una masa crítica** por encima de la cual el embalamiento es inevitable. Esa es la explicación física del efecto de masa.

Una forma más intuitiva de verlo es la **constante de tiempo térmica** del recipiente:

$$\tau_{th} = \frac{m\,c_p}{U\,A}$$

- $\tau_{th} \ll t_{pl}$: el recipiente es casi **isotermo** (película fina, muestras de laboratorio pequeñas en baño).
- $\tau_{th} \gg t_{pl}$: el recipiente es casi **adiabático** (todo el calor se queda dentro).

Con los parámetros de §2.3.1 (cubos cilíndricos con H = D):

| $m$ (kg) | D = H (cm) | $A$ (m²) | $A/V$ (m⁻¹) | $Bi$ | $U_{núcleo}$ (W/m²K) | $\tau_{th}$ (min) |
|---|---|---|---|---|---|---|
| 0.1 | 4.80 | 0.0109 | 125.0 | 1.20 | 6.249 | 41.7 |
| 1 | 10.35 | 0.0504 | 58.0 | 2.59 | 4.361 | 128.8 |
| 5 | 17.69 | 0.1475 | 33.9 | 4.42 | 3.114 | 308.5 |
| 10 | 22.29 | 0.2341 | 26.9 | 5.57 | 2.641 | 458.2 |
| 20 | 28.08 | 0.3716 | 21.4 | 7.02 | 2.217 | 687.8 |

**Hallazgo importante, que contradice en parte la intuición de obra:** para un sistema con 30 min de pot life, **ya a partir de ~1 kg el cubo es prácticamente adiabático** durante el pot life ($\tau_{th}$ = 129 min ≫ 30 min). En consecuencia, la diferencia de pot life entre 1 kg y 10 kg es pequeña (~2–6 %). La gran diferencia aparece entre:

1. **la película extendida o una muestra termostatada** (isoterma) y **cualquier cubo ≥ 1 kg** (casi adiabático): factor ~1,8–3, y
2. el **pico exotérmico y el tiempo hasta el embalamiento** después del pot life, que sí dependen mucho de la masa.

Por eso, cuando un aplicador dice "10 kg se me corta antes que 1 kg", casi siempre compara contra una referencia medida en condiciones casi isotermas (100–200 g en laboratorio, o la mezcla ya extendida en el suelo). **Necesito que valides este punto con experiencia de campo** (ver la propuesta de ensayo en §2.6), porque condiciona qué dato de la ficha se usa como referencia.

#### 2.3.1 Modelo numérico propuesto (motor)

Sistema de EDO:

$$\frac{d\alpha}{dt} = k(T)\,(\alpha + z)\,(1-\alpha)^2,\qquad k(T) = k_{ref}\,\exp\!\left[-\frac{E_a}{R}\left(\frac{1}{T_K} - \frac{1}{T_{k,K}}\right)\right]$$

$$\frac{dT}{dt} = \frac{Q_{tot}}{c_p}\frac{d\alpha}{dt} - \frac{U_{núcleo}\,A}{m\,c_p}\,(T - T_{amb})$$

- Forma cinética: Kamal‑Sourour simplificado con $m = 1$, $n = 2$ y $z = k_1/k_2$ (término no autocatalítico). Se reduce a una sola constante $k$ para poder calibrarla con un único dato.
- Condiciones iniciales: $\alpha(0) = 0$, $T(0) = T_{mat}$.
- Geometría: cilindro con $H/D$ configurable (por defecto 1), $V = m/\rho$, $D = (4V/(\pi\,H/D))^{1/3}$, $A = \pi D H + 2\pi r^2$ (lateral + fondo + superficie libre; ⚠ la superficie libre y el fondo no intercambian igual: se asume el mismo $h$ por simplicidad).
- Fin: $t_{pl}$ es el primer instante en que $\alpha \ge \alpha_{pl}$, con interpolación lineal dentro del último paso.
- Integrador: **RK4 explícito, $\Delta t$ = 1 s** (para reproducibilidad de los tests; se ha comprobado frente a la solución analítica isoterma, ver P‑K0).
- Corte de seguridad: $t > 48$ h → "no alcanza pot life" (sistema muy lento o temperatura demasiado baja).

**Calibración a un punto:** dado el dato del fabricante $(t_{ref}, T_{ref}, m_{ref}, \text{régimen})$, se busca $k_{ref}$ por bisección logarítmica de forma que la simulación en ese régimen reproduzca $t_{ref}$. Régimen = `isotermo` (muestra termostatada o tiempo abierto en película) o `recipiente` (masa $m_{ref}$ en cubo al aire).

**Parámetros por defecto** (pavimento epoxi autonivelante, ligante A+B sin cargar):

| Parámetro | Valor | Origen / comentario |
|---|---|---|
| $E_a$ | 55 kJ/mol | §2.2 |
| $Q_{tot}$ | 400 kJ/kg | ligante no cargado, rango 350–550 |
| $c_p$ | 1700 J/(kg·K) | resina líquida, rango 1500–2000 |
| $\rho$ | 1150 kg/m³ | |
| $\lambda$ | 0.20 W/(m·K) | |
| $h$ | 10 W/(m²·K) | convección natural (~5) + radiación (~5) |
| $z$ | 0.05 | |
| $\alpha_{pl}$ | 0.10 | ⚠ ver AMBIGÜEDAD 2.5 |
| $H/D$ | 1.0 | cubo de obra típico |

⚠ **AMBIGÜEDAD 2.5 — $\alpha_{pl}$.** La conversión en el pot life no se publica. El gel de un sistema DGEBA + amina tetrafuncional estequiométrico ocurre en $\alpha_{gel} = 1/\sqrt{(f_A-1)(f_B-1)} = 1/\sqrt{3} = 0.577$ (Flory‑Stockmayer), pero la mezcla deja de ser aplicable mucho antes: la viscosidad se duplica alrededor de $\alpha \approx 0.05$–$0.15$. Con $\alpha_{pl}$ = 0.10 el aumento adiabático en el pot life es $0.10 \cdot 400/1.7 = 23.5$ K, coherente con el "cubo templado" que se observa en obra al final del pot life. Con $\alpha_{pl}$ = 0.30 saldrían ~70 K, físicamente incoherente con lo observado. **Este parámetro es calibrable**: con dos datos de ficha a masas distintas se podría ajustar.

⚠ **AMBIGÜEDAD 2.6 — mezclas con árido (tricomponente A + B + C).** El árido no reacciona, pero aporta masa térmica y conductividad. Para fracción másica de ligante $w_L$:

$$Q_{mix} = w_L\,Q_{tot},\qquad c_{p,mix} = w_L\,c_{p,L} + (1-w_L)\,c_{p,árido}\ (\approx 800\ \text{J/kgK cuarzo})$$

Ejemplo: 1 parte de ligante por 2 de cuarzo → $Q_{mix}$ = 133 kJ/kg, $c_{p,mix}$ = 1100 J/(kg·K), subida adiabática total 121 K (frente a 235 K del ligante solo). La ficha puede dar el pot life del ligante (A + B) o del mortero (A + B + C): **hay que saber cuál**.

### 2.4 Casos de prueba de cinética

**P‑K0 — validación del integrador frente a la solución analítica isoterma.** Para $f(\alpha) = (\alpha+z)(1-\alpha)^2$, con $s = 1+z$:

$$\int \frac{d\alpha}{(\alpha+z)(1-\alpha)^2} = \frac{1}{s^2}\ln\frac{\alpha+z}{1-\alpha} + \frac{1}{s\,(1-\alpha)}$$

Con $z = 0.05$ y $\alpha_{pl} = 0.30$ → $k\,t = 2.496676$. RK4 con Δt = 1 s reproduce el valor con un error relativo < $10^{-12}$. **Tolerancia del test: $10^{-6}$ relativo.**

**P‑K1 — Arrhenius isotermo** ($t_{ref}$ = 30 min a 20 °C). Fórmula cerrada, tolerancia ±0,01 min.

| $E_a$ (kJ/mol) | 5 °C | 10 °C | 15 °C | 20 °C | 25 °C | 30 °C | 35 °C | 40 °C |
|---|---|---|---|---|---|---|---|---|
| 40 | 72.69 | 53.56 | 39.88 | 30.00 | 22.78 | 17.46 | 13.50 | 10.52 |
| 50 | 90.69 | 61.91 | 42.83 | 30.00 | 21.27 | 15.25 | 11.05 | 8.09 |
| **55** | **101.30** | **66.56** | **44.38** | **30.00** | **20.55** | **14.25** | **10.00** | **7.10** |
| 60 | 113.15 | 71.56 | 45.99 | 30.00 | 19.85 | 13.32 | 9.05 | 6.23 |
| 70 | 141.17 | 82.72 | 49.38 | 30.00 | 18.53 | 11.63 | 7.41 | 4.79 |

**P‑K2 — cambio de referencia:** 30 min declarados a 23 °C, $E_a$ = 55 kJ/mol → **37.70 min a 20 °C**.

**P‑K3 — $E_a$ a partir de dos puntos:** 60 min a 10 °C y 25 min a 25 °C → $E_a = 8.314462618\cdot\ln(2.4)/(1/283.15 - 1/298.15) = 40.97$ kJ/mol.

**P‑K4 — modelo de masa, calibrado en recipiente** (dato: 30 min a 20 °C en cubo de 1 kg; parámetros por defecto; $k_{ref}$ resultante = 3.6660·10⁻⁴ s⁻¹). Formato: pot life (min) / temperatura de la masa al final del pot life (°C). **Tolerancia: ±1 % en tiempo, ±0,5 °C en temperatura** (son tests de regresión del modelo, no valores de laboratorio).

| $T_{mat} = T_{amb}$ | Película (isoterma) | 0.1 kg | 1 kg | 5 kg | 10 kg | 20 kg | Adiabático |
|---|---|---|---|---|---|---|---|
| 10 °C | 120.8 | 76.0 / 24.0 | 66.6 / 30.2 | 64.0 / 32.1 | 63.5 / 32.6 | 63.0 / 32.9 | — |
| 20 °C | 54.5 | 31.9 / 38.7 | **30.0** / 41.9 | 29.5 / 42.9 | 29.4 / 43.1 | 29.3 / 43.2 | 29.1 |
| 30 °C | 25.9 | 14.9 / 51.1 | 14.5 / 52.7 | 14.4 / 53.2 | 14.4 / 53.3 | 14.3 / 53.4 | — |

**P‑K5 — mismo producto, pero el dato de la ficha es isotermo** (30 min a 20 °C en muestra termostatada; $k_{ref}$ = 6.6548·10⁻⁴ s⁻¹):

| $T$ | Película | 0.1 kg | 1 kg | 5 kg | 10 kg | 20 kg |
|---|---|---|---|---|---|---|
| 10 °C | 66.6 | 38.4 | 35.6 | 34.8 | 34.7 | 34.5 |
| 20 °C | **30.0** | 16.9 | 16.3 | 16.1 | 16.1 | 16.1 |
| 30 °C | 14.3 | 8.1 | 7.9 | 7.9 | 7.9 | 7.9 |

→ El **mismo número "30 min"** en la ficha da 29 min o 16 min en un cubo de 10 kg según el régimen en que se midió. Este es el error de dominio más grave que puede cometer la aplicación.

**P‑K6 — sistema lento** ($t_{ref}$ = 90 min a 20 °C, 1 kg, recipiente): el efecto de masa es mayor porque $t_{pl}$ se acerca a $\tau_{th}$:

| $T$ | Película | 0.1 kg | 1 kg | 5 kg | 10 kg | 20 kg |
|---|---|---|---|---|---|---|
| 10 °C | 343.1 | 271.5 | 212.7 | 191.4 | 186.5 | 183.2 |
| 20 °C | 154.6 | 105.4 | **90.0** | 85.7 | 84.7 | 84.0 |
| 30 °C | 73.5 | 45.9 | 42.3 | 41.3 | 41.1 | 40.9 |

**P‑K7 — temperatura del material distinta del ambiente** (calibración P‑K4, 10 kg, $T_{amb}$ = 20 °C):
- $T_{mat}$ = 30 °C (bidones al sol): **14.5 min** (−51 % frente a 29.4 min).
- $T_{mat}$ = 10 °C (material frío): **60.4 min**.

**P‑K8 — dilución con árido** (calibración P‑K4, 10 kg a 20 °C, ligante:cuarzo 1:2 en masa, $\rho$ = 1900 kg/m³, $\lambda$ = 0.6 W/(m·K)): **38.8 min** frente a 29.4 min del ligante solo.

### 2.5 Salidas y alertas del módulo

- $t_{pl}$ estimado (min) en el cubo para la masa real que se va a mezclar.
- Tiempo abierto estimado en película (límite isotermo a $T_s$).
- Alerta "**masa por encima de la recomendada**" si $\psi > 0.8\,\psi_c$ (umbral a validar), recomendando mezclar en tandas o verter la mezcla al suelo de inmediato (extenderla en el suelo la devuelve al régimen isotermo).
- Aviso de extrapolación si $T$ < $T_{min}$ del producto o > 35 °C.
- Toda salida lleva la etiqueta "estimación de ingeniería; prevalece la ficha técnica del fabricante".

### 2.6 Propuesta de ensayo de validación de campo

Para cerrar las ambigüedades 2.4–2.5 y validar el hallazgo de §2.3: mezclar 1 kg y 10 kg del mismo producto a la misma $T_{mat}$, con un termopar en el centro geométrico y otro en la pared, registrando T cada 30 s y anotando el instante en que el aplicador considera que la mezcla ya no es trabajable. Con dos curvas T(t) se ajustan $U$ y $Q_{tot}\cdot\alpha_{pl}$ por mínimos cuadrados.

---

## 3. Álgebra de mezclas bicomponente (A + B) y rendimiento

### 3.1 Normalización de la relación de mezcla

Las fichas expresan la relación de muchas formas: "100 : 50 en peso", "2 : 1", "A 66,7 % / B 33,3 %", "3 : 1 en volumen", "kit 10 + 5 kg". Todas se normalizan internamente a **partes en masa** $(p_A, p_B)$ y a **fracciones másicas**:

$$w_A = \frac{p_A}{p_A + p_B},\qquad w_B = \frac{p_B}{p_A + p_B},\qquad r_w = \frac{p_A}{p_B}$$

### 3.2 Conversión peso ↔ volumen

$$V_i = \frac{m_i}{\rho_i}\;\Rightarrow\; \boxed{r_v = \frac{V_A}{V_B} = r_w\cdot\frac{\rho_B}{\rho_A}},\qquad \boxed{r_w = r_v\cdot\frac{\rho_A}{\rho_B}}$$

Densidad de la mezcla (mezcla ideal, sin variación de volumen):

$$\rho_{mix} = \frac{m_A + m_B}{\dfrac{m_A}{\rho_A} + \dfrac{m_B}{\rho_B}} = \left(\frac{w_A}{\rho_A} + \frac{w_B}{\rho_B}\right)^{-1}$$

(media armónica ponderada en masa; **no** la media aritmética).

⚠ **AMBIGÜEDAD 3.1 — densidades.** (a) Las fichas dan densidades a 20 o 23 °C; los líquidos epoxi varían ~ −0,05 a −0,07 %/K, lo que es despreciable para la dosificación salvo con grandes diferencias de temperatura. (b) Las mezclas reales contraen ligeramente (< 1–2 %). (c) Algunos fabricantes dan la densidad de la **mezcla** medida, que debe prevalecer sobre la calculada. **Propuesta:** si existe $\rho_{mix}$ declarada se usa para rendimiento; las densidades individuales solo para la conversión peso/volumen.

⚠ **AMBIGÜEDAD 3.2 — "volumen aparente" de componentes con carga.** En componentes muy cargados, o con tixotropía y aire ocluido, la dosificación volumétrica con jarra es poco fiable. **Propuesta:** el motor ofrece la conversión a volumen, pero marca "se recomienda dosificar por peso" si alguno de los componentes tiene $\rho$ > 1,5 kg/L o la ficha indica dosificación por peso.

**Comprobación estequiométrica (opcional, modo formulador):** $\text{phr}_{B} = 100\cdot\text{AHEW}/\text{EEW}$. Ejemplo: EEW = 190 g/eq y AHEW = 95 g/eq → 50 phr (100 : 50). La aplicación **no** debe recalcular la relación de un producto comercial (lleva cargas, disolventes, aditivos): siempre manda la ficha.

### 3.3 Algoritmo de mezcla parcial

Entrada: relación normalizada $(p_A, p_B)$ y **una** de estas restricciones:

| Modo | Dato | Cálculo |
|---|---|---|
| Fijo A | $m_A$ | $m_B = m_A\cdot p_B/p_A$ |
| Fijo B | $m_B$ | $m_A = m_B\cdot p_A/p_B$ |
| Total | $M$ | $m_A = M\,w_A,\ m_B = M\,w_B$ |
| Por volumen fijo | $V_A$ (o $V_B$ o $V_{tot}$) | convertir a masa con $\rho_i$ y volver a uno de los anteriores |
| Por superficie | $S$, consumo $c$ (kg/m²), pérdidas | $M = S\cdot c\cdot f_{pérd}$ → modo Total |
| Por envase disponible | resto de envase de A o B | mín(modo Fijo A, modo Fijo B) para no exceder ninguno |

**Redondeo a la resolución de la báscula $d$** (p. ej. 1 g, 5 g, 10 g):

1. Calcular masas exactas.
2. Redondear **el componente fijado por el usuario** solo si el usuario no lo dio exacto; el dependiente se redondea al múltiplo de $d$ más cercano.
3. Calcular el error real de relación: $\varepsilon = \dfrac{m_B^{red}/m_A^{red}}{p_B/p_A} - 1$.
4. Si $|\varepsilon| > \varepsilon_{max}$ → aviso bloqueante.

Masa mínima del componente minoritario para que el redondeo respete la tolerancia (error de redondeo máximo $d/2$):

$$\boxed{m_{min,minoritario} \ge \frac{d}{2\,\varepsilon_{max}}}$$

⚠ **AMBIGÜEDAD 3.3 — tolerancia de relación.** Pocas fichas la declaran. La práctica habitual en epoxi‑amina es ±2–5 % (fuera de ella baja la Tg y aparecen superficies pegajosas o exudación de amina); en poliuretano (índice NCO/OH) es más estricta. **Propuesta:** $\varepsilon_{max}$ por producto, con 2 % por defecto. Añadir también un aviso general: "mezclar el kit completo siempre que sea posible", porque los kits predosificados compensan el residuo que queda en el envase.

### 3.4 Rendimiento: superficie, espesor, sólidos y consumo

Definiciones:
- $WFT$: espesor de película húmeda (µm)
- $DFT$: espesor de película seca (µm)
- $SV$: sólidos en volumen (fracción 0–1; en la ficha suele venir en %; ISO 3233 / ASTM D2697)

**Relación de espesores:**

$$DFT = WFT\cdot SV \qquad\Longleftrightarrow\qquad WFT = \frac{DFT}{SV}$$

**Deducción del rendimiento teórico:** 1 L = $10^{-3}$ m³ extendido sobre 1 m² da $10^{-3}$ m = 1000 µm de húmedo. Por tanto

$$\boxed{R_{teór}\ [\text{m}^2/\text{L}] = \frac{1000\cdot SV}{DFT\,[\mu\text{m}]} = \frac{10\cdot SV[\%]}{DFT\,[\mu\text{m}]}}$$

**Consumo en masa:**

$$\boxed{c\ [\text{kg/m}^2] = \rho_{mix}[\text{kg/L}]\cdot\frac{WFT[\mu\text{m}]}{1000} = \frac{\rho_{mix}\cdot DFT}{1000\cdot SV}}$$

**Comprobación dimensional** para un 100 % sólidos: 1 mm de espesor ⇒ $c$ = $\rho$ kg/m². Es decir, "kg/m² por mm" coincide numéricamente con la densidad en g/cm³ (convención habitual de las fichas de autonivelantes: "1,6–1,8 kg/m² por mm").

**Cantidad total:**

$$M_{total} = S\cdot c\cdot f_{pérd},\qquad N_{kits} = \left\lceil \frac{M_{total}}{M_{kit}} \right\rceil$$

⚠ **AMBIGÜEDAD 3.4 — cómo se aplica el % de pérdidas.** "10 % de pérdidas" puede significar $\times 1.10$ (sobre lo teórico) o $\div 0.90$ (el 10 % de lo comprado se pierde): 47,67 kg frente a 48,15 kg en el ejemplo R3. **Propuesta:** $f_{pérd} = 1/(1-p)$ (lo comprado se pierde en parte), mostrando la fórmula al usuario. Pendiente de tu validación.

⚠ **AMBIGÜEDAD 3.5 — sólidos en masa frente a sólidos en volumen.** Algunas fichas solo dan sólidos en masa (ISO 3251). No se puede pasar a volumen sin la densidad de la película seca. **Propuesta:** si falta $SV$, el motor no calcula DFT ↔ WFT y pide el dato.

⚠ **AMBIGÜEDAD 3.6 — dilución.** Si se añade un $x$ % **en volumen** de disolvente: $SV' = SV/(1 + x)$. Si el % es **en masa** (lo más habitual en las fichas), hacen falta la densidad del diluyente y la de la mezcla: $V_{dil} = x\,M/\rho_{dil}$, $SV' = SV\cdot V_{mix}/(V_{mix} + V_{dil})$.

⚠ **AMBIGÜEDAD 3.7 — el modelo de película no vale para todo.**
- **Imprimaciones sobre hormigón poroso:** el consumo lo gobierna la absorción del soporte (porosidad, perfil CSP), no el espesor. Se usa el consumo de la ficha (kg/m²) directamente.
- **Autonivelantes y morteros con árido:** usar $\rho$ del mortero (A + B + C) y espesor en mm.
- **Espolvoreos de árido a saturación:** consumo independiente, en kg/m².
- **Rugosidad del soporte:** añade un "volumen muerto" equivalente (típicamente 0,1–0,5 mm sobre hormigón granallado), parametrizable.

### 3.5 Casos de prueba de mezclas y rendimiento

Tolerancia: ±0,05 % relativo, o ±1 g en las masas redondeadas.

**M1 — peso → volumen.** 100 : 50 en peso, $\rho_A$ = 1.10, $\rho_B$ = 1.00 kg/L.
$r_v = 2 \cdot 1.00/1.10 = 1.8182$ → 100 : 55.0 en volumen. $\rho_{mix} = 1.5/(1/1.1 + 0.5/1.0) = 1.5/1.40909 = 1.0645$ kg/L. (La media aritmética daría 1.0667: error del 0,2 %.)

**M2 — volumen → peso.** 3 : 1 en volumen, $\rho_A$ = 1.40, $\rho_B$ = 0.98.
$r_w = 3\cdot1.40/0.98 = 4.2857$ → $w_A$ = 0.81081, $w_B$ = 0.18919 (≈ 100 : 23.33 en peso).

**M3 — fijo A.** 100 : 50, $m_A$ = 7.300 kg → $m_B$ = 3.650 kg.

**M4 — fijo B.** 100 : 50, $m_B$ = 1.250 kg → $m_A$ = 2.500 kg.

**M5 — total con redondeo.** 100 : 50, $M$ = 4.000 kg, $d$ = 5 g.
Exacto: 2666.67 g / 1333.33 g → redondeado: 2665 g / 1335 g → $\varepsilon = (1335/2665)/0.5 - 1 = +0.19\,\%$ → OK.

**M6 — masa mínima.** $d$ = 5 g, $\varepsilon_{max}$ = 2 % → componente minoritario ≥ 125 g → con 100 : 50, mezcla total ≥ 375 g. Con $d$ = 10 g → ≥ 250 g de B (750 g en total).

**M7 — límite de envase.** 100 : 50, quedan 6.0 kg de A y 2.5 kg de B → B limita: 2.5 kg de B + 5.0 kg de A (sobra 1.0 kg de A).

**R1 — 100 % sólidos, capa de 300 µm.** $SV$ = 1, $DFT$ = 300 µm, $\rho_{mix}$ = 1.45 kg/L → $WFT$ = 300 µm, $R$ = 3.333 m²/L, $c$ = 0.435 kg/m².

**R2 — base disolvente.** $SV$ = 60 %, $DFT$ = 80 µm, $\rho$ = 1.30 → $WFT$ = 133.33 µm, $R$ = 7.50 m²/L, $c$ = 0.17333 kg/m².

**R3 — pedido.** R2 sobre $S$ = 250 m², pérdidas 10 %: teórico 43.333 kg; con $\div 0.90$: **48.148 kg**; con $\times 1.10$: 47.667 kg. Kits de 20 kg → **3 kits** en ambos casos (60 kg; sobran ~11,9 kg).

**R4 — autonivelante.** 2 mm, $\rho_{mortero}$ = 1.80 kg/L, 100 % sólidos → 3.60 kg/m²; 120 m² → 432 kg teóricos.

**R5 — dilución en volumen.** $SV$ = 60 % + 5 % en volumen de diluyente → $SV'$ = 57.14 %; para mantener $DFT$ = 80 µm, $WFT$ = 140.0 µm (frente a 133.3 µm).

**R6 — coherencia inversa.** Para cualquier entrada válida: $c\cdot R\cdot\dfrac{1}{\rho}\cdot\dfrac{DFT}{1000\,SV}\cdot\dfrac{1000\,SV}{DFT} = 1$, es decir, $c = \rho/R$ (kg/m² = (kg/L)/(m²/L)). Test de propiedad sobre entradas aleatorias.

### 3.6 Límites de validez

- $0 < SV \le 1$; si $SV$ > 1, error de datos.
- Relación de mezcla con $p_A, p_B > 0$.
- Densidades entre 0.7 y 2.5 kg/L (fuera de ese rango, se pide confirmación del dato).
- Espesores: de 20 µm a 10 mm. Por encima de ~3 mm en una sola capa, aviso de exotermia en capa gruesa: en el suelo también aparece el efecto de masa (enlaza con §2.3).

---

## 4. Resumen de decisiones pendientes de validación

| ID | Tema | Propuesta por defecto |
|---|---|---|
| 1.1 | Agua/hielo por debajo de 0 °C | Coeficientes sobre agua siempre |
| 1.2 | ≥ o > 3 °C | `≥`, umbral parametrizable por producto |
| 1.3 | Redondeo | Comparar sin redondear |
| 1.4 | Incertidumbre | Añadir estado "APTO MARGINAL" (**¿lo quieres?**) |
| 1.5 | Condición dinámica nocturna | Fase posterior con previsión horaria |
| 2.1 | $E_a$ ausente | Dos puntos > valor declarado > valor por familia |
| 2.2 | $T_{ref}$ 20 / 23 °C | Campo obligatorio, sin valor por defecto silencioso |
| 2.3 | T de la masa | Entrada $T_{mat}$ separada de $T_{aire}$ |
| 2.4 | Tipo de pot life en la ficha | Campos obligatorios: régimen y $m_{ref}$ |
| 2.5 | $\alpha_{pl}$ | 0.10, calibrable |
| 2.6 | Árido en la mezcla | Dilución de $Q$ y $c_p$ por fracción de ligante |
| §2.3 | Efecto de masa 1 vs 10 kg pequeño si la referencia ya es un cubo | **Validar con experiencia de campo / ensayo §2.6** |
| 3.1 | Densidades | Prevalece la $\rho_{mix}$ declarada |
| 3.3 | Tolerancia de relación | 2 % por defecto, por producto |
| 3.4 | % de pérdidas | $\div(1-p)$ |
| 3.5 | Sólidos en masa | No calcular sin $SV$ |
| 3.6 | Dilución en masa | Requiere $\rho_{dil}$ |
| 3.7 | Imprimaciones y espolvoreos | Consumo directo de la ficha |

**Fin de la fase 1.** Quedo a la espera de tu validación antes de definir el modelo de datos (fichas de producto, parámetros por familia, trazabilidad de fuentes) y la arquitectura del motor.
