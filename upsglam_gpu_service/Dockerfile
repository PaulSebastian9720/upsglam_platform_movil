# Servicio de filtros GPU de UPSGlam.
#   docker build -t upsglam-gpu:0.1 .
#   docker run --rm --gpus all -p 8000:8000 upsglam-gpu:0.1
#
# El controlador NVIDIA es del anfitrión y lo monta NVIDIA Container Toolkit con --gpus; la
# imagen no trae controlador.
#
# Los kernels se compilan con NVRTC, que viene como paquete de Python
# (nvidia-cuda-nvrtc-cu12), no con nvcc. Por eso la imagen final parte de la base "base" de
# CUDA y no de "devel": solo necesita libcuda, que llega del anfitrión.

# Etapa 1: entorno virtual con las dependencias de pyproject.toml. PyCUDA se compila aquí
# contra las cabeceras de CUDA ("devel") y de Python; nada de eso pasa a la imagen final.
# MX230 (Pascal, 6.1), equipo de desarrollo: CUDA 13 ya no admite Pascal.
FROM nvidia/cuda:12.9.1-devel-ubuntu24.04 AS construccion
# RTX 5050 (Blackwell, 12.0), equipo de la demostración: base de la práctica 03.
# FROM nvidia/cuda:12.9.1-devel-ubuntu22.04 AS construccion
ENV DEBIAN_FRONTEND=noninteractive
# Ubuntu 24.04 trae Python 3.12; Ubuntu 22.04 trae 3.10 y se usa el PPA deadsnakes.
RUN apt-get update && \
    if ! apt-cache show python3.12 > /dev/null 2>&1; then \
        apt-get install -y --no-install-recommends software-properties-common gpg-agent && \
        add-apt-repository -y ppa:deadsnakes/ppa && apt-get update; \
    fi && \
    apt-get install -y --no-install-recommends python3.12 python3.12-dev python3.12-venv && \
    rm -rf /var/lib/apt/lists/*

# pyproject.toml es la única lista de dependencias: se extrae con tomllib a un
# requirements.txt y se instala con pip, sin uv.
WORKDIR /app
COPY pyproject.toml ./
RUN python3.12 -m venv /opt/venv && \
    python3.12 -c "import tomllib; print('\n'.join(tomllib.load(open('pyproject.toml', 'rb'))['project']['dependencies']))" > requirements.txt && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Etapa 2: solo el intérprete 3.12 (sin -dev) y el entorno virtual.
FROM nvidia/cuda:12.9.1-base-ubuntu24.04
# FROM nvidia/cuda:12.9.1-base-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    if ! apt-cache show python3.12 > /dev/null 2>&1; then \
        apt-get install -y --no-install-recommends software-properties-common gpg-agent && \
        add-apt-repository -y ppa:deadsnakes/ppa && apt-get update && \
        apt-get purge -y --auto-remove software-properties-common gpg-agent; \
    fi && \
    apt-get install -y --no-install-recommends python3.12 && \
    apt-get upgrade -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home app

COPY --from=construccion /opt/venv /opt/venv
# PyCUDA queda enlazado a cuRAND, que la imagen "base" no trae.
COPY --from=construccion /usr/local/cuda-12.9/targets/x86_64-linux/lib/libcurand.so.10 /usr/local/cuda/lib64/
WORKDIR /app
COPY --chown=app:app src ./src

ENV PATH=/opt/venv/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    DIR_RESULTADOS=/tmp/resultados \
    PUERTO=8000
USER app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/api/salud', timeout=4)"
CMD ["python", "src/main.py"]
