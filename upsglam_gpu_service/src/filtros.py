"""Los seis filtros: sus máscaras, sus parámetros y los pasos que encadena cada uno.

Cada filtro recibe la foto en RGB de 8 bits (alto x ancho x 3) y devuelve 8 bits: RGB para
Media, Nitidez, Relieve y UPS, gris (alto x ancho) para Laplaciano y Sobel.
"""

from dataclasses import dataclass

import numpy as np

from utils import imagen


# Qué implementación usa cada paso. Para mover un paso entre CPU y GPU se cambia su línea
# aquí; los filtros, el servicio y la API no cambian, porque todos siguen el mismo contrato.
class Pasos:

    def __init__(self, gpu):
        self.a_gris = imagen.a_gris
        self.convolucion_rgb = gpu.convolucion_rgb
        self.convolucion_gris = gpu.convolucion_gris
        self.sobel = gpu.sobel
        self.colorear_ups = gpu.colorear_ups
        self.valor_absoluto = imagen.valor_absoluto
        self.a_8bits = imagen.a_8bits


# ---- Parámetros de cada filtro ----

@dataclass(frozen=True)
class Opcion:
    valores: tuple
    defecto: str


@dataclass(frozen=True)
class Rango:
    minimo: float
    maximo: float
    defecto: float


PARAMETROS = {
    "media": {"nivel": Opcion(("bajo", "medio", "fuerte"), "medio")},
    "nitidez": {"intensidad": Rango(0.0, 2.0, 1.0)},
    "laplaciano": {"intensidad": Rango(1.0, 10.0, 6.0)},
    "sobel": {"direccion": Opcion(("horizontal", "vertical", "ambas"), "ambas")},
    "relieve": {"intensidad": Rango(0.0, 2.0, 1.0)},
    "ups": {},
}

# ---- Máscaras ----

TAMANO_MEDIA = {"bajo": 3, "medio": 9, "fuerte": 21}

NITIDEZ = np.array([[0, -1, 0],
                    [-1, 5, -1],
                    [0, -1, 0]], dtype=np.float32)

LAPLACIANO = np.array([[0, 1, 0],
                       [1, -4, 1],
                       [0, 1, 0]], dtype=np.float32)

# Suma 1: las zonas planas conservan su color y solo los cambios quedan en relieve.
RELIEVE = np.array([[-2, -1, 0],
                    [-1, 1, 1],
                    [0, 1, 2]], dtype=np.float32)

# Gaussiano 5x5 (fila 1 4 6 4 1 por sí misma, entre 256). Suaviza antes del Laplaciano
# para que el ruido del sensor y del JPG no salga como bordes (Laplaciano del Gaussiano).
_BINOMIAL = np.array([1, 4, 6, 4, 1], dtype=np.float32)
GAUSSIANO = np.outer(_BINOMIAL, _BINOMIAL) / np.float32(256)

# Cuánto se marcan los bordes en UPS; con 1 tapan el degradado en zonas con mucho detalle.
FUERZA_BORDES_UPS = 0.4


def mascara_media(k):
    return np.full((k, k), 1.0 / (k * k), dtype=np.float32)


# Mezcla la máscara con la identidad: 0 deja la foto igual, 1 aplica la máscara tal cual y
# más de 1 exagera el efecto. Como la convolución es lineal, mezclar la máscara equivale a
# mezclar las fotos, y se hace en una sola pasada.
def mezclar(mascara, intensidad):
    identidad = np.zeros_like(mascara)
    centro = mascara.shape[0] // 2
    identidad[centro, centro] = 1.0
    return (identidad + np.float32(intensidad) * (mascara - identidad)).astype(np.float32)


# ---- Filtros ----

def media(p, imagen, medidas, nivel):
    k = TAMANO_MEDIA[nivel]
    return p.a_8bits(p.convolucion_rgb(imagen, [mascara_media(k)], medidas))


def nitidez(p, imagen, medidas, intensidad):
    return p.a_8bits(p.convolucion_rgb(imagen, [mezclar(NITIDEZ, intensidad)], medidas))


def laplaciano(p, imagen, medidas, intensidad):
    bordes = p.convolucion_gris(p.a_gris(imagen), [GAUSSIANO, LAPLACIANO], medidas)
    return p.a_8bits(p.valor_absoluto(bordes, intensidad))


def sobel(p, imagen, medidas, direccion):
    return p.a_8bits(p.sobel(p.a_gris(imagen), direccion, medidas))


def relieve(p, imagen, medidas, intensidad):
    return p.a_8bits(p.convolucion_rgb(imagen, [mezclar(RELIEVE, intensidad)], medidas))


def ups(p, imagen, medidas):
    return p.a_8bits(p.colorear_ups(p.a_gris(imagen), FUERZA_BORDES_UPS, medidas))


FILTROS = {
    "media": media,
    "nitidez": nitidez,
    "laplaciano": laplaciano,
    "sobel": sobel,
    "relieve": relieve,
    "ups": ups,
}


# Aplica un filtro con sus parámetros ya validados.
def aplicar(pasos, nombre, imagen, parametros, medidas):
    return FILTROS[nombre](pasos, imagen, medidas, **parametros)
