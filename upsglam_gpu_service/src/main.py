"""API REST del servicio de filtros. Es la única capa que conoce HTTP.

    python src/main.py

Documentación interactiva en http://localhost:8000/docs
"""

import asyncio
import logging
import uuid
from contextlib import asynccontextmanager
from typing import Literal

import uvicorn
from fastapi import FastAPI, File, Form, Request, UploadFile
from fastapi.exceptions import RequestValidationError
from fastapi.responses import FileResponse, JSONResponse
from starlette.concurrency import run_in_threadpool

import config
import filtros
from errores import ErrorServicio
from modelos import RespuestaError, RespuestaFiltro
from servicios.procesamiento import ServicioFiltros

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")
log = logging.getLogger("api")

# Estado HTTP de cada código de ErrorServicio. Un código que no esté aquí responde 500.
ESTADOS_HTTP = {
    "formato_no_admitido": 415,
    "imagen_danada": 415,
    "archivo_muy_grande": 413,
    "lado_excedido": 413,
    "pixeles_excedidos": 413,
    "imagen_muy_pequena": 422,
    "filtro_desconocido": 422,
    "parametro_invalido": 422,
    "resultado_no_encontrado": 404,
    "cola_llena": 429,
    "gpu_no_disponible": 503,
    "memoria_gpu_insuficiente": 507,
    "error_cuda": 500,
}


async def limpiar_periodicamente(servicio):
    while True:
        await asyncio.sleep(60)
        await run_in_threadpool(servicio.borrar_antiguos)


# La GPU se prepara al arrancar, antes de aceptar solicitudes, para que el contexto, la
# compilación y el calentamiento no se sumen a la primera solicitud.
@asynccontextmanager
async def ciclo_de_vida(app):
    app.state.servicio = await run_in_threadpool(ServicioFiltros)
    limpieza = asyncio.create_task(limpiar_periodicamente(app.state.servicio))
    yield
    limpieza.cancel()
    await run_in_threadpool(app.state.servicio.cerrar)


app = FastAPI(title="UPSGlam - Servicio de filtros GPU", version="0.1.0",
              lifespan=ciclo_de_vida,
              description="Aplica los filtros de UPSGlam en la GPU con PyCUDA. "
                          "Lo consume el backend Java.")


# Cada solicitud recibe un id que va en la cabecera X-Request-Id, en los registros y en el
# nombre del resultado. El peso se revisa con Content-Length antes de leer el cuerpo.
@app.middleware("http")
async def identificar(request: Request, siguiente):
    request.state.id = uuid.uuid4().hex
    largo = request.headers.get("content-length")
    if (request.method == "POST" and largo and largo.isdigit()
            and int(largo) > config.MAX_MB * 2**20 + 2**16):
        respuesta = responder_error(request, ErrorServicio(
            "archivo_muy_grande",
            f"El archivo pesa {int(largo) / 2**20:.1f} MB; el máximo es {config.MAX_MB} MB"))
    else:
        respuesta = await siguiente(request)
    respuesta.headers["X-Request-Id"] = request.state.id
    return respuesta


def responder_error(request, error):
    estado = ESTADOS_HTTP.get(error.codigo, 500)
    log.warning("%s %d %s: %s", request.state.id, estado, error.codigo, error.detalle)
    cuerpo = RespuestaError(id=request.state.id, error=error.codigo, detalle=error.detalle)
    return JSONResponse(status_code=estado, content=cuerpo.model_dump())


@app.exception_handler(ErrorServicio)
async def manejar_error(request: Request, error: ErrorServicio):
    return responder_error(request, error)


# Campos que faltan o con tipo equivocado (por ejemplo intensidad=abc) llegan aquí.
@app.exception_handler(RequestValidationError)
async def manejar_validacion(request: Request, error: RequestValidationError):
    detalle = "; ".join(f"{'.'.join(map(str, e['loc'][1:]))}: {e['msg']}" for e in error.errors())
    return responder_error(request, ErrorServicio("parametro_invalido", detalle))


@app.exception_handler(Exception)
async def manejar_inesperado(request: Request, error: Exception):
    log.exception("%s error no controlado", request.state.id)
    cuerpo = RespuestaError(id=request.state.id, error="error_interno", detalle=str(error))
    return JSONResponse(status_code=500, content=cuerpo.model_dump(),
                        headers={"X-Request-Id": request.state.id})


ERRORES_DOC = {estado: {"model": RespuestaError, "description": descripcion} for estado, descripcion in (
    (413, "Archivo, lado o píxeles por encima del límite"),
    (415, "No es una imagen JPG, PNG o WEBP, o está dañada"),
    (422, "Filtro o parámetros no válidos, o imagen demasiado pequeña"),
    (429, "Cola de la GPU llena"),
    (503, "GPU no disponible"),
    (507, "Memoria de GPU insuficiente"),
)}


@app.post("/api/procesar", response_model=RespuestaFiltro, responses=ERRORES_DOC,
          summary="Aplica un filtro en la GPU y devuelve las métricas y el id del resultado")
async def procesar(
    request: Request,
    imagen: UploadFile = File(..., description="Foto JPG, PNG o WEBP"),
    filtro: Literal[tuple(filtros.FILTROS)] = Form(...),
    nivel: Literal[filtros.PARAMETROS["media"]["nivel"].valores] | None = Form(
        None, description="Solo media. Por defecto medio. Los demás filtros lo ignoran"),
    intensidad: float | None = Form(
        None, description="Nitidez y relieve: 0 a 2 (1). Laplaciano: 3 a 10 (6)"),
    direccion: Literal[filtros.PARAMETROS["sobel"]["direccion"].valores] | None = Form(
        None, description="Solo sobel. Por defecto ambas"),
):
    datos = await imagen.read()
    procesado = await request.app.state.servicio.procesar(
        request.state.id, datos, filtro,
        {"nivel": nivel, "intensidad": intensidad, "direccion": direccion})
    return RespuestaFiltro.desde(procesado, f"/api/resultados/{procesado.id}")


@app.get("/api/resultados/{id_resultado}", response_class=FileResponse,
         responses={404: {"model": RespuestaError, "description": "No existe o ya se borró"}},
         summary="Descarga la imagen procesada (JPEG)")
async def resultado(request: Request, id_resultado: str):
    ruta = request.app.state.servicio.ruta_resultado(id_resultado)
    return FileResponse(ruta, media_type="image/jpeg", filename=f"upsglam_{id_resultado}.jpg")


@app.get("/api/filtros", summary="Filtros disponibles y sus parámetros")
async def catalogo():
    return {nombre: {parametro: vars(regla) for parametro, regla in parametros.items()}
            for nombre, parametros in filtros.PARAMETROS.items()}


@app.get("/api/salud", summary="Estado de la GPU, la cola y los límites",
         responses={503: {"description": "Sin GPU: el servicio no puede procesar"}})
async def salud(request: Request):
    estado = request.app.state.servicio.estado()
    return JSONResponse(status_code=200 if estado["gpu_disponible"] else 503, content=estado)


if __name__ == "__main__":
    uvicorn.run(app, host=config.HOST, port=config.PUERTO)
