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

| Equipo | GPU | Capacidad de cómputo | Uso |
|---|---|---|---|
| PC de desarrollo (Manjaro) | GeForce MX230, 4 GB | 6.1 | Desarrollo y validación |
| PC de demostración (Windows, Docker Desktop) | RTX 5050 | 12.0 | Entrega final |

Los kernels se compilan en tiempo de ejecución con NVRTC 12.9 (paquete
`nvidia-cuda-nvrtc-cu12`) y se cargan con `pycuda.driver.module_from_buffer`. No se emplea
`SourceModule`, porque requiere `nvcc` y la versión instalada en el sistema (CUDA 13) ya no
genera código para la arquitectura Pascal. Con NVRTC el mismo código funciona en ambos
equipos, dentro y fuera de Docker.

## 3. Arquitectura

```
upsglam_gpu_service/
  src/
    main.py               Creación de la aplicación y registro de rutas    (pendiente)
    config.py             Parámetros configurables por variable de entorno
    modelos.py            Estructuras de datos del servicio
    errores.py            Errores y su representación en JSON              (pendiente)
    filtros.py            Definición de los filtros y clase Pasos
    controladores/        Rutas HTTP                                       (pendiente)
    servicios/            Validación, cola de trabajo, archivos temporales (pendiente)
    gpu/
      kernels.py          Código CUDA de los kernels, como texto
      compilador.py       Compilación de los kernels a PTX con NVRTC
      motor.py            Contexto CUDA, memoria, lanzamientos y medición
    utils/
      imagen.py           Conversión a gris, valor absoluto y paso a 8 bits
  pruebas/
    validacion.py         Validación de kernels y filtros contra NumPy
```

El servicio se organiza en capas con dependencias en un solo sentido:

- Los controladores reciben las peticiones HTTP y no acceden a la GPU.
- Los servicios validan, encolan y administran archivos, sin conocer HTTP.
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
| Laplaciano | gris, `convolucion_gris` (gaussiano 5×5 y Laplaciano), valor absoluto | `intensidad` | 1 a 10 | 6 |
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

No se redimensiona la imagen: cada fotografía se procesa con la resolución de la cámara que la
tomó, siempre que esté dentro de los límites siguientes, definidos en `src/config.py`.

| Variable | Valor por defecto | Respuesta al excederlo |
|---|---|---|
| `MAX_MB` | 25 MB | 413 |
| `MIN_LADO` | 64 px | 422 |
| `MAX_LADO` | 12 000 px | 413 |
| `MAX_PIXELES` | 50 000 000 | 413 |
| `MAX_COLA` | 4 solicitudes | 429 |
| `TTL_MIN` | 10 min | El resultado se elimina |
| `BLOQUE` | 16 | — |

Códigos de error:

| Código | Causa |
|---|---|
| 413 | Imagen demasiado grande |
| 415 | Formato no admitido |
| 422 | Parámetros no válidos o imagen demasiado pequeña |
| 429 | Cola de trabajo llena |
| 503 | GPU no disponible |
| 507 | Memoria de GPU insuficiente |

El cuerpo de todos los errores tiene la forma `{"error": ..., "detalle": ..., "id": ...}`.

## 7. Interfaz REST

Pendiente de implementación. Comprenderá un `POST` que recibe la imagen, el filtro y sus
parámetros y devuelve el identificador del resultado con sus métricas; un
`GET /api/resultados/{id}` que entrega la imagen procesada, y un endpoint de salud. La
documentación interactiva estará disponible en `http://localhost:8000/docs`.

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

## 9. Normas para modificar el servicio

- Ningún paso de un filtro se ejecuta en CPU sin que así se asigne en la clase `Pasos`, y
  nunca como sustituto silencioso de la GPU.
- Los límites nuevos se declaran en `config.py`, y los parámetros de filtro en `PARAMETROS`
  de `filtros.py`.
- Todo cambio en un kernel o en un filtro debe pasar `pruebas/validacion.py` completo.
- Este documento se actualiza junto con el cambio.
