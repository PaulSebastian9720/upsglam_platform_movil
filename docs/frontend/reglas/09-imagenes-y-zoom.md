# Imágenes y zoom

## Marcos fijos
Todas las fotos pasan por `ImagenApp`. El hueco se reserva **antes** de cargar, así nada salta. Rellenan su marco y se recortan al centro.

| Marco | Proporción o tamaño | Esquinas |
|---|---|---|
| Publicación | Todo el ancho, 5:6 (390 × 468) | Rectas |
| Cuadrícula de perfil | 3 columnas, 129 × 150, separación 2 | Rectas |
| Portada de login | Todo el ancho, 390 × 192 | Rectas |
| Edición y cámara | Todo el ancho, hasta el panel | Rectas |
| Historial | 64 × 64 | Rectas |
| Publicar, miniatura | 124 × 190 | Rectas |
| Nivel de Media | 106 × 72 | 10 |
| Rueda de filtro | 64 | Círculo |
| Avatar | 36 feed, 38 comentarios, 54 listas, 88 perfil, 132 editar | Círculo |

El recorte es solo visual: el archivo enviado y el resultado conservan su tamaño.

## Zoom estándar
- Se abre al tocar una foto en Inicio, Ver publicación, Editar e Historial. No en cuadrículas, ruedas ni avatares.
- `VisorImagen` a pantalla completa, fondo negro, sobre `InteractiveViewer` de Flutter.
- Escala de **1 a 4**. Pellizcar amplía; doble toque alterna entre 1 y 2; deslizar hacia abajo cierra, solo en escala 1.
- Se ve la foto **completa**, sin recorte, y con más resolución que en el marco.
- Al cerrar vuelve a escala 1. El gesto no compite con el desplazamiento de la lista, porque ocurre en otra pantalla.

## Peso
- Decodificar al tamaño del marco, no al del archivo.
- Miniaturas en cuadrículas e historial; la grande, solo al abrirla.
- Carga: bloque `campo`. Error: icono `alerta` y toque para reintentar.
- Nunca se guarda una imagen en el estado de un controlador; solo su referencia.

## Para revisar
- [ ] La lista no salta mientras cargan fotos.
- [ ] Pellizcar en el visor no mueve lo de atrás.
