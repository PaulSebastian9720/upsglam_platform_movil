# Datos, paginación y caché

## Carga dinámica
- Se muestra primero lo guardado y después se actualiza con la red; el repositorio es el único que decide ([patrón oficial](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)).
- Las listas se construyen a medida que se ven, con constructores perezosos ([fuente](https://docs.flutter.dev/cookbook/lists/long-lists)).
- Deslizar hacia abajo actualiza. Volver a una pantalla **no** recarga si el dato sigue vigente.
- Los cambios propios (me gusta, comentar) se ven al instante y se deshacen si el servidor falla.

## Paginación
**Por cursor, no por número de página:** si alguien publica mientras bajas, no se repite ni se salta nada. Orden: fecha y luego id, descendente.

Petición: `GET /publicaciones?limite=10&cursor=<cursor>`. La primera va sin cursor.

Respuesta, **igual para todas las listas**:
```json
{
  "elementos": [],
  "siguienteCursor": "texto opaco o null",
  "hayMas": true
}
```
El cursor es opaco: la app lo guarda y lo devuelve, nunca lo interpreta. Rutas y campos son **propuesta, por acordar con el backend**.

| Lista | Ruta | Límite | Al final |
|---|---|---|---|
| Inicio | `/publicaciones` | 10 | Carga más a 3 elementos del final |
| Publicaciones de un usuario | `/usuarios/{id}/publicaciones` | 18 | Cuadrícula de 3 |
| Comentarios | `/publicaciones/{id}/comentarios` | 20 | Más antiguos arriba |
| Historial | `/historial` | 15 | Solo el propio |
| Seguidos (opcional) | `/usuarios/{id}/seguidos` | 20 | |

**Reglas de la lista**
- No se pide una página si ya hay una pedida o si `hayMas` es falso.
- Se descartan repetidos por id.
- Si falla, se conserva lo cargado y se ofrece reintentar esa página.
- Actualizar reemplaza la primera página y limpia los cursores.
- Biblioteca: `infinite_scroll_pagination` ([fuente](https://pub.dev/documentation/infinite_scroll_pagination/latest/)), que no impone una estrategia y por tanto admite cursores. El componente propio es `ListaPaginada`; ninguna página la usa directo.

## Esquemas
Viven en `lib/modelos/<modelo>/`. Fechas en ISO 8601 UTC; ids como texto.

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
{ "perfil": { "id": "", "usuario": "", "descripcion": "", "avatarUrl": null,
  "publicaciones": 0, "meGusta": 0, "seguidores": 0, "loSigo": false } }
```
`imagenClave` es la ruta en Supabase Storage. Una URL firmada cambia; la clave no, y con ella se guarda la imagen. Las métricas de GPU se quedan en el backend.

## Qué se guarda en el teléfono
| Dato | Dónde | Vigencia |
|---|---|---|
| Sesión y token | Almacenamiento seguro ([07](07-sesion-y-token.md)) | La de Supabase |
| Imágenes ya vistas | Disco | 7 días |
| Primera página de Inicio | Disco | 5 min |
| Perfil propio | Disco | 30 min |
| Primera página de publicaciones propias | Disco | 10 min |
| Historial, primera página | Disco | 2 min; nunca si hay algo en "aplicando" |
| Páginas siguientes y otros perfiles | Memoria | Mientras viva la pantalla |
| Comentarios | Memoria | Nunca a disco: son en vivo |

Vencido no significa borrado: se muestra y se actualiza. Las vigencias son propuesta del proyecto.

**Bibliotecas**
| Para | Usar | Por qué |
|---|---|---|
| Imágenes | `cached_network_image` | Disco y memoria; `cacheKey` para usar la clave y `memCacheWidth` para no decodificar de más ([API](https://pub.dev/documentation/cached_network_image/latest/cached_network_image/CachedNetworkImage-class.html)) |
| Datos en JSON | `hive_ce` | Clave y valor, ligera ([pub.dev](https://pub.dev/documentation/hive_ce/2.23.3/)) |
| Preferencias sueltas | `shared_preferences` | Solo ajustes simples, nunca tokens |
| Relaciones o consultas | No hace falta | Si crece, `drift` o `sqflite` |

Todo pasa por `servicios/cache/`. Cada entrada guarda fecha y versión del esquema; si la versión cambia, se descarta. Las claves llevan el id del usuario y **al salir se borra todo**.

## Para revisar
- [ ] Ir a Perfil y volver a Inicio no lanza una petición.
- [ ] Sin conexión se ve la última primera página.
- [ ] Entrar con otro usuario no muestra nada del anterior.
