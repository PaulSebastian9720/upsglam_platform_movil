# Servicio de filtros en GPU

Python 3.12 con `uv`, PyCUDA y CUDA 12.9.

## Por qué CUDA 12 dentro del proyecto
La GPU de desarrollo es una GeForce MX230 (Pascal, capacidad 6.1). CUDA 13 ya no
genera código para Pascal y el controlador 575 admite hasta CUDA 12.9. Por eso el
CUDA 12.9 viene como paquetes de Python dentro del entorno, sin tocar el del sistema:

- `nvidia-cuda-runtime-cu12`: cabeceras (`cuda.h`) para compilar PyCUDA.
- `nvidia-cuda-nvrtc-cu12`: NVRTC, que compila los kernels a PTX mientras corre.
  El paquete no trae `nvcc`, así que no se usa `SourceModule`: se compila con
  NVRTC y se carga con `pycuda.driver.module_from_buffer`.

## Preparar el entorno
PyCUDA se compila al instalarse y debe usar las cabeceras de CUDA 12.9, no las
del sistema:

```bash
uv sync --no-install-package pycuda
export CUDA_ROOT="$(uv run python -c 'import site;print(site.getsitepackages()[0])')/nvidia/cuda_runtime"
CUDA_INC_DIR="$CUDA_ROOT/include" uv sync --reinstall-package pycuda
```

## Comprobar la GPU
```bash
uv run python consulta_gpu.py
```
Muestra las características de la GPU y prueba un kernel.

## Validar los kernels
```bash
.venv/bin/python pruebas/validacion.py
```
Compara cada kernel y los seis filtros con NumPy. Las reglas del servicio están en
[docs/backend/servicio-gpu.md](../docs/backend/servicio-gpu.md).
