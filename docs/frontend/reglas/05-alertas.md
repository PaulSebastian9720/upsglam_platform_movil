# Alertas

Un componente: **AppAlerta**. Nadie más abre diálogos.

- Un solo mensaje, sin subtítulo. Icono **en rojo** (`rojoTexto`), fondo `superficie`, radio 20, velo detrás.
- Dos botones: acción y Cancelar. La acción es amarilla, salvo la destructiva, que es **roja**.
- Se elige por tipo, no por texto. Los textos viven solo en el componente.

| Tipo | Mensaje | Icono | Acción |
|---|---|---|---|
| archivoNoValido | Ese archivo no es una foto JPG, PNG o WEBP | alerta_archivo | Elegir otra |
| fotoMuyGrande | La foto es muy grande | alerta_tamano | Elegir otra |
| servidorOcupado | Hay mucha gente aplicando filtros | alerta_espera | Reintentar |
| filtrosNoDisponibles | Los filtros no están disponibles | alerta | Reintentar |
| sinConexion (previsto) | No hay conexión | alerta | Reintentar |
| eliminarPublicacion | ¿Eliminar esta publicación? | eliminar | Eliminar |

## De error a alerta
La conversión se hace **en un solo lugar**, `servicios/api`, con códigos del backend, nunca leyendo textos. Códigos HTTP **propuestos, por acordar con el backend**:

| Respuesta | Tipo |
|---|---|
| 415 | archivoNoValido |
| 413 | fotoMuyGrande |
| 429 | servidorOcupado |
| 503 | filtrosNoDisponibles |
| Sin red o tiempo agotado | sinConexion |
| 401 | Ninguna: se maneja en [sesión](07-sesion-y-token.md) |
| 400 o 422 de un campo | Error bajo el campo |

## Cuándo no usar alerta
- Dato mal escrito: error bajo el campo.
- Filtro que falló en el historial: se muestra en la rueda.
- Confirmación de algo que salió bien: aviso breve, sin botones.

## Para revisar
- [ ] Nunca hay dos alertas a la vez.
- [ ] Tras esperar una respuesta, se comprueba que la pantalla siga abierta.
- [ ] Reintentar no duplica la solicitud.
- [ ] La alerta de filtros no pierde la foto ni los ajustes.
