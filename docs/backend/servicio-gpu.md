# Servicio de filtros en GPU

## 1. Propósito y alcance

El servicio de filtros aplica a las fotografías de UPSGlam seis filtros de procesamiento de
imagen ejecutados en GPU. Está escrito en Python con FastAPI y PyCUDA, y expone una interfaz
REST que consume exclusivamente el backend Java (Spring WebFlux). La aplicación móvil no se
comunica con este servicio.

El código fuente se encuentra en [`upsglam_gpu_service/`](../../upsglam_gpu_service/).

Ante una contradicción entre fuentes, el orden de prioridad es el siguiente:

1. El enunciado del proyecto y su rúbrica.
2. Este documento.
3. La práctica 03 (`Portfolio_Parallel_Computing/03_Aplicacion_computo_paralelo_badado_docker_pycuda`),
   que sirve de referencia, pero no es un estándar obligatorio.

## 2. Entorno de ejecución

| GPU | Memoria | Capacidad de cómputo |
|---|---|---|
| GeForce MX230 | 4 GB | 6.1 |
| GeForce RTX 5050 Laptop | 8 GB | 12.0 |

Los kernels se compilan en tiempo de ejecución con NVRTC 12.9 (paquete
`nvidia-cuda-nvrtc-cu12`) y se cargan con `pycuda.driver.module_from_buffer`. No se emplea
`SourceModule`, porque requiere `nvcc` y la versión instalada en el sistema (CUDA 13) ya no
genera código para la arquitectura Pascal. Con NVRTC el mismo código funciona en ambos
equipos, dentro y fuera de Docker.

## 3. Arquitectura

```
upsglam_gpu_service/
  src/
    main.py               Aplicación FastAPI, rutas y traducción de errores a HTTP
    config.py             Parámetros configurables por variable de entorno
    modelos.py            Estructuras de datos y respuestas de la API
    errores.py            ErrorServicio, con código de texto y sin estado HTTP
    filtros.py            Definición de los filtros y clase Pasos
    servicios/
      procesamiento.py    Validación, cola de la GPU, resultados temporales
    gpu/
      kernels.py          Código CUDA de los kernels, como texto
      compilador.py       Compilación de los kernels a PTX con NVRTC
      motor.py            Contexto CUDA, memoria, lanzamientos y medición
    utils/
      imagen.py           Normalización a RGB, gris, valor absoluto, 8 bits, JPEG
  pruebas/
    validacion.py         Validación de kernels y filtros contra NumPy
    prueba_api.py         Prueba de la API con el servicio en ejecución
```

El servicio se organiza en capas con dependencias en un solo sentido:

- `main.py` define las rutas: recibe la petición, llama al servicio y arma la respuesta.
  No accede a la GPU ni contiene reglas del negocio.
- Los servicios validan, encolan, aplican el filtro y administran archivos. No manejan
  nada de HTTP: ni peticiones, ni respuestas, ni códigos de estado.
- El módulo `gpu/` ejecuta kernels y no conoce los filtros ni HTTP.
- Las estructuras de datos se agrupan en `modelos.py`, sin un archivo por modelo.

### 3.1 Reparto entre CPU y GPU

Todas las convoluciones y transformaciones de píxeles que definen un filtro se ejecutan en
GPU. La CPU se limita a preparar la entrada y entregar la salida:

- Pillow abre la imagen y la convierte a RGB o a escala de grises.
- NumPy calcula el valor absoluto, redondea, recorta al intervalo 0–255 y convierte a 8 bits.

Cada paso de un filtro cumple el mismo contrato: recibe un arreglo de NumPy y sus parámetros,
devuelve otro arreglo y registra sus mediciones en un objeto `Medidas`. La clase `Pasos` de
`src/filtros.py` es el único lugar donde se asigna a cada paso su implementación. Para
trasladar un paso entre CPU y GPU basta con modificar esa asignación; los filtros, los
servicios y la API no cambian.

## 4. Filtros

Todos los filtros reciben una imagen RGB de 8 bits. Media, Nitidez, Relieve y UPS devuelven
una imagen en color; Laplaciano y Sobel la devuelven en escala de grises.

| Filtro | Secuencia de pasos | Parámetro | Valores | Por defecto |
|---|---|---|---|---|
| Media | `convolucion_rgb` con máscara de promedio k×k | `nivel` | bajo (3), medio (9), fuerte (21) | medio |
| Nitidez | `convolucion_rgb` con máscara de nitidez | `intensidad` | 0 a 2 | 1 |
| Laplaciano | gris, `convolucion_gris` (gaussiano 5×5 y Laplaciano × intensidad), valor absoluto | `intensidad` | 3 a 10 | 6 |
| Sobel | gris, `sobel` | `direccion` | horizontal, vertical, ambas | ambas |
| Relieve | `convolucion_rgb` con máscara de relieve | `intensidad` | 0 a 2 | 1 |
| UPS | gris, `sobel` y `colorear_ups` | — | — | — |

Todos los filtros terminan con la conversión a 8 bits.

Detalles de diseño:

- **Intensidad en Nitidez y Relieve.** La máscara aplicada es
  `(1 − i)·identidad + i·máscara`. Por la linealidad de la convolución, el resultado equivale a
  mezclar la imagen original con la filtrada, pero se obtiene en una sola pasada. Con `i = 0`
  la imagen no cambia y con `i > 1` el efecto se acentúa.
- **Laplaciano del gaussiano.** Antes del Laplaciano se aplica un suavizado gaussiano de 5×5
  (coeficientes binomiales 1-4-6-4-1, normalizados entre 256). Sin este paso, el ruido del
  sensor y los artefactos de compresión JPEG aparecen como bordes. Sobel no lo requiere,
  porque su máscara ya incluye un suavizado 1-2-1.
- **Sobel.** `horizontal` resalta los bordes horizontales (|gy|), `vertical` los verticales
  (|gx|) y `ambas` calcula la magnitud √(gx² + gy²).
- **Relieve.** La máscara suma 1, de modo que las zonas uniformes conservan su color.
- **UPS.** El nivel de gris determina el color de fondo dentro de un degradado del azul
  #013871 (zonas oscuras) al amarillo #FFC72C (zonas claras). Sobre ese fondo se trazan los
  bordes de Sobel con el color opuesto al del fondo, con una fuerza de 0,4.

### 4.1 Dónde actúa cada parámetro

| Parámetro | Momento | Dónde | Qué modifica |
|---|---|---|---|
| `nivel` (Media) | Antes de la convolución | CPU, `mascara_media` | Tamaño k de la máscara |
| `intensidad` (Nitidez, Relieve) | Antes de la convolución | CPU, `mezclar` | Coeficientes de la máscara |
| `intensidad` (Laplaciano) | Antes de la convolución | CPU, `laplaciano` | Multiplica los coeficientes de la máscara |
| `direccion` (Sobel) | Durante el kernel | GPU, `sobel` | Qué gradiente escribe cada hilo |
| Fuerza de bordes (UPS, fija en 0,4) | Durante el kernel | GPU, `colorear_ups` | Peso del color de borde |

Construir o mezclar una máscara en CPU cuesta a lo sumo 441 operaciones, sin importar el
tamaño de la imagen; la convolución, que recorre todos los píxeles, se ejecuta siempre en GPU.
Todo parámetro actúa sobre la máscara o dentro del kernel; ninguno se aplica sobre la imagen
resultante. Después de la GPU solo quedan el valor absoluto (Laplaciano) y el paso a 8 bits.

### 4.2 Ejemplo de cálculo

Los ejemplos siguientes usan un solo canal y el mismo vecindario de 3×3, con el píxel central
en 130:

```
100 100 100
100 130 140
100 140 160
```

La convolución multiplica cada vecino por el coeficiente de la máscara que le corresponde y
suma los productos.

**Media.** Con `nivel = bajo` (k = 3) cada coeficiente vale 1/9:

(100·5 + 130 + 140 + 140 + 160) / 9 = 1070 / 9 = 118,9 → **119**

`medio` y `fuerte` promedian 81 y 441 vecinos (máscaras de 9×9 y 21×21). El desenfoque
aumenta y también el costo: cada hilo realiza k² multiplicaciones, por lo que el tiempo de
kernel crece aproximadamente con k² (en la MX230, 6 ms, 51 ms y 250 ms para una imagen de
1920×1280).

**Nitidez.** La máscara aplicada es `identidad + i·(nitidez − identidad)`:

```
identidad          nitidez            nitidez − identidad
0  0  0            0 -1  0            0 -1  0
0  1  0           -1  5 -1           -1  4 -1
0  0  0            0 -1  0            0 -1  0
```

| i | Máscara aplicada | Cálculo | Resultado |
|---|---|---|---|
| 0 | `0 0 0 / 0 1 0 / 0 0 0` | 1·130 | 130 |
| 0,5 | `0 -0.5 0 / -0.5 3 -0.5 / 0 -0.5 0` | 3·130 − 0,5·480 | 150 |
| 1 | `0 -1 0 / -1 5 -1 / 0 -1 0` | 5·130 − 480 | 170 |
| 2 | `0 -2 0 / -2 9 -2 / 0 -2 0` | 9·130 − 2·480 | 210 |

480 es la suma de los cuatro vecinos en cruz (100 + 100 + 140 + 140). La máscara suma 1 con
cualquier `i`, de modo que una zona uniforme no cambia; solo se amplifica la diferencia entre
el píxel y sus vecinos.

**Relieve.** Misma fórmula con la máscara de relieve:

```
relieve            relieve − identidad
-2 -1  0           -2 -1  0
-1  1  1           -1  0  1
 0  1  2            0  1  2
```

Aplicada al vecindario, `relieve − identidad` da
−2·100 − 1·100 − 1·100 + 1·140 + 1·140 + 2·160 = 200, y el resultado es `130 + i·200`:

| i | Máscara aplicada | Resultado |
|---|---|---|
| 0 | identidad | 130 |
| 0,5 | `-1 -0.5 0 / -0.5 1 0.5 / 0 0.5 1` | 230 |
| 1 | `-2 -1 0 / -1 1 1 / 0 1 2` | 330 → 255 tras el recorte |
| 2 | `-4 -2 0 / -2 1 2 / 0 2 4` | 530 → 255 tras el recorte |

El coeficiente central vale 1 para cualquier `i`, por eso se conserva el color de las zonas
uniformes. Un píxel con vecinos más claros abajo a la derecha se aclara y uno con vecinos más
claros arriba a la izquierda se oscurece, lo que produce el efecto de grabado.

**Laplaciano.** La intensidad multiplica los coeficientes. Con `intensidad = 6` (y sin el
gaussiano previo, para simplificar):

```
laplaciano         × 6
0  1  0            0   6   0
1 -4  1            6 -24   6
0  1  0            0   6   0
```

La GPU obtiene 6·480 − 24·130 = −240 y la CPU solo calcula el valor absoluto: **240**. Como
|c·L| = c·|L| para c > 0, el resultado es el mismo que multiplicar |−40| por 6 después de la
convolución, pero el factor se aplica en la GPU. El mínimo del rango es 3 porque con valores
menores los bordes salen casi negros.

## 5. Ejecución en GPU

### 5.1 Kernels

| Kernel | Entrada | Salida | Uso |
|---|---|---|---|
| `convolucion_rgb` | 3 canales | 3 canales | Media, Nitidez, Relieve |
| `convolucion_gris` | 1 canal | 1 canal | Gaussiano y Laplaciano |
| `sobel` | 1 canal | 1 canal | Sobel y UPS |
| `colorear_ups` | gris y bordes | 3 canales | UPS |

Se prefiere un kernel por tarea frente a un kernel genérico con ramas condicionales.

### 5.2 Configuración de lanzamiento

- Bloques bidimensionales de 16×16 hilos (`BLOQUE`), con un hilo por píxel.
- La malla se redondea hacia arriba para cubrir la imagen completa; los hilos que quedan fuera
  de ella terminan sin escribir.
- Las imágenes se procesan en `float32` con valores de 0 a 255. Las imágenes en color se
  almacenan con los canales intercalados (R, G, B por píxel).

### 5.3 Tratamiento de bordes

Cuando la máscara excede los límites de la imagen, se toma el valor del píxel más cercano
dentro de ella (replicación de borde). La práctica 03 asignaba 0 a esos vecinos, lo que
oscurece la orilla y produce un marco negro de 10 píxeles con la máscara de 21×21.

### 5.4 Memoria

- La máscara se guarda en memoria constante (hasta 21×21 coeficientes) y se copia antes de
  cada lanzamiento.
- Cuando un filtro encadena varios kernels (gaussiano y Laplaciano, o Sobel y colores), los
  datos intermedios permanecen en la GPU.
- Los búferes de salida se inicializan con NaN, de modo que un píxel no calculado se detecta
  durante la validación.
- La memoria reservada se libera al terminar cada solicitud, también cuando ocurre un error.

### 5.5 Concurrencia

Un único hilo es propietario del contexto CUDA y ejecuta todas las solicitudes. Las
solicitudes pendientes esperan en una cola de tamaño limitado.

### 5.6 Métricas por solicitud

Conforme a la rúbrica, cada solicitud registra: filtro, ancho, alto, dimensiones de bloque y
de malla, total de hilos lanzados, tiempo de kernel (la suma, si se ejecutan varios), tiempo
de copia CPU→GPU y GPU→CPU, y estado. Los tiempos se miden con eventos CUDA.

## 6. Límites y errores

El servicio no redimensiona la imagen. La aplicación móvil reduce el lado mayor a 2048 px
antes de enviarla; el servicio acepta cualquier imagen dentro de los límites siguientes,
definidos en `src/config.py`, hasta `MAX_LADO`.

| Variable | Valor por defecto | Respuesta al excederlo |
|---|---|---|
| `MAX_MB` | 25 MB | 413 |
| `MIN_LADO` | 64 px | 422 |
| `MAX_LADO` | 12 000 px | 413 |
| `MAX_PIXELES` | 50 000 000 | 413 |
| `MAX_COLA` | 4 solicitudes | 429 |
| `TTL_MIN` | 10 min | El resultado se elimina |
| `BLOQUE` | 16 | — |

Los servicios lanzan `ErrorServicio` con un código de texto; `main.py` lo traduce a HTTP
con la tabla `ESTADOS_HTTP`.

| HTTP | Código (`error`) | Causa |
|---|---|---|
| 413 | `archivo_muy_grande` | El archivo pesa más de `MAX_MB` |
| 413 | `lado_excedido` | Un lado pasa de `MAX_LADO` |
| 413 | `pixeles_excedidos` | Ancho × alto pasa de `MAX_PIXELES` |
| 415 | `formato_no_admitido` | No es JPG, PNG ni WEBP (el formato se lee del contenido, no de la extensión) |
| 415 | `imagen_danada` | El archivo está incompleto o no se pueden leer sus píxeles |
| 422 | `imagen_muy_pequena` | Un lado mide menos de `MIN_LADO` |
| 422 | `parametro_invalido` | Filtro inexistente, parámetro fuera de rango o con tipo equivocado |
| 404 | `resultado_no_encontrado` | El id no existe o el resultado ya se borró |
| 429 | `cola_llena` | Hay `MAX_COLA` solicitudes en curso |
| 503 | `gpu_no_disponible` | No se pudo iniciar CUDA |
| 507 | `memoria_gpu_insuficiente` | La imagen no cabe en la memoria libre de la GPU |
| 500 | `error_cuda`, `error_interno` | Falla inesperada |

Cuerpo de todos los errores:

```json
{
  "id": "6c67442aaa9b4838894b1eba38dc9d11",
  "estado": "error",
  "error": "pixeles_excedidos",
  "detalle": "La imagen tiene 50,400,000 píxeles; el máximo es 50,000,000",
  "metricas": null
}
```

`metricas` es `null` porque la solicitud falló antes de lanzar los kernels.

## 7. Interfaz REST

Base: `http://<host>:8000`. Toda respuesta lleva la cabecera `X-Request-Id`, igual al `id`
del cuerpo y al que aparece en los registros del servicio. La documentación interactiva, con
la que se puede probar cada ruta, está en `/docs`.

```bash
cd upsglam_gpu_service
.venv/bin/python src/main.py
```

| Método | Ruta | Uso |
|---|---|---|
| `POST` | `/api/procesar` | Aplica un filtro y devuelve el id y las métricas |
| `GET` | `/api/resultados/{id}` | Descarga la imagen procesada (JPEG) |
| `GET` | `/api/filtros` | Filtros y parámetros admitidos |
| `GET` | `/api/salud` | Estado de la GPU, la cola y los límites; 503 si no hay GPU |

### 7.1 `POST /api/procesar`

Petición `multipart/form-data`:

| Campo | Obligatorio | Valores |
|---|---|---|
| `imagen` | Sí | Archivo JPG, PNG o WEBP |
| `filtro` | Sí | `media`, `nitidez`, `laplaciano`, `sobel`, `relieve`, `ups` |
| `nivel` | No | Solo `media`: `bajo`, `medio`, `fuerte` |
| `intensidad` | No | `nitidez` y `relieve`: 0 a 2; `laplaciano`: 3 a 10 |
| `direccion` | No | Solo `sobel`: `horizontal`, `vertical`, `ambas` |

Los parámetros omitidos toman el valor por defecto de la sección 4. Los que el filtro no usa
se ignoran (la documentación interactiva envía todos los campos); `parametros`, en la
respuesta, indica los que se aplicaron.

Respuesta 200:

```json
{
  "id": "0d6f1c3e9b6a4f0e8f7d2a1b3c4d5e6f",
  "estado": "ok",
  "filtro": "laplaciano",
  "parametros": {"intensidad": 6.0},
  "ancho": 1920,
  "alto": 1280,
  "metricas": {
    "bloque": [16, 16, 1],
    "grid": [120, 80],
    "hilos_lanzados": 4915200,
    "ms_kernel": 4.46,
    "ms_cpu_gpu": 3.3,
    "ms_gpu_cpu": 3.2,
    "kernels": [
      {"kernel": "convolucion_gris", "bloque": [16, 16, 1], "grid": [120, 80], "hilos": 2457600, "ms": 1.1},
      {"kernel": "convolucion_gris", "bloque": [16, 16, 1], "grid": [120, 80], "hilos": 2457600, "ms": 3.36}
    ]
  },
  "tiempos_ms": {"decodificacion": 46.3, "cola": 0.1, "gpu": 37.2, "codificacion": 11.0, "total": 94.8},
  "url_resultado": "/api/resultados/0d6f1c3e9b6a4f0e8f7d2a1b3c4d5e6f"
}
```

- `metricas` contiene lo que exige la rúbrica. Cuando el filtro lanza varios kernels,
  `hilos_lanzados` y `ms_kernel` son la suma y `kernels` detalla cada uno.
- `tiempos_ms.gpu` incluye copias, kernels y los pasos en CPU del filtro; `total` abarca toda
  la solicitud.
- `parametros` devuelve los valores aplicados, incluidos los valores por defecto.
- `ancho` y `alto` corresponden a la imagen ya girada según su orientación EXIF.

### 7.2 `GET /api/resultados/{id}`

Devuelve la imagen en JPEG (calidad 92): en color para Media, Nitidez, Relieve y UPS, y en
gris para Laplaciano y Sobel. El resultado se borra a los `TTL_MIN` minutos; después la ruta
responde 404.

### 7.3 Uso desde el backend Java

El backend envía la foto con `WebClient` (multipart), lee el JSON y, con el `id`, descarga
la imagen para guardarla en Supabase Storage. Ante 429 puede reintentar tras unos segundos;
ante 503 o 507 no tiene sentido reintentar de inmediato.

## 8. Validación

```bash
cd upsglam_gpu_service
.venv/bin/python pruebas/validacion.py
```

La validación comprende tres grupos de pruebas:

1. Casos con resultado conocido: imagen uniforme, escalón e impulso.
2. Cada kernel comparado con una implementación de referencia en NumPy, en `float` y antes del
   recorte (tolerancia 0,02), con tamaños que no son múltiplos del bloque (1×1, 5×7, 17×33,
   40×23).
3. Los seis filtros completos comparados en 8 bits (tolerancia de 1 nivel).

La ejecución debe terminar con el mensaje `N/N correctas`.

Con el servicio en ejecución, `pruebas/prueba_api.py` prueba la API completa: los seis
filtros con sus métricas y la descarga del resultado; entradas PNG de 16 bits, con
transparencia, con paleta, en gris, CMYK, WEBP y JPG con orientación EXIF; y los errores 404,
413, 415, 422 y 429.

```bash
.venv/bin/python pruebas/prueba_api.py
```

Los errores 503 (sin GPU) y 413 por peso se comprueban a mano, iniciando una segunda
instancia con `CUDA_VISIBLE_DEVICES=""`, `PUERTO=8001` y `MAX_MB=1`. El 507 no tiene prueba
automática.

## 9. Normas para modificar el servicio

- Ningún paso de un filtro se ejecuta en CPU sin que así se asigne en la clase `Pasos`, y
  nunca como sustituto silencioso de la GPU.
- Los límites nuevos se declaran en `config.py`, y los parámetros de filtro en `PARAMETROS`
  de `filtros.py`.
- Todo cambio en un kernel o en un filtro debe pasar `pruebas/validacion.py` completo, y
  todo cambio en la API o en los servicios, `pruebas/prueba_api.py`.
- Un código de error nuevo se agrega a `ESTADOS_HTTP` en `main.py` y a la tabla de la
  sección 6.
- Este documento se actualiza junto con el cambio.
