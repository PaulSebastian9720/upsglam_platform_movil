# Cámara

La cámara y la galería se usan solo a través de esta cadena: `paginas/camara` → `FotosRepositorio` → `CamaraService`, `GaleriaService` e `ImagenService`.

| Pieza | Regla |
|---|---|
| Encuadre | El visor ocupa un cuadro 3:4 a todo el ancho, con una barra superior (cerrar y flash) y otra inferior (galería, disparo y girar). Muestra el cuadro completo del sensor: lo que se ve es lo que se envía, sin recortes ni cambios de encuadre posteriores. Si una cámara no entrega 3:4, el visor adopta su proporción dentro del cuadro |
| Fondo | Siempre oscuro, sin importar el tema elegido |
| Filtro | No aparece en la cámara. Se elige después de tomar la foto, en Editar, y empieza en Original |
| Foto | Se guarda en un archivo temporal ya optimizado, que se borra al volver a la cámara |
| Galería | Selector del sistema, sin permiso de fotos. El tipo se comprueba por el contenido del archivo (JPG, PNG, WEBP o HEIC); en otro caso se muestra la alerta `archivoNoValido` |
| Permiso | Solo cámara, solicitado al abrirla. Nunca micrófono |
| Permiso negado o bloqueado | Se ofrece "Permitir" o "Abrir ajustes", según el caso. La galería sigue disponible |
| Flash | Apagado o encendido, solo en la cámara trasera. Si la cámara no tiene flash, se avisa con un mensaje breve |
| Orden de operaciones | Abrir, cerrar, girar y disparar se ejecutan en cola, sin superponerse. Un doble toque al disparar toma una sola foto |
| Segundo plano, galería y Editar | La cámara se libera y se recupera al volver |
| Orientación | La aplicación funciona solo en vertical |

`camera_android_camerax` está fijado en la versión 0.7.1+2 (CameraX 1.5.3), porque con 0.7.2 (CameraX 1.6.0) la aplicación se cerró al girar la cámara en el emulador. La actualización queda sujeta a verificación en un dispositivo físico.

## Optimización
Inmediatamente después de tomar o elegir la foto, en Android y en iOS, `ImagenService` la convierte una sola vez:
- El lado mayor se limita a 2560 px, conservando la proporción. Las fotos más pequeñas no se amplían.
- Se guarda en WEBP con calidad 85, que pesa entre un 25 y un 30 % menos que un JPG de calidad equivalente. Las fotos HEIC del iPhone también se convierten a WEBP; la aplicación nunca envía HEIC.
- Esa es la foto que se muestra en Editar y Publicar y la que se envía. La copia original se borra.

Esta conversión reduce los datos enviados por la red, el espacio ocupado en el almacenamiento y el tiempo de procesamiento de los filtros, sin pérdida visible de calidad. En una pantalla de 1080 px de ancho, una foto de 2560 px se ve nítida sin zoom y hasta un zoom de 1,8×.

La conversión usa la biblioteca `flutter_image_compress`, que genera WEBP en Android con el codificador del sistema y en iOS con SDWebImageWebPCoder, más lento pero funcional. Si la conversión falla, la galería muestra la alerta `archivoNoValido` y la cámara pasa al estado de fallo.

