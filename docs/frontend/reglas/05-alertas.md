# Alertas

Todas las alertas se muestran con el componente `AppAlerta`. Ninguna otra parte de la aplicación abre diálogos.

- Cada alerta tiene un solo mensaje, sin subtítulo, con el icono en rojo (`rojoTexto`), fondo `superficie`, radio 20 y velo detrás.
- Tiene dos botones: la acción y Cancelar. La acción es amarilla, salvo cuando es destructiva, que es roja.
- La alerta se elige por tipo, no por texto. Los textos se definen solo dentro del componente.

| Tipo | Mensaje | Icono | Acción |
|---|---|---|---|
| archivoNoValido | Ese archivo no es una foto JPG, PNG o WEBP | alerta_archivo | Elegir otra |
| fotoMuyGrande | La foto es muy grande | alerta_tamano | Elegir otra |
| servidorOcupado | Hay mucha gente aplicando filtros | alerta_espera | Reintentar |
| filtrosNoDisponibles | Los filtros no están disponibles | alerta | Reintentar |
| sinConexion (no implementado) | No hay conexión | alerta | Reintentar |
| eliminarPublicacion | ¿Eliminar esta publicación? | eliminar | Eliminar |

## De error a alerta
La conversión de errores en alertas se hace en un único lugar, `servicios/api`, a partir de los códigos de respuesta del backend y nunca de sus textos. El servicio de API no está implementado.

Códigos HTTP (pendiente de definición con el backend):

| Respuesta | Tipo |
|---|---|
| 415 | archivoNoValido |
| 413 | fotoMuyGrande |
| 429 | servidorOcupado |
| 503 | filtrosNoDisponibles |
| Sin red o tiempo agotado | sinConexion |
| 401 | Ninguna; se gestiona en la [sesión](07-sesion-y-token.md) |
| 400 o 422 de un campo | Error bajo el campo |

## Cuándo no usar alerta
- Dato mal escrito: se muestra el error bajo el campo.
- Filtro que falló en el historial: se indica en la rueda del filtro.
- Confirmación de una acción exitosa: se muestra un aviso breve, sin botones.

## Comportamiento requerido
- No se muestran dos alertas al mismo tiempo.
- Después de esperar una respuesta, se comprueba que la pantalla siga abierta antes de mostrar la alerta.
- Reintentar no duplica la solicitud.
- La alerta de filtros conserva la foto y los ajustes elegidos.

