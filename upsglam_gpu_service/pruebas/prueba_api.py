"""Prueba la API con el servicio corriendo (python src/main.py).

    python pruebas/prueba_api.py [http://localhost:8000]

Recorre los seis filtros, varios tipos de imagen de entrada y cada error que el servicio
puede producir sin cambiar su configuración. Termina con código 1 si alguna falla.
"""

import io
import json
import sys
import uuid
from concurrent.futures import ThreadPoolExecutor
from urllib import error, request

import numpy as np
from PIL import Image

BASE = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000"
resultados = []


def enviar(datos, campos, nombre="foto.jpg"):
    limite = uuid.uuid4().hex
    partes = []
    for clave, valor in campos.items():
        partes.append(f'--{limite}\r\nContent-Disposition: form-data; name="{clave}"\r\n\r\n'
                      f"{valor}\r\n".encode())
    partes.append(f'--{limite}\r\nContent-Disposition: form-data; name="imagen"; '
                  f'filename="{nombre}"\r\nContent-Type: application/octet-stream\r\n\r\n'.encode()
                  + datos + b"\r\n")
    partes.append(f"--{limite}--\r\n".encode())
    peticion = request.Request(f"{BASE}/api/procesar", data=b"".join(partes), method="POST",
                               headers={"Content-Type": f"multipart/form-data; boundary={limite}"})
    return abrir(peticion)


def abrir(peticion):
    try:
        with request.urlopen(peticion, timeout=120) as respuesta:
            return respuesta.status, respuesta.headers, respuesta.read()
    except error.HTTPError as fallo:
        return fallo.code, fallo.headers, fallo.read()


def comprobar(nombre, condicion, detalle=""):
    resultados.append((nombre, bool(condicion), detalle))


def foto(ancho=320, alto=240, modo="RGB", formato="JPEG", **opciones):
    azar = np.random.default_rng(3)
    if modo == "I;16":
        imagen = Image.fromarray(azar.integers(0, 65536, (alto, ancho), dtype=np.uint16))
    else:
        imagen = Image.fromarray(azar.integers(0, 256, (alto, ancho, 3), dtype=np.uint8)).convert(modo)
    salida = io.BytesIO()
    imagen.save(salida, formato, **opciones)
    return salida.getvalue()


def esperar_error(nombre, estado_esperado, codigo_esperado, datos, campos):
    estado, cabeceras, cuerpo = enviar(datos, campos)
    contenido = json.loads(cuerpo)
    comprobar(nombre, estado == estado_esperado and contenido["error"] == codigo_esperado
              and contenido["estado"] == "error" and contenido["metricas"] is None
              and contenido["id"] == cabeceras["X-Request-Id"],
              f"{estado} {contenido.get('error')}: {contenido.get('detalle')}")


def filtros_y_resultado():
    datos = foto(640, 480)
    casos = [("media", {"nivel": "fuerte"}), ("nitidez", {}), ("laplaciano", {"intensidad": 6}),
             ("sobel", {"direccion": "vertical"}), ("relieve", {"intensidad": 1.5}), ("ups", {})]
    for filtro, parametros in casos:
        estado, cabeceras, cuerpo = enviar(datos, {"filtro": filtro, **parametros})
        if estado != 200:
            comprobar(f"filtro {filtro}", False, f"{estado} {cuerpo[:200]}")
            continue
        r = json.loads(cuerpo)
        m = r["metricas"]
        comprobar(f"filtro {filtro}: métricas",
                  r["ancho"] == 640 and r["alto"] == 480 and m["bloque"] == [16, 16, 1]
                  and m["grid"] == [40, 30] and m["hilos_lanzados"] >= 640 * 480
                  and m["ms_kernel"] > 0 and r["id"] == cabeceras["X-Request-Id"],
                  f"kernels {[k['kernel'] for k in m['kernels']]}, {m['ms_kernel']:.3f} ms")
        estado, cabeceras, imagen = abrir(request.Request(BASE + r["url_resultado"]))
        salida = Image.open(io.BytesIO(imagen))
        comprobar(f"filtro {filtro}: GET resultado",
                  estado == 200 and cabeceras["Content-Type"] == "image/jpeg"
                  and salida.size == (640, 480),
                  f"{salida.mode} {salida.size}")


def tipos_de_entrada():
    casos = {
        "PNG RGB": foto(formato="PNG"),
        "PNG 16 bits gris": foto(modo="I;16", formato="PNG"),
        "PNG con transparencia": foto(modo="RGBA", formato="PNG"),
        "PNG con paleta": foto(modo="P", formato="PNG"),
        "JPG en gris": foto(modo="L"),
        "JPG CMYK": foto(modo="CMYK"),
        "WEBP": foto(formato="WEBP"),
    }
    for nombre, datos in casos.items():
        estado, _, cuerpo = enviar(datos, {"filtro": "media", "nivel": "bajo"})
        comprobar(f"entrada {nombre}", estado == 200, f"{estado}")

    # Foto de celular girada: 320x240 guardada con orientación EXIF 6 (90°) se ve 240x320.
    imagen = Image.open(io.BytesIO(foto()))
    exif = imagen.getexif()
    exif[0x0112] = 6
    salida = io.BytesIO()
    imagen.save(salida, "JPEG", exif=exif)
    estado, _, cuerpo = enviar(salida.getvalue(), {"filtro": "ups"})
    r = json.loads(cuerpo)
    comprobar("entrada JPG con orientación EXIF", estado == 200 and (r["ancho"], r["alto"]) == (240, 320),
              f"{r.get('ancho')}x{r.get('alto')}")


def errores():
    jpg = foto()
    esperar_error("415 no es imagen", 415, "formato_no_admitido", b"hola", {"filtro": "media"})
    esperar_error("415 formato GIF", 415, "formato_no_admitido", foto(formato="GIF"), {"filtro": "media"})
    esperar_error("415 imagen cortada", 415, "imagen_danada", jpg[:len(jpg) // 3], {"filtro": "media"})
    esperar_error("422 imagen pequeña", 422, "imagen_muy_pequena", foto(40, 40), {"filtro": "media"})
    esperar_error("413 lado excedido", 413, "lado_excedido", foto(12001, 64, formato="PNG"),
                  {"filtro": "media"})
    esperar_error("422 filtro desconocido", 422, "parametro_invalido", jpg, {"filtro": "acuarela"})
    esperar_error("422 intensidad fuera de rango", 422, "parametro_invalido", jpg,
                  {"filtro": "nitidez", "intensidad": 9})
    esperar_error("422 intensidad no numérica", 422, "parametro_invalido", jpg,
                  {"filtro": "relieve", "intensidad": "mucha"})
    # Un parámetro que el filtro no usa se ignora, como hace /docs al enviar todos los campos.
    estado, _, cuerpo = enviar(jpg, {"filtro": "ups", "nivel": "bajo", "intensidad": 1,
                                     "direccion": "ambas"})
    comprobar("parámetros que no aplican se ignoran",
              estado == 200 and json.loads(cuerpo)["parametros"] == {}, f"{estado}")
    estado, _, cuerpo = abrir(request.Request(f"{BASE}/api/resultados/{'0' * 32}"))
    comprobar("404 resultado inexistente", estado == 404, json.loads(cuerpo)["error"])

    # Más solicitudes a la vez que lugares en la cola: alguna debe recibir 429.
    salud = json.loads(abrir(request.Request(f"{BASE}/api/salud"))[2])
    grande = foto(2000, 1500)
    total = salud["cola"]["maximo"] * 3
    with ThreadPoolExecutor(total) as hilos:
        estados = list(hilos.map(lambda _: enviar(grande, {"filtro": "media", "nivel": "fuerte"})[0],
                                 range(total)))
    comprobar("429 cola llena", 429 in estados and 200 in estados and set(estados) <= {200, 429},
              f"{estados.count(200)} atendidas, {estados.count(429)} rechazadas")


def main():
    estado, _, cuerpo = abrir(request.Request(f"{BASE}/api/salud"))
    comprobar("salud", estado == 200 and json.loads(cuerpo)["gpu_disponible"], f"{estado}")
    filtros_y_resultado()
    tipos_de_entrada()
    errores()

    fallos = [r for r in resultados if not r[1]]
    for nombre, bien, detalle in resultados:
        print(f"{'OK   ' if bien else 'FALLO'} {nombre}: {detalle}")
    print(f"\n{len(resultados) - len(fallos)}/{len(resultados)} correctas")
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
