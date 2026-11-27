"""Kernels CUDA de los filtros de UPSGlam, como texto para compilarlos con NVRTC
al iniciar el servicio (gpu/compilador.py).

Todos usan bloques 2D: cada hilo calcula un píxel, con la columna en X y la fila en Y.
Los hilos que caen fuera de la imagen (último bloque de cada fila o columna) salen sin
escribir. Las imágenes son float de 0 a 255; las de color van intercaladas (R, G, B por
píxel), como las entrega NumPy.

Bordes: cuando la máscara se sale de la imagen, el vecino toma el valor del píxel más
cercano dentro de ella (se repite el borde). Con 0, como en la práctica 02, la orilla se
oscurece y la media de 21x21 deja un marco negro de 10 píxeles.

NVRTC compila como C++; extern "C" deja los nombres tal cual para buscarlos desde Python.
"""

# Nombre con el que NVRTC reporta los errores de compilación.
NOMBRE = "kernels.cu"

FUENTE = r"""
#define MAX_K 21

extern "C" {

// Máscara en memoria constante: todos los hilos de un warp leen el mismo coeficiente a la
// vez y la caché constante lo reparte en una sola lectura. Se copia antes de cada kernel.
__constant__ float mascara[MAX_K * MAX_K];

__device__ __forceinline__ int recortar(int valor, int limite) {
    return min(max(valor, 0), limite - 1);
}

// Convolución k x k sobre los tres canales. Media, Nitidez y Relieve.
__global__ void convolucion_rgb(const float* entrada, float* salida,
                                int ancho, int alto, int k) {
    const int col = blockIdx.x * blockDim.x + threadIdx.x;
    const int fila = blockIdx.y * blockDim.y + threadIdx.y;
    if (col >= ancho || fila >= alto) {
        return;
    }

    const int radio = k / 2;
    float r = 0.0f, g = 0.0f, b = 0.0f;
    for (int i = 0; i < k; i++) {
        const int f = recortar(fila + i - radio, alto);
        for (int j = 0; j < k; j++) {
            const int c = recortar(col + j - radio, ancho);
            const float peso = mascara[i * k + j];
            const int vecino = (f * ancho + c) * 3;
            r += entrada[vecino] * peso;
            g += entrada[vecino + 1] * peso;
            b += entrada[vecino + 2] * peso;
        }
    }
    const int indice = (fila * ancho + col) * 3;
    salida[indice] = r;
    salida[indice + 1] = g;
    salida[indice + 2] = b;
}

// Convolución k x k sobre un canal. Gaussiano y Laplaciano.
__global__ void convolucion_gris(const float* entrada, float* salida,
                                 int ancho, int alto, int k) {
    const int col = blockIdx.x * blockDim.x + threadIdx.x;
    const int fila = blockIdx.y * blockDim.y + threadIdx.y;
    if (col >= ancho || fila >= alto) {
        return;
    }

    const int radio = k / 2;
    float suma = 0.0f;
    for (int i = 0; i < k; i++) {
        const int f = recortar(fila + i - radio, alto);
        for (int j = 0; j < k; j++) {
            const int c = recortar(col + j - radio, ancho);
            suma += entrada[f * ancho + c] * mascara[i * k + j];
        }
    }
    salida[fila * ancho + col] = suma;
}

// Sobel sobre un canal con sus dos máscaras 3x3 fijas:
//   gx = [-1 0 1; -2 0 2; -1 0 1]   cambia de izquierda a derecha: marca bordes verticales
//   gy = [-1 -2 -1; 0 0 0; 1 2 1]   cambia de arriba abajo: marca bordes horizontales
// direccion: 0 = horizontales |gy|, 1 = verticales |gx|, 2 = ambas sqrt(gx² + gy²).
__global__ void sobel(const float* entrada, float* salida, int ancho, int alto,
                      int direccion) {
    const int col = blockIdx.x * blockDim.x + threadIdx.x;
    const int fila = blockIdx.y * blockDim.y + threadIdx.y;
    if (col >= ancho || fila >= alto) {
        return;
    }

    const int arriba = recortar(fila - 1, alto) * ancho;
    const int centro = fila * ancho;
    const int abajo = recortar(fila + 1, alto) * ancho;
    const int izq = recortar(col - 1, ancho);
    const int der = recortar(col + 1, ancho);

    const float a = entrada[arriba + izq], b = entrada[arriba + col], c = entrada[arriba + der];
    const float d = entrada[centro + izq],                            e = entrada[centro + der];
    const float f = entrada[abajo + izq],  g = entrada[abajo + col],  h = entrada[abajo + der];

    const float gx = (c + 2.0f * e + h) - (a + 2.0f * d + f);
    const float gy = (f + 2.0f * g + h) - (a + 2.0f * b + c);

    float valor;
    if (direccion == 0) {
        valor = fabsf(gy);
    } else if (direccion == 1) {
        valor = fabsf(gx);
    } else {
        valor = sqrtf(gx * gx + gy * gy);
    }
    salida[centro + col] = valor;
}

// Colores UPS. El gris elige el fondo dentro del degradado azul #013871 (oscuro) a
// amarillo #FFC72C (claro). Encima se pintan los bordes de Sobel con el color contrario al
// fondo, para que se vean en las dos zonas; fuerza escala cuánto se marcan.
__global__ void colorear_ups(const float* gris, const float* bordes, float* salida,
                             int ancho, int alto, float fuerza) {
    const int col = blockIdx.x * blockDim.x + threadIdx.x;
    const int fila = blockIdx.y * blockDim.y + threadIdx.y;
    if (col >= ancho || fila >= alto) {
        return;
    }

    const float azul[3] = {1.0f, 56.0f, 113.0f};
    const float amarillo[3] = {255.0f, 199.0f, 44.0f};

    const int indice = fila * ancho + col;
    const float t = gris[indice] / 255.0f;
    const float peso_borde = fminf(bordes[indice] / 255.0f * fuerza, 1.0f);
    const float* color_borde = t < 0.5f ? amarillo : azul;

    for (int canal = 0; canal < 3; canal++) {
        const float fondo = azul[canal] + t * (amarillo[canal] - azul[canal]);
        salida[indice * 3 + canal] = fondo + peso_borde * (color_borde[canal] - fondo);
    }
}

}  // extern "C"
"""
