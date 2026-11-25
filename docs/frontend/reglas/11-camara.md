# Cámara

`paginas/camara` → `FotosRepositorio` → `CamaraService` y `GaleriaService`. Nadie más usa la cámara ni la galería.

| Pieza | Regla |
|---|---|
| Filtro | Se **elige** en la cámara y se aplica **después** de la foto, en Editar. El visor nunca muestra un filtro |
| Foto | Queda en un archivo temporal; se borra al volver a la cámara |
| Galería | Selector del sistema, sin permiso de fotos. El tipo se comprueba por el contenido: JPG, PNG o WEBP; si no, alerta `archivoNoValido` |
| Permiso | Solo cámara, al abrirla. Nunca micrófono |
| Negado / bloqueado | "Permitir" / "Abrir ajustes". La galería sigue disponible |
| Flash | Apagado o encendido; solo en la cámara trasera |
| Orden | Abrir, cerrar, girar y disparar van en una fila: no se pisan |
| Segundo plano, galería y Editar | La cámara se suelta y se recupera al volver |
| Orientación | La app va en vertical |

`camera_android_camerax` está fijado en 0.7.1+2 (CameraX 1.5.3): con 0.7.2 (CameraX 1.6.0) la app se cerró una vez al girar la cámara en el emulador. Antes de subirlo, repetir el giro muchas veces en un teléfono.

## Para revisar
- [ ] Doble toque al disparar toma una sola foto.
- [ ] Girar muchas veces seguidas no cierra la app.
- [ ] Ir al inicio del teléfono y volver muestra el visor.
- [ ] Negar el permiso, y concederlo luego en ajustes, la abre sin reiniciar.
