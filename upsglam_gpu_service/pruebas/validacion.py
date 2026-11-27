"""Valida los kernels contra NumPy con entradas pequeñas.

    python pruebas/validacion.py

Tres grupos de pruebas:
  1. Resultados conocidos que se pueden calcular a mano (foto plana, escalón, impulso).
  2. Cada paso de la GPU contra una referencia en NumPy, en float y antes del recorte, con
     tamaños que no son múltiplo del bloque (1x1, 5x7, 17x33...).
  3. Los seis filtros completos, ya en 8 bits, contra la misma cadena hecha en NumPy.
Termina con código 1 si alguna falla.
"""

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))

import filtros  # noqa: E402
from utils import imagen as util_imagen  # noqa: E402
from gpu.motor import MotorGpu  # noqa: E402
from modelos import Medidas  # noqa: E402

# Error admitido en la escala 0-255 antes del recorte, el mismo de la práctica: la media
# 21x21 acumula 441 sumas en float32. En 8 bits se admite 1 por el redondeo de x.5.
TOLERANCIA = 0.02
TOLERANCIA_8BITS = 1

TAMANOS = [(1, 1), (5, 7), (16, 16), (17, 33), (40, 23)]

GX = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]], dtype=np.float64)
GY = np.array([[-1, -2, -1], [0, 0, 0], [1, 2, 1]], dtype=np.float64)

resultados = []


def comprobar(nombre, obtenido, esperado, tolerancia):
    obtenido = np.asarray(obtenido, dtype=np.float64)
    esperado = np.asarray(esperado, dtype=np.float64)
    if obtenido.shape != esperado.shape:
        resultados.append((nombre, False, f"forma {obtenido.shape} != {esperado.shape}"))
        return
    sin_calcular = int(np.isnan(obtenido).sum())
    diferencia = float(np.nanmax(np.abs(obtenido - esperado))) if obtenido.size else 0.0
    bien = sin_calcular == 0 and diferencia <= tolerancia
    resultados.append((nombre, bien, f"dif. máx {diferencia:.4g}, sin calcular {sin_calcular}"))


# ---- Referencias en NumPy, independientes del código de la GPU ----

# Correlación con bordes repetidos (np.pad mode="edge"), como hacen los kernels.
def ref_convolucion(imagen, mascara):
    imagen = imagen.astype(np.float64)
    k = mascara.shape[0]
    r = k // 2
    relleno = [(r, r), (r, r)] + [(0, 0)] * (imagen.ndim - 2)
    ampliada = np.pad(imagen, relleno, mode="edge")
    alto, ancho = imagen.shape[:2]
    salida = np.zeros_like(imagen)
    for i in range(k):
        for j in range(k):
            salida += ampliada[i:i + alto, j:j + ancho] * float(mascara[i, j])
    return salida


def ref_sobel(gris, direccion):
    gx = ref_convolucion(gris, GX)
    gy = ref_convolucion(gris, GY)
    return {"horizontal": np.abs(gy), "vertical": np.abs(gx),
            "ambas": np.sqrt(gx ** 2 + gy ** 2)}[direccion]


def ref_ups(gris, fuerza):
    azul = np.array([1, 56, 113], dtype=np.float64)
    amarillo = np.array([255, 199, 44], dtype=np.float64)
    t = gris.astype(np.float64)[..., None] / 255
    peso = np.minimum(ref_sobel(gris, "ambas")[..., None] / 255 * fuerza, 1)
    fondo = azul + t * (amarillo - azul)
    borde = np.where(t < 0.5, amarillo, azul)
    return fondo + peso * (borde - fondo)


def ref_filtro(nombre, imagen, parametros):
    gris = util_imagen.a_gris(imagen)
    if nombre == "media":
        k = filtros.TAMANO_MEDIA[parametros["nivel"]]
        valores = ref_convolucion(imagen, filtros.mascara_media(k))
    elif nombre == "nitidez":
        valores = ref_convolucion(imagen, filtros.mezclar(filtros.NITIDEZ, parametros["intensidad"]))
    elif nombre == "relieve":
        valores = ref_convolucion(imagen, filtros.mezclar(filtros.RELIEVE, parametros["intensidad"]))
    elif nombre == "laplaciano":
        suave = ref_convolucion(gris, filtros.GAUSSIANO)
        valores = np.abs(ref_convolucion(suave, filtros.LAPLACIANO)) * parametros["intensidad"]
    elif nombre == "sobel":
        valores = ref_sobel(gris, parametros["direccion"])
    else:
        valores = ref_ups(gris, filtros.FUERZA_BORDES_UPS)
    return np.clip(np.rint(valores), 0, 255).astype(np.uint8)


# ---- Pruebas ----

def conocidos(gpu):
    plana = np.full((13, 20, 3), 100, dtype=np.uint8)
    gris_plana = np.full((13, 20), 100, dtype=np.float32)
    # Con bordes repetidos una foto plana no cambia, ni siquiera en la orilla.
    for k in (3, 9, 21):
        comprobar(f"plana: media {k}x{k} = 100",
                  gpu.convolucion_rgb(plana, [filtros.mascara_media(k)], Medidas()), plana, TOLERANCIA)
    comprobar("plana: relieve = 100",
              gpu.convolucion_rgb(plana, [filtros.RELIEVE], Medidas()), plana, TOLERANCIA)
    comprobar("plana: Laplaciano = 0",
              gpu.convolucion_gris(gris_plana, [filtros.GAUSSIANO, filtros.LAPLACIANO], Medidas()),
              np.zeros((13, 20)), TOLERANCIA)
    comprobar("plana: Sobel = 0", gpu.sobel(gris_plana, "ambas", Medidas()),
              np.zeros((13, 20)), TOLERANCIA)

    # Escalón vertical 0 | 200: Sobel vertical vale 4 * 200 en las dos columnas del borde.
    escalon = np.zeros((6, 8), dtype=np.float32)
    escalon[:, 4:] = 200
    esperado = np.zeros((6, 8))
    esperado[:, 3:5] = 800
    comprobar("escalón: Sobel vertical = 800 en el borde",
              gpu.sobel(escalon, "vertical", Medidas()), esperado, TOLERANCIA)
    comprobar("escalón: Sobel horizontal = 0",
              gpu.sobel(escalon, "horizontal", Medidas()), np.zeros((6, 8)), TOLERANCIA)

    # Impulso de 255: la media 3x3 lo reparte en 255/9 sobre sus 9 vecinos.
    impulso = np.zeros((5, 5, 3), dtype=np.uint8)
    impulso[2, 2] = 255
    esperado = np.zeros((5, 5, 3))
    esperado[1:4, 1:4] = 255 / 9
    comprobar("impulso: media 3x3 = 255/9",
              gpu.convolucion_rgb(impulso, [filtros.mascara_media(3)], Medidas()), esperado, TOLERANCIA)


def pasos_contra_numpy(gpu, azar):
    for alto, ancho in TAMANOS:
        tam = f"{ancho}x{alto}"
        color = azar.integers(0, 256, (alto, ancho, 3), dtype=np.uint8)
        gris = azar.integers(0, 256, (alto, ancho), dtype=np.uint8)
        for k in (3, 9, 21):
            mascara = azar.uniform(-1, 1, (k, k)).astype(np.float32)
            comprobar(f"convolucion_rgb {k}x{k} {tam}",
                      gpu.convolucion_rgb(color, [mascara], Medidas()),
                      ref_convolucion(color, mascara), TOLERANCIA * k)
        comprobar(f"convolucion_gris gaussiano+Laplaciano {tam}",
                  gpu.convolucion_gris(gris, [filtros.GAUSSIANO, filtros.LAPLACIANO], Medidas()),
                  ref_convolucion(ref_convolucion(gris, filtros.GAUSSIANO), filtros.LAPLACIANO),
                  TOLERANCIA)
        for direccion in ("horizontal", "vertical", "ambas"):
            comprobar(f"sobel {direccion} {tam}", gpu.sobel(gris, direccion, Medidas()),
                      ref_sobel(gris, direccion), TOLERANCIA)
        comprobar(f"colorear_ups {tam}", gpu.colorear_ups(gris, 1.0, Medidas()),
                  ref_ups(gris, 1.0), TOLERANCIA)


def filtros_completos(gpu, azar):
    pasos = filtros.Pasos(gpu)
    casos = [("media", {"nivel": n}) for n in ("bajo", "medio", "fuerte")]
    casos += [("nitidez", {"intensidad": i}) for i in (0.0, 1.0, 2.0)]
    casos += [("laplaciano", {"intensidad": i}) for i in (3.0, 6.0, 10.0)]
    casos += [("sobel", {"direccion": d}) for d in ("horizontal", "vertical", "ambas")]
    casos += [("relieve", {"intensidad": i}) for i in (0.0, 1.0, 2.0)]
    casos += [("ups", {})]
    imagen = azar.integers(0, 256, (37, 50, 3), dtype=np.uint8)
    for nombre, parametros in casos:
        medidas = Medidas()
        salida = filtros.aplicar(pasos, nombre, imagen, parametros, medidas)
        etiqueta = f"filtro {nombre} {parametros}"
        comprobar(etiqueta, salida, ref_filtro(nombre, imagen, parametros), TOLERANCIA_8BITS)
        # Medidas: cada lanzamiento cubre la imagen y tiene tiempo.
        cubren = all(l.hilos >= 50 * 37 and l.ms > 0 for l in medidas.lanzamientos)
        resultados.append((f"{etiqueta} medidas", bool(medidas.lanzamientos) and cubren,
                           f"{len(medidas.lanzamientos)} kernels, {medidas.ms_kernel:.3f} ms"))


def main():
    gpu = MotorGpu()
    try:
        print(gpu.info())
        azar = np.random.default_rng(7)
        conocidos(gpu)
        pasos_contra_numpy(gpu, azar)
        filtros_completos(gpu, azar)
    finally:
        gpu.cerrar()

    fallos = [r for r in resultados if not r[1]]
    for nombre, bien, detalle in resultados:
        print(f"{'OK   ' if bien else 'FALLO'} {nombre}: {detalle}")
    print(f"\n{len(resultados) - len(fallos)}/{len(resultados)} correctas")
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
