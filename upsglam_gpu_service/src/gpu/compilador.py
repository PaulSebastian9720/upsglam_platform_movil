"""Compila los kernels de gpu/kernels.py a PTX con NVRTC 12.9.

No se usa SourceModule porque llama a nvcc, y el de la PC de desarrollo es CUDA 13, que ya
no genera código para Pascal (MX230, capacidad 6.1). NVRTC viene como paquete de Python
(nvidia-cuda-nvrtc-cu12) y compila igual dentro y fuera de Docker, para la MX230 (6.1) y
para la RTX 5050 (12.0). El PTX resultante lo carga PyCUDA con module_from_buffer.
"""

import ctypes
import glob
import os
import site

from gpu import kernels


def _nvrtc():
    for base in site.getsitepackages():
        rutas = glob.glob(os.path.join(base, "nvidia/cuda_nvrtc/lib/libnvrtc.so*"))
        if rutas:
            return ctypes.CDLL(sorted(rutas)[0])
    raise RuntimeError("No se encontró libnvrtc: falta el paquete nvidia-cuda-nvrtc-cu12")


def _registro(nvrtc, programa):
    tam = ctypes.c_size_t()
    nvrtc.nvrtcGetProgramLogSize(programa, ctypes.byref(tam))
    texto = ctypes.create_string_buffer(tam.value)
    nvrtc.nvrtcGetProgramLog(programa, texto)
    return texto.value.decode(errors="replace")


def compilar_ptx(capacidad):
    """Compila los kernels para una capacidad de cómputo como (6, 1); devuelve el PTX."""
    nvrtc = _nvrtc()
    programa = ctypes.c_void_p()
    estado = nvrtc.nvrtcCreateProgram(ctypes.byref(programa), kernels.FUENTE.encode(),
                                      kernels.NOMBRE.encode(), 0, None, None)
    if estado:
        raise RuntimeError(f"nvrtcCreateProgram falló con código {estado}")
    try:
        opciones = [f"--gpu-architecture=compute_{capacidad[0]}{capacidad[1]}".encode()]
        estado = nvrtc.nvrtcCompileProgram(
            programa, len(opciones), (ctypes.c_char_p * len(opciones))(*opciones))
        if estado:
            raise RuntimeError("Error al compilar los kernels:\n" + _registro(nvrtc, programa))
        tam = ctypes.c_size_t()
        nvrtc.nvrtcGetPTXSize(programa, ctypes.byref(tam))
        ptx = ctypes.create_string_buffer(tam.value)
        nvrtc.nvrtcGetPTX(programa, ptx)
        return ptx.raw
    finally:
        nvrtc.nvrtcDestroyProgram(ctypes.byref(programa))
