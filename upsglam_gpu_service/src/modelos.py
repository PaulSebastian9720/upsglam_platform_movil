"""Datos del servicio, todos en un archivo."""

from dataclasses import dataclass, field

from pydantic import BaseModel, Field


# Una ejecución de kernel: lo que pide la rúbrica por cada lanzamiento.
@dataclass
class Lanzamiento:
    kernel: str
    bloque: tuple
    grid: tuple
    hilos: int
    ms: float


# Medidas de una solicitud en la GPU. Un filtro puede lanzar varios kernels (Laplaciano:
# gaussiano y Laplaciano; UPS: Sobel y colores); el tiempo de kernel es la suma.
@dataclass
class Medidas:
    lanzamientos: list = field(default_factory=list)
    ms_cpu_gpu: float = 0.0
    ms_gpu_cpu: float = 0.0

    @property
    def ms_kernel(self):
        return sum(lanzamiento.ms for lanzamiento in self.lanzamientos)

    @property
    def hilos(self):
        return sum(lanzamiento.hilos for lanzamiento in self.lanzamientos)


# Lo que devuelve el servicio al terminar una solicitud; main.py lo pasa a RespuestaFiltro.
@dataclass
class Procesado:
    id: str
    filtro: str
    parametros: dict
    ancho: int
    alto: int
    medidas: Medidas
    tiempos_ms: dict


# ---- Respuestas de la API (también documentan el contrato en /docs) ----

class KernelLanzado(BaseModel):
    kernel: str
    bloque: list[int]
    grid: list[int]
    hilos: int
    ms: float


class MetricasGpu(BaseModel):
    bloque: list[int] = Field(description="Hilos por bloque en X, Y, Z")
    grid: list[int] = Field(description="Bloques en X, Y")
    hilos_lanzados: int = Field(description="Suma de los hilos de todos los kernels")
    ms_kernel: float = Field(description="Suma del tiempo de todos los kernels")
    ms_cpu_gpu: float
    ms_gpu_cpu: float
    kernels: list[KernelLanzado]


class TiemposMs(BaseModel):
    decodificacion: float
    cola: float
    gpu: float
    codificacion: float
    total: float


class RespuestaFiltro(BaseModel):
    id: str
    estado: str = "ok"
    filtro: str
    parametros: dict
    ancho: int
    alto: int
    metricas: MetricasGpu
    tiempos_ms: TiemposMs
    url_resultado: str

    @classmethod
    def desde(cls, procesado, url_resultado):
        medidas = procesado.medidas
        kernels = [KernelLanzado(kernel=l.kernel, bloque=list(l.bloque), grid=list(l.grid),
                                 hilos=l.hilos, ms=l.ms) for l in medidas.lanzamientos]
        return cls(
            id=procesado.id, filtro=procesado.filtro, parametros=procesado.parametros,
            ancho=procesado.ancho, alto=procesado.alto, tiempos_ms=TiemposMs(**procesado.tiempos_ms),
            metricas=MetricasGpu(bloque=kernels[0].bloque, grid=kernels[0].grid,
                                 hilos_lanzados=medidas.hilos, ms_kernel=medidas.ms_kernel,
                                 ms_cpu_gpu=medidas.ms_cpu_gpu, ms_gpu_cpu=medidas.ms_gpu_cpu,
                                 kernels=kernels),
            url_resultado=url_resultado)


# Si la solicitud falla, las métricas no están disponibles (null), como pide la rúbrica.
class RespuestaError(BaseModel):
    id: str
    estado: str = "error"
    error: str
    detalle: str
    metricas: None = None
