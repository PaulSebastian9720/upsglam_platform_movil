# Iconos y assets

Están en `upsglam_movil/assets/` y, completos, en [docs/frontend/assets](../assets). Créditos: [CREDITOS.md](../assets/CREDITOS.md).

## Iconos permitidos
**Solo estos.** Prohibidos `Icons.*`, `cupertino_icons`, emojis y dibujos nuevos. Uno nuevo se aprueba antes y se agrega aquí. Son SVG blancos de 24; el color lo pone `AppIcono` desde el tema.

| Dónde | Archivos en `assets/iconos` |
|---|---|
| Menú | inicio, inicio_activo, perfil, perfil_activo |
| Publicación | me_gusta, me_gusta_activo, comentario, mas, filtros |
| Cámara | camara, galeria, girar, flash, flash_apagado, filtros, adelante |
| Navegación | atras, cerrar, flecha |
| Acciones | guardar, enviar, editar, eliminar, ajustes |
| Perfil | publicaciones, publica, privada |
| Acceso | google, ver_clave, ocultar_clave |
| Alertas | alerta, alerta_archivo, alerta_tamano, alerta_espera |

`google` y `filtros` conservan sus colores. `flash` y `ocultar_clave` son el otro estado de un icono ya aprobado. Todo icono que se toca lleva descripción.

## Logo
| Archivo | Uso |
|---|---|
| logo_negro.svg | Sobre el fondo de la app |
| logo_amarillo.svg | Bola del menú y login |

Los dos llevan el borde del color de su fondo: no mezclarlos. No deformar ni cambiar colores.

## Imágenes
Estándar de Flutter: el archivo base sin carpeta y sus variantes en `2.0x/` y `3.0x/`; se declara solo la carpeta base ([fuente](https://docs.flutter.dev/ui/assets/assets-and-images)). Formato WebP.

| Carpeta | Contenido | Tamaño base |
|---|---|---|
| imagenes/filtros | normal, ups, nitidez, media, laplaciano, sobel, relieve | 64 × 64 |
| | media_bajo, media_medio, media_fuerte | 106 × 72 |
| imagenes/login | portada (original, Sobel, Relieve y UPS) | 390 × 192 |

Todas parten del mismo retrato de perro (`avatar_4`). Son muestras del efecto, calculadas fuera de la app; el resultado real siempre viene del servidor.

| Filtro | Muestra | Operación |
|---|---|---|
| Media | Color | Convolución por canal |
| Nitidez | Color | Convolución por canal, centro 5 |
| Laplaciano | Blanco y negro | Convolución, valor absoluto (aclarado ×3 en la muestra) |
| Sobel | Blanco y negro | Dos convoluciones y su magnitud |
| Relieve | Color, efecto 3D | Convolución `-2 -1 0 / -1 1 1 / 0 1 2` por canal |
| UPS | Azul y amarillo | Color y bordes |

Declaradas en `pubspec.yaml`: `assets/logo/`, `assets/iconos/`, `assets/imagenes/filtros/`, `assets/imagenes/login/`, y las fuentes.

## Icono de la app y carga
**Ya instalados** en `android/` e `ios/`. Originales en `assets/iconos_aplicacion/` ([copia](../assets/iconos_aplicacion)); no se declaran en `pubspec.yaml`, para que no pesen en la app.
- **Android:** adaptable y vectorial (fondo amarillo, logo en la zona segura de 66 de 108 dp), **monocromo vectorial** para iconos temáticos de Android 13+, y PNG clásico por densidad ([fuente](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)).
- **iOS:** los 15 PNG que declara Flutter, cuadrados y sin transparencia, e imagen de carga. La versión oscura y la tintada (blanco y negro) de iOS 18 están creadas, sin conectar.
- **Carga en Android:** fondo `#101114` con el logo; en Android 12+ el icono de 288 dp cabe en un círculo de 192 ([fuente](https://developer.android.com/develop/ui/views/launch/splash-screen)). Antes de Android 12, `launch_background`, como indica [Flutter](https://docs.flutter.dev/platform-integration/android/splash-screen).
- Fondo de la carga, de la ventana y de la app son el mismo, para que no parpadee.
- Si cambia el logo se regeneran todos; no se edita uno suelto.
