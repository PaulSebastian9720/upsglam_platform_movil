# Cámara

`paginas/camara` → `FotosRepositorio` → `CamaraService`, `GaleriaService` e `ImagenService`. Nadie más usa la cámara ni la galería.

| Pieza | Regla |
|---|---|
| Encuadre | El visor va en un cuadro 3:4 a todo el ancho, con una barra arriba (cerrar y flash) y otra abajo (galería, disparo y girar). Muestra el cuadro **entero** del sensor: lo que se ve es exactamente lo que se envía, sin recortes ni cambios de encuadre después. Si una cámara no da 3:4, el visor toma su forma dentro del cuadro |
| Fondo | Siempre oscuro, con cualquier tema |
| Filtro | No aparece en la cámara. Se elige **después** de la foto, en Editar, y empieza en Original |
| Foto | Queda en un archivo temporal ya optimizado; se borra al volver a la cámara |
| Galería | Selector del sistema, sin permiso de fotos. El tipo se comprueba por el contenido: JPG, PNG, WEBP o HEIC; si no, alerta `archivoNoValido` |
| Permiso | Solo cámara, al abrirla. Nunca micrófono |
| Negado / bloqueado | "Permitir" / "Abrir ajustes". La galería sigue disponible |
| Flash | Apagado o encendido; solo en la cámara trasera |
| Orden | Abrir, cerrar, girar y disparar van en una fila: no se pisan |
| Segundo plano, galería y Editar | La cámara se suelta y se recupera al volver |
| Orientación | La app va en vertical |

`camera_android_camerax` está fijado en 0.7.1+2 (CameraX 1.5.3): con 0.7.2 (CameraX 1.6.0) la app se cerró una vez al girar la cámara en el emulador. Antes de subirlo, repetir el giro muchas veces en un teléfono.

## Optimización
Justo después de tomar o elegir la foto, en Android y en iOS, `ImagenService` la convierte una sola vez:
- El lado mayor queda en **2560 px** como máximo, con la misma proporción. Si es más pequeña, no se agranda.
- Se guarda en **WEBP con calidad 85**, que pesa un 25–30 % menos que un JPG de igual calidad. Las HEIC del iPhone también salen en WEBP: nunca se envía HEIC.
- Esa es la foto que se ve en Editar y Publicar y la que se envía. La copia original se borra.

Por qué: menos datos por la red, menos espacio en el almacenamiento y menos trabajo para los filtros, sin pérdida visible. En un teléfono de 1080 px de ancho, 2560 px se ve nítida sin zoom y hasta 1,8× con zoom.

Biblioteca: `flutter_image_compress`. Genera WEBP en Android con el codificador del sistema y en iOS con SDWebImageWebPCoder (más lento, pero funciona). Si no puede convertir, la galería muestra `archivoNoValido` y la cámara pasa a fallo.

## Para revisar
- [ ] Lo que se ve en el cuadro es lo mismo que sale en Editar, sin bordes de más.
- [ ] Una foto de la galería en HEIC (iPhone) llega como WEBP.
- [ ] Doble toque al disparar toma una sola foto.
- [ ] Girar muchas veces seguidas no cierra la app.
- [ ] Ir al inicio del teléfono y volver muestra el visor.
- [ ] Negar el permiso, y concederlo luego en ajustes, la abre sin reiniciar.
