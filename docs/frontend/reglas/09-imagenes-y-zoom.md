# Imágenes y zoom

## Marcos fijos
Todas las fotos se muestran con `ImagenApp`. El espacio de la imagen se reserva antes de cargarla, para que el contenido no cambie de posición. Las fotos rellenan su marco y se recortan al centro.

| Marco | Proporción o tamaño | Esquinas |
|---|---|---|
| Publicación | Todo el ancho, 5:6 (390 × 468) | Rectas |
| Cuadrícula de perfil | 3 columnas, 129 × 150, separación 2 | Rectas |
| Portada de login | Todo el ancho, 390 × 192 | Rectas |
| Cámara | Todo el ancho, 3:4, entre la barra de arriba y la de abajo; sin recorte | Rectas |
| Edición | Todo el ancho, hasta el panel | Rectas |
| Historial | 64 × 64 | Rectas |
| Publicar, miniatura | 124 × 190 | Rectas |
| Nivel de Media | 106 × 72 | 10 |
| Rueda de filtro | 64 | Círculo |
| Avatar | 36 feed, 38 comentarios, 54 listas, 88 perfil, 132 editar | Círculo |

El recorte es solo visual: el archivo enviado y el resultado conservan su tamaño. La foto que se envía sale optimizada desde la cámara o la galería (WEBP, lado mayor de 2560 px), según [11-camara](11-camara.md#optimización).

## Zoom
**Sobre la misma foto** (publicaciones en Inicio y Ver publicación, Editar e Historial): `ZoomEnSitio`.
- Al pellizcar con dos dedos, la foto se amplía en su lugar, por encima del resto y con el fondo oscurecido. La escala va de 1 a 4.
- Al soltar, la foto vuelve a su posición. Con un dedo la lista se desplaza con normalidad; mientras la foto está ampliada, la lista no se mueve.

**En una pantalla nueva** (solo la foto de perfil): `VisorImagen`.
- Se abre al tocar la foto de perfil y la muestra completa, sin recorte, sobre fondo negro con `InteractiveViewer`.
- La escala va de 1 a 4. El doble toque alterna entre 1 y 2. Deslizar hacia abajo cierra el visor, solo en escala 1.

No hay zoom en cuadrículas, ruedas ni avatares de listas.

## Rendimiento
- Las imágenes se decodifican al tamaño del marco, no al del archivo.
- Las cuadrículas y el historial usan miniaturas; la imagen grande se carga solo al abrirla.
- Mientras carga, la imagen se muestra como un bloque de color `campo`. Si falla, se muestra el icono `alerta` y un toque permite reintentar.
- El estado de un controlador guarda solo la referencia de una imagen, nunca la imagen.
- Al pellizcar en el visor, el contenido de fondo no se mueve.

