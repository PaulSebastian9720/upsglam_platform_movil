"""Utilidades de imagen con Pillow y NumPy, en la CPU.

Preparan la entrada y entregan la salida de los filtros; las convoluciones van en
gpu/motor.py. Siguen el mismo contrato que los pasos de la GPU (arreglo y parámetros de
entrada, arreglo de salida), así que filtros.Pasos puede usar una u otra.
"""

import numpy as np
from PIL import Image, ImageOps


# RGB de 8 bits a gris de 8 bits con la fórmula de Pillow: 0.299 R + 0.587 G + 0.114 B.
def a_gris(imagen):
    return np.asarray(Image.fromarray(imagen, "RGB").convert("L"))


# Bordes del Laplaciano: valen igual si el cambio es de claro a oscuro o al revés.
def valor_absoluto(arreglo):
    return np.abs(arreglo)


# Resultado en float de la GPU a 8 bits: redondeo y recorte entre 0 y 255.
def a_8bits(arreglo):
    return np.clip(np.rint(arreglo), 0, 255).astype(np.uint8)


# Cualquier imagen abierta con Pillow a RGB de 8 bits (alto x ancho x 3):
# - gira la foto según la orientación EXIF que guardan los celulares;
# - un gris de 16 o 32 bits (PNG de 16 bits) baja a 8 bits por escala, no por recorte;
# - la transparencia (RGBA, LA, paleta con transparencia) se pone sobre fondo blanco;
# - paleta, gris, blanco y negro y CMYK pasan a RGB.
def a_rgb(imagen):
    imagen = ImageOps.exif_transpose(imagen)
    if imagen.mode in ("I;16", "I;16B", "I;16L", "I"):
        valores = np.asarray(imagen, dtype=np.float64)
        maximo = 65535.0 if imagen.mode.startswith("I;16") or valores.max() > 255 else 255.0
        imagen = Image.fromarray(np.rint(valores * 255.0 / maximo).astype(np.uint8), "L")
    elif imagen.mode == "F":
        imagen = Image.fromarray(np.clip(np.rint(np.asarray(imagen)), 0, 255).astype(np.uint8), "L")
    if imagen.mode == "P" and "transparency" in imagen.info:
        imagen = imagen.convert("RGBA")
    if imagen.mode in ("RGBA", "LA", "PA"):
        rgba = imagen.convert("RGBA")
        imagen = Image.new("RGB", imagen.size, (255, 255, 255))
        imagen.paste(rgba, mask=rgba.getchannel("A"))
    return np.asarray(imagen.convert("RGB"))


# Resultado de 8 bits (RGB o gris) a JPEG. Calidad 92: sin artefactos visibles y mucho
# más liviano que PNG en fotos.
def guardar_jpeg(arreglo, ruta):
    Image.fromarray(arreglo).save(ruta, "JPEG", quality=92)
