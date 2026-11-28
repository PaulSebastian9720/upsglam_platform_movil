# Imágenes y zoom

## Marcos fijos
Todas las fotos pasan por `ImagenApp`. El hueco se reserva **antes** de cargar, así nada salta. Rellenan su marco y se recortan al centro.

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

El recorte es solo visual: el archivo enviado y el resultado conservan su tamaño. La foto que se envía ya sale optimizada de la cámara o la galería (WEBP, lado mayor de 2560 px): ver [11-camara](11-camara.md#optimización).

## Zoom
**En la misma foto** (publicaciones en Inicio y Ver publicación, Editar e Historial): `ZoomEnSitio`.
- Con dos dedos la foto crece ahí mismo, por encima de todo y con el fondo oscurecido; escala de **1 a 4**.
- Al soltar vuelve a su lugar. Con un dedo la lista se desplaza como siempre; mientras se amplía, la lista no se mueve.

**En ventana nueva** (solo la foto de perfil): `VisorImagen`.
- Se abre al tocar la foto de perfil. Fondo negro, foto **completa** sin recorte, sobre `InteractiveViewer`.
- Escala de 1 a 4; doble toque alterna entre 1 y 2; deslizar hacia abajo cierra, solo en escala 1.

No hay zoom en cuadrículas, ruedas ni avatares de listas.

## Peso
- Decodificar al tamaño del marco, no al del archivo.
- Miniaturas en cuadrículas e historial; la grande, solo al abrirla.
- Carga: bloque `campo`. Error: icono `alerta` y toque para reintentar.
- Nunca se guarda una imagen en el estado de un controlador; solo su referencia.

## Para revisar
- [ ] La lista no salta mientras cargan fotos.
- [ ] Pellizcar en el visor no mueve lo de atrás.
