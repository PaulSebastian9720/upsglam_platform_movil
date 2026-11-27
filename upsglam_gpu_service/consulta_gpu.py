"""Consulta las características de la GPU con PyCUDA y prueba un kernel.

Los kernels se compilan con NVRTC 12.9 (paquete nvidia-cuda-nvrtc-cu12),
porque el CUDA 13 del sistema ya no genera código para Pascal (sm_61).
"""

import ctypes
import glob
import os
import site

import numpy as np
import pycuda.autoinit  # noqa: F401  crea el contexto en la GPU 0
import pycuda.driver as cuda


def _nvrtc() -> ctypes.CDLL:
    base = site.getsitepackages()[0]
    ruta = glob.glob(os.path.join(base, "nvidia/cuda_nvrtc/lib/libnvrtc.so*"))
    if not ruta:
        raise RuntimeError("No se encontró libnvrtc: instala nvidia-cuda-nvrtc-cu12")
    return ctypes.CDLL(sorted(ruta)[0])


def compilar_ptx(fuente: str, nombre: str, arquitectura: str) -> bytes:
    """Compila CUDA C a PTX para la arquitectura dada (por ejemplo 61)."""
    nvrtc = _nvrtc()
    programa = ctypes.c_void_p()
    estado = nvrtc.nvrtcCreateProgram(
        ctypes.byref(programa), fuente.encode(), nombre.encode(), 0, None, None
    )
    if estado:
        raise RuntimeError(f"nvrtcCreateProgram falló: {estado}")
    opciones = (ctypes.c_char_p * 1)(f"--gpu-architecture=compute_{arquitectura}".encode())
    estado = nvrtc.nvrtcCompileProgram(programa, 1, opciones)
    if estado:
        tam = ctypes.c_size_t()
        nvrtc.nvrtcGetProgramLogSize(programa, ctypes.byref(tam))
        registro = ctypes.create_string_buffer(tam.value)
        nvrtc.nvrtcGetProgramLog(programa, registro)
        raise RuntimeError(registro.value.decode())
    tam = ctypes.c_size_t()
    nvrtc.nvrtcGetPTXSize(programa, ctypes.byref(tam))
    ptx = ctypes.create_string_buffer(tam.value)
    nvrtc.nvrtcGetPTX(programa, ptx)
    nvrtc.nvrtcDestroyProgram(ctypes.byref(programa))
    return ptx.raw


def caracteristicas() -> None:
    a = cuda.device_attribute
    print(f"CUDA del controlador: {cuda.get_driver_version()}")
    print(f"GPUs encontradas: {cuda.Device.count()}")
    for i in range(cuda.Device.count()):
        d = cuda.Device(i)
        attr = d.get_attributes()
        mayor, menor = d.compute_capability()
        print(f"\nGPU {i}: {d.name()}")
        print(f"  Capacidad de cómputo: {mayor}.{menor}")
        print(f"  Memoria global: {d.total_memory() / 1024**2:.0f} MiB")
        print(f"  Multiprocesadores (SM): {attr[a.MULTIPROCESSOR_COUNT]}")
        print(f"  Frecuencia del núcleo: {attr[a.CLOCK_RATE] / 1000:.0f} MHz")
        print(f"  Hilos máximos por bloque: {attr[a.MAX_THREADS_PER_BLOCK]}")
        print(f"  Hilos máximos por SM: {attr[a.MAX_THREADS_PER_MULTIPROCESSOR]}")
        print(
            "  Dimensiones máximas de bloque: "
            f"{attr[a.MAX_BLOCK_DIM_X]} x {attr[a.MAX_BLOCK_DIM_Y]} x {attr[a.MAX_BLOCK_DIM_Z]}"
        )
        print(
            "  Dimensiones máximas de grilla: "
            f"{attr[a.MAX_GRID_DIM_X]} x {attr[a.MAX_GRID_DIM_Y]} x {attr[a.MAX_GRID_DIM_Z]}"
        )
        print(f"  Memoria compartida por bloque: {attr[a.MAX_SHARED_MEMORY_PER_BLOCK] / 1024:.0f} KiB")
        print(f"  Registros por bloque: {attr[a.MAX_REGISTERS_PER_BLOCK]}")
        print(f"  Tamaño de warp: {attr[a.WARP_SIZE]}")
        print(f"  Ancho del bus de memoria: {attr[a.GLOBAL_MEMORY_BUS_WIDTH]} bits")
        libre, total = cuda.mem_get_info()
        print(f"  Memoria libre ahora: {libre / 1024**2:.0f} de {total / 1024**2:.0f} MiB")


def prueba_kernel() -> None:
    fuente = 'extern "C" __global__ void duplicar(float *a, int n) {\n' \
             "  int i = blockIdx.x * blockDim.x + threadIdx.x;\n" \
             "  if (i < n) a[i] *= 2.0f;\n}\n"
    mayor, menor = cuda.Context.get_device().compute_capability()
    modulo = cuda.module_from_buffer(compilar_ptx(fuente, "duplicar.cu", f"{mayor}{menor}"))
    duplicar = modulo.get_function("duplicar")
    datos = np.arange(1_000_000, dtype=np.float32)
    esperado = datos * 2
    duplicar(cuda.InOut(datos), np.int32(datos.size), block=(256, 1, 1), grid=((datos.size + 255) // 256, 1))
    ok = np.array_equal(datos, esperado)
    print(f"\nPrueba de kernel en la GPU (duplicar 1 000 000 números): {'correcta' if ok else 'FALLÓ'}")


if __name__ == "__main__":
    caracteristicas()
    prueba_kernel()
