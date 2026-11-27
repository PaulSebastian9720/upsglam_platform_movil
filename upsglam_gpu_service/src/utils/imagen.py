"""Utilidades de imagen con Pillow y NumPy, en la CPU.

Preparan la entrada y entregan la salida de los filtros; las convoluciones van en
gpu/motor.py. Siguen el mismo contrato que los pasos de la GPU (arreglo y parámetros de
entrada, arreglo de salida), así que filtros.Pasos puede usar una u otra.
"""

import numpy as np
from PIL import Image


# RGB de 8 bits a gris de 8 bits con la fórmula de Pillow: 0.299 R + 0.587 G + 0.114 B.
def a_gris(imagen):
    return np.asarray(Image.fromarray(imagen, "RGB").convert("L"))


# Bordes del Laplaciano: valen igual si el cambio es de claro a oscuro o al revés.
def valor_absoluto(arreglo, intensidad):
    return np.abs(arreglo) * np.float32(intensidad)


# Resultado en float de la GPU a 8 bits: redondeo y recorte entre 0 y 255.
def a_8bits(arreglo):
    return np.clip(np.rint(arreglo), 0, 255).astype(np.uint8)
