# Datos, paginación y caché

**Estado:** la carga dinámica está implementada sobre datos de prueba en memoria. La paginación, la conexión con el backend y el caché en el teléfono no están implementados.

## Carga dinámica
- Primero se muestra lo guardado y después se actualiza con la red. El repositorio es el único que decide de dónde salen los datos ([patrón oficial](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)).
- Las listas se construyen a medida que se muestran, con constructores perezosos ([fuente](https://docs.flutter.dev/cookbook/lists/long-lists)).
- No se usa el gesto de deslizar hacia abajo para actualizar. Las pantallas se recargan al volver de otra que pudo cambiar sus datos, o cuando el repositorio notifica un cambio (publicar, editar o eliminar).
- Los cambios propios, como dar me gusta o comentar, se reflejan de inmediato y se revierten si el servidor responde con error.

## Paginación
La paginación es por cursor y no por número de página, para que una publicación nueva no provoque elementos repetidos ni omitidos mientras se recorre la lista. El orden es por fecha y luego por id, de forma descendente.

Petición: `GET /publicaciones?limite=10&cursor=<cursor>`. La primera petición se envía sin cursor.

Todas las listas usan la misma forma de respuesta:
```json
{
  "elementos": [],
  "siguienteCursor": "texto opaco o null",
  "hayMas": true
}
```
El cursor es opaco: la aplicación lo guarda y lo devuelve sin interpretarlo.

**Pendiente de definición:** las rutas y los campos deben acordarse con el backend.

| Lista | Ruta | Límite | Al final |
|---|---|---|---|
| Inicio | `/publicaciones` | 10 | Pide la siguiente página a 3 elementos del final |
| Publicaciones de un usuario | `/usuarios/{id}/publicaciones` | 18 | Cuadrícula de 3 |
| Comentarios | `/publicaciones/{id}/comentarios` | 20 | Más antiguos arriba |
| Historial | `/historial` | 15 | Solo el del usuario |
| Seguidores | `/usuarios/{id}/seguidores` | 20 | Solo los del usuario |

**Reglas de las listas**
- No se pide una página si ya hay otra en curso o si `hayMas` es falso.
- Los elementos repetidos se descartan por id.
- Si una página falla, se conserva lo cargado y se ofrece reintentar esa página.
- Actualizar reemplaza la primera página y descarta los cursores.
- Se usará la biblioteca `infinite_scroll_pagination` ([fuente](https://pub.dev/documentation/infinite_scroll_pagination/latest/)), que no impone una estrategia y admite cursores. Las páginas la usan a través del componente `ListaPaginada`, nunca directamente.

## Esquemas
Los modelos están en `lib/modelos/`, uno por archivo. Las fechas van en ISO 8601 UTC y los ids como texto.

```json
{ "publicacion": {
  "id": "", "autor": { "id": "", "usuario": "", "avatarUrl": null },
  "imagenUrl": "", "imagenClave": "", "filtro": "ups", "texto": "",
  "meGusta": 0, "meGustaMio": false, "comentarios": 0,
  "privada": false, "creada": "2026-11-25T15:04:05Z" } }
```
```json
{ "comentario": { "id": "", "autor": {}, "texto": "", "creado": "" } }
```
```json
{ "procesamiento": {
  "id": "", "filtro": "media", "parametros": { "nivel": "medio" },
  "estado": "aplicando | lista | fallo",
  "originalUrl": "", "originalClave": "", "resultadoUrl": null, "resultadoClave": null,
  "creado": "" } }
```
```json
{ "perfil": { "id": "", "usuario": "", "nombre": "", "correo": "solo el propio", "descripcion": "", "avatarUrl": null,
  "publicaciones": 0, "meGusta": 0, "seguidores": 0, "loSigo": false } }
```
En el perfil, `usuario` es único y no se puede cambiar. `correo` solo se incluye en el perfil propio y tampoco se puede cambiar. `nombre` (completo) y `descripcion` son editables.

`imagenClave` es la ruta del archivo en Supabase Storage. A diferencia de una URL firmada, la clave no cambia, por lo que se usa para guardar la imagen en caché. Las métricas de GPU no se envían a la aplicación.

## Caché en el teléfono
No implementado.

| Dato | Dónde | Vigencia |
|---|---|---|
| Sesión y token | Almacenamiento seguro ([07](07-sesion-y-token.md)) | La de Supabase |
| Imágenes ya vistas | Disco | 7 días |
| Primera página de Inicio | Disco | 5 min |
| Perfil propio | Disco | 30 min |
| Primera página de publicaciones propias | Disco | 10 min |
| Historial, primera página | Disco | 2 min; nunca si hay algo en "aplicando" |
| Páginas siguientes y otros perfiles | Memoria | Mientras viva la pantalla |
| Comentarios | Memoria | No se guardan en disco porque se actualizan en tiempo real |

Un dato vencido no se borra: se muestra y se actualiza. Las vigencias están pendientes de definición.

**Bibliotecas**
| Para | Usar | Por qué |
|---|---|---|
| Imágenes | `cached_network_image` | Disco y memoria; `cacheKey` para usar la clave y `memCacheWidth` para no decodificar de más ([API](https://pub.dev/documentation/cached_network_image/latest/cached_network_image/CachedNetworkImage-class.html)) |
| Datos en JSON | `hive_ce` | Clave y valor, ligera ([pub.dev](https://pub.dev/documentation/hive_ce/2.23.3/)) |
| Preferencias sueltas | `shared_preferences` | Solo ajustes simples, nunca tokens |
| Relaciones o consultas | No se requiere | Si el proyecto crece, `drift` o `sqflite` |

Todo el acceso al caché pasa por `servicios/cache/`. Cada entrada guarda su fecha y la versión del esquema; si la versión cambia, la entrada se descarta. Las claves incluyen el id del usuario y al cerrar sesión se borra todo el caché.

