"""Atención de solicitudes: validación, cola de la GPU y resultados. Sin nada de HTTP.

Los errores se lanzan como ErrorServicio con un código de texto; main.py los traduce.
"""

import asyncio
import io
import logging
import re
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from contextlib import contextmanager

import numpy as np
import pycuda.driver as cuda
from PIL import Image

import config
import filtros
from errores import ErrorServicio
from gpu.motor import MotorGpu
from modelos import Medidas, Procesado
from utils import imagen as util_imagen

log = logging.getLogger("servicio")

# Pillow llama MPO al JPEG con varias imágenes que guardan algunos celulares (se usa la
# primera).
FORMATOS = {"JPEG", "MPO", "PNG", "WEBP"}

# Memoria de GPU por píxel en el peor caso: entrada y salida RGB en float32 (2 x 3 x 4 B).
BYTES_GPU_POR_PIXEL = 24

ID_VALIDO = re.compile(r"^[0-9a-f]{32}$")

# Los límites propios se revisan con la cabecera, antes de decodificar; se quita el de
# Pillow para que una imagen enorme reciba el error de límite y no uno de formato.
Image.MAX_IMAGE_PIXELS = None


# ---- Validación ----

# Convierte los parámetros recibidos (None si no llegaron) a sus valores, con los rangos y
# valores por defecto de filtros.PARAMETROS. Los que el filtro no usa se ignoran: /docs y
# los formularios suelen enviar todos los campos; la respuesta indica los que se aplicaron.
def validar_parametros(filtro, recibidos):
    if filtro not in filtros.PARAMETROS:
        raise ErrorServicio("filtro_desconocido",
                            f"El filtro '{filtro}' no existe. Opciones: "
                            f"{', '.join(filtros.PARAMETROS)}")
    permitidos = filtros.PARAMETROS[filtro]

    parametros = {}
    for nombre, regla in permitidos.items():
        valor = recibidos.get(nombre)
        if isinstance(regla, filtros.Opcion):
            valor = regla.defecto if valor is None else valor
            if valor not in regla.valores:
                raise ErrorServicio("parametro_invalido",
                                    f"{nombre}='{valor}' no es válido para {filtro}. "
                                    f"Opciones: {', '.join(regla.valores)}")
        else:
            try:
                valor = regla.defecto if valor is None else float(valor)
            except ValueError:
                raise ErrorServicio("parametro_invalido",
                                    f"{nombre}='{valor}' no es un número") from None
            if not regla.minimo <= valor <= regla.maximo:
                raise ErrorServicio("parametro_invalido",
                                    f"{nombre}={valor} está fuera del rango "
                                    f"{regla.minimo} a {regla.maximo}")
        parametros[nombre] = valor
    return parametros


# Comprueba el formato real (no la extensión) y las dimensiones antes de decodificar los
# píxeles; luego normaliza a RGB de 8 bits.
def abrir(datos):
    try:
        imagen = Image.open(io.BytesIO(datos))
    except Exception:
        raise ErrorServicio("formato_no_admitido",
                            "El archivo no es una imagen JPG, PNG o WEBP") from None
    if imagen.format not in FORMATOS:
        raise ErrorServicio("formato_no_admitido",
                            f"Formato {imagen.format} no admitido. Use JPG, PNG o WEBP")

    ancho, alto = imagen.size
    if ancho < config.MIN_LADO or alto < config.MIN_LADO:
        raise ErrorServicio("imagen_muy_pequena",
                            f"La imagen mide {ancho}x{alto}; cada lado debe tener al menos "
                            f"{config.MIN_LADO} px")
    if ancho > config.MAX_LADO or alto > config.MAX_LADO:
        raise ErrorServicio("lado_excedido",
                            f"La imagen mide {ancho}x{alto}; ningún lado puede pasar de "
                            f"{config.MAX_LADO} px")
    if ancho * alto > config.MAX_PIXELES:
        raise ErrorServicio("pixeles_excedidos",
                            f"La imagen tiene {ancho * alto:,} píxeles; el máximo es "
                            f"{config.MAX_PIXELES:,}")
    try:
        return util_imagen.a_rgb(imagen)
    except Exception:
        raise ErrorServicio("imagen_danada",
                            "No se pudieron leer los píxeles de la imagen") from None


# ---- Servicio ----

# Toda la GPU pasa por un único hilo: el contexto CUDA se crea en él y queda activo ahí, y
# los filtros se ejecutan uno tras otro. Una solicitud ocupa un lugar en la cola desde que
# se acepta hasta que su resultado queda guardado; si ya hay MAX_COLA lugares ocupados, la
# siguiente se rechaza. Así se acota también la memoria del equipo.
class ServicioFiltros:

    def __init__(self):
        config.DIR_RESULTADOS.mkdir(parents=True, exist_ok=True)
        self.ejecutor = ThreadPoolExecutor(max_workers=1, thread_name_prefix="gpu")
        self.motor = None
        self.pasos = None
        self.info_gpu = None
        self.error_inicio = None
        self.pendientes = 0
        self.atendidas = 0
        self.rechazadas = 0
        self.candado = threading.Lock()
        self.ejecutor.submit(self._iniciar).result()

    # Crea el contexto y compila los kernels. El primer lanzamiento de cada kernel carga el
    # módulo en la GPU y tarda más; se hace aquí con una imagen pequeña para que no caiga
    # en la primera solicitud. Si no hay GPU, el servicio arranca igual y responde 503.
    def _iniciar(self):
        try:
            self.motor = MotorGpu()
            self.pasos = filtros.Pasos(self.motor)
            inicio = time.perf_counter()
            prueba = np.zeros((64, 64, 3), dtype=np.uint8)
            for nombre in filtros.FILTROS:
                filtros.aplicar(self.pasos, nombre, prueba,
                                validar_parametros(nombre, {}), Medidas())
            self.info_gpu = self.motor.info()
            self.info_gpu["ms_calentamiento"] = (time.perf_counter() - inicio) * 1000
            log.info("GPU lista: %s (%s) | contexto %.1f ms | compilación %.1f ms | "
                     "calentamiento %.1f ms", self.info_gpu["nombre"],
                     self.info_gpu["capacidad"], self.info_gpu["ms_contexto"],
                     self.info_gpu["ms_compilacion"], self.info_gpu["ms_calentamiento"])
        except Exception as error:
            self.motor = None
            self.error_inicio = f"{type(error).__name__}: {error}"
            log.error("No se pudo iniciar CUDA: %s", self.error_inicio)

    def cerrar(self):
        if self.motor is not None:
            self.ejecutor.submit(self.motor.cerrar).result()
        self.ejecutor.shutdown()

    def disponible(self):
        return self.motor is not None

    def estado(self):
        return {
            "gpu_disponible": self.disponible(),
            "error": self.error_inicio,
            "gpu": self.info_gpu,
            "cola": {"pendientes": self.pendientes, "maximo": config.MAX_COLA,
                     "atendidas": self.atendidas, "rechazadas": self.rechazadas},
            "limites": {"max_mb": config.MAX_MB, "min_lado": config.MIN_LADO,
                        "max_lado": config.MAX_LADO, "max_pixeles": config.MAX_PIXELES},
        }

    @contextmanager
    def _turno(self):
        if not self.disponible():
            raise ErrorServicio("gpu_no_disponible",
                                f"No hay GPU CUDA disponible: {self.error_inicio}")
        with self.candado:
            if self.pendientes >= config.MAX_COLA:
                self.rechazadas += 1
                raise ErrorServicio("cola_llena",
                                    f"Hay {self.pendientes} solicitudes en curso; el máximo "
                                    f"es {config.MAX_COLA}. Intente de nuevo en unos segundos")
            self.pendientes += 1
        try:
            yield
        finally:
            with self.candado:
                self.pendientes -= 1

    # Aplica un filtro a la foto y guarda el resultado como <id>.jpg. Los parámetros se
    # validan antes de ocupar un lugar en la cola.
    async def procesar(self, id_solicitud, datos, filtro, recibidos):
        inicio = time.perf_counter()
        parametros = validar_parametros(filtro, recibidos)
        if len(datos) > config.MAX_MB * 2**20:
            raise ErrorServicio("archivo_muy_grande",
                                f"El archivo pesa {len(datos) / 2**20:.1f} MB; el máximo es "
                                f"{config.MAX_MB} MB")

        bucle = asyncio.get_running_loop()
        with self._turno():
            t = time.perf_counter()
            foto = await bucle.run_in_executor(None, abrir, datos)
            ms_decodificacion = (time.perf_counter() - t) * 1000

            encolada = time.perf_counter()
            salida, medidas, ms_cola, ms_gpu = await bucle.run_in_executor(
                self.ejecutor, self._aplicar, encolada, filtro, foto, parametros)

            t = time.perf_counter()
            await bucle.run_in_executor(None, util_imagen.guardar_jpeg, salida,
                                        config.DIR_RESULTADOS / f"{id_solicitud}.jpg")
            ms_codificacion = (time.perf_counter() - t) * 1000

        alto, ancho = foto.shape[:2]
        tiempos = {"decodificacion": ms_decodificacion, "cola": ms_cola, "gpu": ms_gpu,
                   "codificacion": ms_codificacion,
                   "total": (time.perf_counter() - inicio) * 1000}
        log.info("%s %s %s %dx%d kernel=%.3f ms total=%.1f ms", id_solicitud, filtro,
                 parametros, ancho, alto, medidas.ms_kernel, tiempos["total"])
        return Procesado(id=id_solicitud, filtro=filtro, parametros=parametros,
                         ancho=ancho, alto=alto, medidas=medidas, tiempos_ms=tiempos)

    # Corre en el hilo de la GPU. Antes de reservar comprueba que la foto quepa en la
    # memoria libre, para responder 507 en lugar de fallar a mitad del filtro.
    def _aplicar(self, encolada, filtro, foto, parametros):
        ms_cola = (time.perf_counter() - encolada) * 1000
        alto, ancho = foto.shape[:2]
        necesaria = alto * ancho * BYTES_GPU_POR_PIXEL
        libre = self.motor.memoria_libre()
        if necesaria > libre * 0.9:
            raise ErrorServicio("memoria_gpu_insuficiente",
                                f"Se necesitan {necesaria / 2**20:.0f} MB en la GPU y hay "
                                f"{libre / 2**20:.0f} MB libres")
        medidas = Medidas()
        inicio = time.perf_counter()
        try:
            salida = filtros.aplicar(self.pasos, filtro, foto, parametros, medidas)
        except cuda.MemoryError as error:
            raise ErrorServicio("memoria_gpu_insuficiente", str(error)) from None
        except cuda.Error as error:
            raise ErrorServicio("error_cuda", f"{type(error).__name__}: {error}") from None
        self.atendidas += 1
        return salida, medidas, ms_cola, (time.perf_counter() - inicio) * 1000

    # ---- Resultados ----

    def ruta_resultado(self, id_solicitud):
        ruta = config.DIR_RESULTADOS / f"{id_solicitud}.jpg"
        if not ID_VALIDO.match(id_solicitud) or not ruta.is_file():
            raise ErrorServicio("resultado_no_encontrado",
                                f"No existe el resultado {id_solicitud} o ya se borró "
                                f"(se guardan {config.TTL_MIN} min)")
        return ruta

    def borrar_antiguos(self):
        limite = time.time() - config.TTL_MIN * 60
        borrados = 0
        for ruta in config.DIR_RESULTADOS.glob("*.jpg"):
            try:
                if ruta.stat().st_mtime < limite:
                    ruta.unlink()
                    borrados += 1
            except FileNotFoundError:
                pass
        if borrados:
            log.info("limpieza: %d resultados con más de %d min", borrados, config.TTL_MIN)
