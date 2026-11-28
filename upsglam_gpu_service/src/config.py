"""Ajustes del servicio. Cada uno se puede cambiar con una variable de entorno."""

import os
import tempfile
from pathlib import Path


def _entero(nombre, defecto):
    return int(os.environ.get(nombre, str(defecto)))


# Límites de la foto. El servicio no redimensiona: la app reduce el lado mayor a 2560 px y
# aquí se acepta hasta MAX_LADO. Por debajo de MIN_LADO la máscara de 21x21 cubriría casi
# toda la imagen; 50 megapíxeles cubren el modo de 50 MP de los teléfonos y caben en los
# 4 GB de la MX230.
MAX_MB = _entero("MAX_MB", 25)
MIN_LADO = _entero("MIN_LADO", 64)
MAX_LADO = _entero("MAX_LADO", 12000)
MAX_PIXELES = _entero("MAX_PIXELES", 50_000_000)

# Solicitudes esperando la GPU; con la cola llena se responde 429.
MAX_COLA = _entero("MAX_COLA", 4)

# Minutos que se guarda un resultado antes de borrarlo.
TTL_MIN = _entero("TTL_MIN", 10)
DIR_RESULTADOS = Path(os.environ.get(
    "DIR_RESULTADOS", Path(tempfile.gettempdir()) / "upsglam_resultados"))

# Bloques 2D de BLOQUE x BLOQUE hilos, un hilo por píxel.
BLOQUE = _entero("BLOQUE", 16)

# Dirección y puerto de la API.
HOST = os.environ.get("HOST", "0.0.0.0")
PUERTO = _entero("PUERTO", 8000)
