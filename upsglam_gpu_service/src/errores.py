"""Errores del servicio, sin nada de HTTP.

Los servicios lanzan ErrorServicio con un código de texto; main.py es el único que
traduce ese código a un estado HTTP (tabla ESTADOS_HTTP).
"""


class ErrorServicio(Exception):

    def __init__(self, codigo, detalle):
        super().__init__(detalle)
        self.codigo = codigo
        self.detalle = detalle
