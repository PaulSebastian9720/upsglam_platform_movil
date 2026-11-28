# UPSGlam GPU Service

Servicio REST que aplica los filtros de imagen de UPSGlam en la GPU con PyCUDA. Recibe
una foto, el filtro y sus parámetros, y devuelve las métricas de ejecución junto con
la imagen procesada. Lo consume el backend de UPSGlam.

Filtros: media, nitidez, Laplaciano, Sobel, relieve y UPS.

![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![CUDA](https://img.shields.io/badge/CUDA-12.9-76B900?logo=nvidia&logoColor=white)
![PyCUDA](https://img.shields.io/badge/PyCUDA-2026.1-76B900?logo=nvidia&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-0.165-009688?logo=fastapi&logoColor=white)
![NumPy](https://img.shields.io/badge/NumPy-2.5-013243?logo=numpy&logoColor=white)
![Pillow](https://img.shields.io/badge/Pillow-13.0-3776AB?logo=python&logoColor=white)
![uv](https://img.shields.io/badge/uv-gestor-DE5FE9?logo=uv&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-NVIDIA_Container_Toolkit-2496ED?logo=docker&logoColor=white)

## Requisitos

- GPU NVIDIA con controlador compatible con CUDA 12.9.
- Python 3.12 y [uv](https://docs.astral.sh/uv/).
- Para Docker: NVIDIA Container Toolkit (en Windows, Docker Desktop con WSL 2).

## Instalación

```bash
uv sync --no-install-package pycuda
```
```bash
export CUDA_ROOT="$(uv run python -c 'import site;print(site.getsitepackages()[0])')/nvidia/cuda_runtime"
```
```bash
CUDA_INC_DIR="$CUDA_ROOT/include" uv sync --reinstall-package pycuda
```

Para comprobar que la GPU responde:

```bash
uv run python consulta_gpu.py
```

## Levantar el servicio

```bash
.venv/bin/python src/main.py
```

La API queda en http://localhost:8000 y su documentación interactiva en
http://localhost:8000/docs.

## Levantar con Docker

```bash
docker build -t upsglam-gpu:0.1 .
```
```bash
docker run --rm --gpus all -p 8000:8000 upsglam-gpu:0.1
```

El `Dockerfile` tiene activa la imagen base de Ubuntu 24.04 y, comentada, la de
Ubuntu 22.04. Para cambiar de base se intercambian las dos líneas `FROM`.

## Pruebas

Validación de los kernels y de los seis filtros contra una referencia en NumPy:

```bash
.venv/bin/python pruebas/validacion.py
```

Prueba de la API completa (filtros, tipos de imagen y errores), con el servicio en
ejecución:

```bash
.venv/bin/python pruebas/prueba_api.py
```

Para probar otra dirección, como el contenedor en otro puerto, se pasa como argumento:

```bash
.venv/bin/python pruebas/prueba_api.py http://localhost:8001
```

## Documentación

Contrato REST, filtros, parámetros, límites y errores en
[docs/backend/servicio-gpu.md](../docs/backend/servicio-gpu.md).
