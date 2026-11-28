# Iconos y assets

Los recursos están en `upsglam_movil/assets/`. Las licencias y créditos se encuentran en [CREDITOS.md](../assets/CREDITOS.md).

## Iconos permitidos
Solo se usan los iconos de esta tabla. No se usan `Icons.*`, `cupertino_icons`, emojis ni dibujos propios. Un icono nuevo requiere aprobación previa y se registra aquí. Los iconos son SVG blancos de 24 y `AppIcono` les aplica el color del tema.

| Dónde | Archivos en `assets/iconos` |
|---|---|
| Menú | inicio, inicio_activo, perfil, perfil_activo |
| Publicación | me_gusta, me_gusta_activo, comentario, mas, filtros |
| Cámara | camara, galeria, girar, flash, flash_apagado, filtros, adelante |
| Navegación | atras, cerrar, flecha |
| Acciones | guardar, enviar, editar, eliminar, ajustes, tema |
| Perfil | publicaciones, publica, privada |
| Acceso | ver_clave, ocultar_clave |
| Alertas | alerta, alerta_archivo, alerta_tamano, alerta_espera |

`filtros` conserva sus colores originales. `publica` (un ojo: visible para todos) y `privada` (un candado: visible solo para el autor) se usan como pareja. `flash` y `ocultar_clave` representan el segundo estado de un icono ya aprobado. Todo icono que responde al toque lleva una descripción para lectores de pantalla.

## Logo
| Archivo | Uso |
|---|---|
| logo_negro.svg | Tema oscuro: sobre el fondo de la aplicación |
| logo_amarillo.svg | Tema oscuro: bola del menú y login |
| logo_azul.svg | Tema claro: suelto sobre el fondo de la página (Inicio) |
| logo_blanco.svg | Tema claro: sobre azul, en la bola del menú y el cuadro del login |

Cada logo lleva un borde del color de su fondo, por lo que no son intercambiables. El logo que corresponde lo decide el tema (`AppMarca` en `app_theme.dart`), nunca la página. Los logos no se deforman ni se les cambia el color.

## Imágenes
Siguen el estándar de Flutter: el archivo base en la carpeta y sus variantes en `2.0x/` y `3.0x/`; en `pubspec.yaml` se declara solo la carpeta base ([fuente](https://docs.flutter.dev/ui/assets/assets-and-images)). El formato es WebP.

| Carpeta | Contenido | Tamaño base |
|---|---|---|
| imagenes/filtros | normal, ups, nitidez, media, laplaciano, sobel, relieve | 64 × 64 |
| | media_bajo, media_medio, media_fuerte | 106 × 72 |
| imagenes/login | portada (original, Sobel, Relieve y UPS) | 390 × 192 |

Todas parten del mismo retrato (`avatar_4`). Son muestras del efecto calculadas fuera de la aplicación; el resultado real lo genera siempre el servidor.

| Filtro | Muestra | Operación |
|---|---|---|
| Media | Color | Convolución por canal |
| Nitidez | Color | Convolución por canal, centro 5 |
| Laplaciano | Blanco y negro | Convolución, valor absoluto (aclarado ×3 en la muestra) |
| Sobel | Blanco y negro | Dos convoluciones y su magnitud |
| Relieve | Color, efecto 3D | Convolución `-2 -1 0 / -1 1 1 / 0 1 2` por canal |
| UPS | Azul y amarillo | Color y bordes |

En `pubspec.yaml` se declaran `assets/logo/`, `assets/iconos/`, `assets/imagenes/filtros/`, `assets/imagenes/login/` y las fuentes.

## Icono de la aplicación y pantalla de carga
Están instalados en `android/` e `ios/`. Los originales están en `assets/iconos_aplicacion/` y no se declaran en `pubspec.yaml`, para no aumentar el tamaño de la aplicación.
- **Android:** icono adaptable y vectorial (fondo amarillo y logo dentro de la zona segura de 66 de 108 dp), versión monocroma vectorial para los iconos temáticos de Android 13+ y PNG por densidad ([fuente](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)).
- **iOS:** los 15 PNG que declara Flutter, cuadrados y sin transparencia, y la imagen de carga. Las versiones oscura y tintada de iOS 18 están creadas, pero no están conectadas (no implementado).
- **Carga en Android:** fondo `#101114` con el logo; en Android 12+ el icono de 288 dp cabe en un círculo de 192 ([fuente](https://developer.android.com/develop/ui/views/launch/splash-screen)). En versiones anteriores a Android 12 se usa `launch_background`, como indica [Flutter](https://docs.flutter.dev/platform-integration/android/splash-screen).
- La pantalla de carga, la ventana y la aplicación comparten el mismo fondo, para evitar un parpadeo al abrir.
- Si cambia el logo, se regeneran todos los iconos; no se edita uno por separado.
