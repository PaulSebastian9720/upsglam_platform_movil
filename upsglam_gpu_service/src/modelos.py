"""Datos del servicio, todos en un archivo."""

from dataclasses import dataclass, field


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
