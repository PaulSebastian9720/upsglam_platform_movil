"""Pasos de los filtros que corren en la GPU, sin nada de HTTP.

Cada paso sigue el mismo contrato que los de utils/imagen.py: recibe un arreglo de NumPy y
sus parámetros y devuelve otro arreglo; las medidas se anotan en el objeto Medidas que se
le pasa. Así un paso se puede mover entre CPU y GPU cambiando una línea de filtros.py.

Las entradas se suben como float32 de 0 a 255 y las salidas vuelven en float32 sin
recortar; el recorte a 8 bits lo hace utils/imagen.py.
"""

import time

import numpy as np
import pycuda
import pycuda.driver as cuda

from config import BLOQUE
from gpu.compilador import compilar_ptx
from modelos import Lanzamiento

MAX_K = 21  # el mismo de gpu/kernels.py
SOBEL = {"horizontal": 0, "vertical": 1, "ambas": 2}


# Prepara la GPU una sola vez: contexto y kernels compilados. El contexto queda activo en el
# hilo que crea el objeto, así que todas las llamadas deben hacerse desde ese mismo hilo.
class MotorGpu:

    def __init__(self, numero_gpu=0):
        inicio = time.perf_counter()
        cuda.init()
        self.dispositivo = cuda.Device(numero_gpu)
        self.contexto = self.dispositivo.make_context()
        self.ms_contexto = (time.perf_counter() - inicio) * 1000

        try:
            inicio = time.perf_counter()
            modulo = cuda.module_from_buffer(
                compilar_ptx(self.dispositivo.compute_capability()))
            self.ms_compilacion = (time.perf_counter() - inicio) * 1000
            self.kernels = {nombre: modulo.get_function(nombre) for nombre in
                            ("convolucion_rgb", "convolucion_gris", "sobel", "colorear_ups")}
            self.mascara, _ = modulo.get_global("mascara")
        except Exception:
            self.cerrar()
            raise

    def cerrar(self):
        self.contexto.pop()
        self.contexto.detach()

    def memoria_libre(self):
        return cuda.mem_get_info()[0]

    def info(self):
        libre, total = cuda.mem_get_info()
        driver = cuda.get_driver_version()
        return {
            "nombre": self.dispositivo.name(),
            "capacidad": "%d.%d" % self.dispositivo.compute_capability(),
            "memoria_total_mb": round(total / 2**20),
            "memoria_libre_mb": round(libre / 2**20),
            "driver_cuda": f"{driver // 1000}.{driver % 1000 // 10}",
            "pycuda": pycuda.VERSION_TEXT,
            "ms_contexto": self.ms_contexto,
            "ms_compilacion": self.ms_compilacion,
        }

    # ---- Pasos ----

    # Aplica las máscaras una tras otra sobre los tres canales. imagen: alto x ancho x 3.
    def convolucion_rgb(self, imagen, mascaras, medidas):
        return self._convoluciones("convolucion_rgb", imagen, mascaras, medidas)

    # Igual sobre un canal. imagen: alto x ancho. El Laplaciano pasa [gaussiano, laplaciano]
    # y las dos convoluciones se encadenan dentro de la GPU, sin volver a la CPU.
    def convolucion_gris(self, imagen, mascaras, medidas):
        return self._convoluciones("convolucion_gris", imagen, mascaras, medidas)

    # Magnitud de Sobel de una imagen gris: "horizontal", "vertical" o "ambas".
    def sobel(self, gris, direccion, medidas):
        alto, ancho = gris.shape
        with _Memoria() as memoria:
            entrada = self._subir(gris, memoria, medidas)
            salida = memoria.reservar(gris.shape)
            self._lanzar("sobel", (entrada, salida), ancho, alto,
                         (np.int32(SOBEL[direccion]),), medidas)
            return self._bajar(salida, gris.shape, medidas)

    # Colores UPS de una imagen gris: Sobel en ambas direcciones y luego el degradado azul y
    # amarillo con los bordes encima. Los bordes no salen de la GPU. Devuelve alto x ancho x 3.
    def colorear_ups(self, gris, fuerza, medidas):
        alto, ancho = gris.shape
        forma = (alto, ancho, 3)
        with _Memoria() as memoria:
            entrada = self._subir(gris, memoria, medidas)
            bordes = memoria.reservar(gris.shape)
            salida = memoria.reservar(forma)
            self._lanzar("sobel", (entrada, bordes), ancho, alto,
                         (np.int32(SOBEL["ambas"]),), medidas)
            self._lanzar("colorear_ups", (entrada, bordes, salida), ancho, alto,
                         (np.float32(fuerza),), medidas)
            return self._bajar(salida, forma, medidas)

    # ---- Apoyo ----

    # Con varias máscaras se alternan dos búferes: la salida de una es la entrada de la otra.
    def _convoluciones(self, kernel, imagen, mascaras, medidas):
        alto, ancho = imagen.shape[:2]
        with _Memoria() as memoria:
            actual = self._subir(imagen, memoria, medidas)
            siguiente = memoria.reservar(imagen.shape)
            for mascara in mascaras:
                k = _copiar_mascara(self.mascara, mascara)
                self._lanzar(kernel, (actual, siguiente), ancho, alto, (np.int32(k),), medidas)
                actual, siguiente = siguiente, actual
            return self._bajar(actual, imagen.shape, medidas)

    # Lanza un kernel con bloques BLOQUE x BLOQUE y los bloques justos para cubrir la imagen.
    # Los argumentos van como np.int32 / np.float32 porque PyCUDA no convierte tipos.
    def _lanzar(self, nombre, arreglos, ancho, alto, extra, medidas):
        bloque = (BLOQUE, BLOQUE, 1)
        grid = ((ancho + BLOQUE - 1) // BLOQUE, (alto + BLOQUE - 1) // BLOQUE)
        inicio, fin = cuda.Event(), cuda.Event()
        inicio.record()
        self.kernels[nombre](*arreglos, np.int32(ancho), np.int32(alto), *extra,
                             block=bloque, grid=grid)
        fin.record()
        fin.synchronize()
        medidas.lanzamientos.append(Lanzamiento(
            kernel=nombre, bloque=bloque, grid=grid,
            hilos=BLOQUE * BLOQUE * grid[0] * grid[1], ms=inicio.time_till(fin)))

    def _subir(self, arreglo, memoria, medidas):
        datos = np.ascontiguousarray(arreglo, dtype=np.float32)
        destino = memoria.reservar(datos.shape)
        inicio, fin = cuda.Event(), cuda.Event()
        inicio.record()
        cuda.memcpy_htod(destino, datos)
        fin.record()
        fin.synchronize()
        medidas.ms_cpu_gpu += inicio.time_till(fin)
        return destino

    def _bajar(self, origen, forma, medidas):
        datos = np.empty(forma, dtype=np.float32)
        inicio, fin = cuda.Event(), cuda.Event()
        inicio.record()
        cuda.memcpy_dtoh(datos, origen)
        fin.record()
        fin.synchronize()
        medidas.ms_gpu_cpu += inicio.time_till(fin)
        return datos


def _copiar_mascara(destino, mascara):
    mascara = np.ascontiguousarray(mascara, dtype=np.float32)
    k = mascara.shape[0]
    if mascara.shape != (k, k) or k % 2 == 0 or k > MAX_K:
        raise ValueError(f"La máscara debe ser cuadrada, impar y de hasta {MAX_K}x{MAX_K}")
    cuda.memcpy_htod(destino, mascara)
    return k


# Reservas de una llamada; se liberan al salir, también si falla una reserva o un kernel.
# Cada búfer nuevo se llena con 0xFF (NaN en float) para detectar píxeles que ningún hilo
# escribió.
class _Memoria:

    def __enter__(self):
        self.reservas = []
        return self

    def reservar(self, forma):
        tam = int(np.prod(forma)) * 4
        reserva = cuda.mem_alloc(tam)
        self.reservas.append(reserva)
        cuda.memset_d8(reserva, 0xFF, tam)
        return reserva

    def __exit__(self, *_):
        for reserva in self.reservas:
            reserva.free()
