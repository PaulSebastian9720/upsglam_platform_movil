# Componentes

Un elemento se convierte en componente cuando se usa en dos o más páginas. Si lo usa una sola página, se ubica en la carpeta de esa página.

| Componente | Para qué | Recibe |
|---|---|---|
| BarraPrincipal | Menú inferior | pestaña activa |
| AppAlerta | Todas las alertas | tipo de alerta |
| BotonPrincipal | Acción amarilla | texto, acción, cargando |
| BotonSecundario | Acción con borde | texto, icono, acción, cargando |
| CampoTexto | Todos los campos, con etiqueta flotante: aparece dentro del campo y sube al borde al enfocarlo | etiqueta, validador, tipo, líneas |
| AppIcono | Todos los iconos | nombre, tamaño, color, descripción |
| ImagenApp | Todas las fotos | origen, marco |
| VisorImagen | Zoom en ventana nueva: solo la foto de perfil | imagen |
| ZoomEnSitio | Zoom con dos dedos sobre la misma foto de una publicación | foto |
| AvatarUsuario | Foto de perfil | imagen, tamaño |
| TarjetaPublicacion | Publicación en Inicio y Ver publicación | publicación, acciones |
| RuedaFiltro | Filtros en editar e historial | filtro, seleccionada, cargando, falló |
| ListaPaginada (no implementado) | Toda lista o cuadrícula con páginas | controlador, elemento |
| HojaApp (no implementado) | Hojas inferiores; por ahora los comentarios usan una hoja propia | título, contenido |
| EncabezadoPagina | Flecha y título | título, acción |
| BotonRedondo | Icono sobre una foto | icono, descripción, acción |
| SelectorFiltro | Fila de ruedas, en editar | filtro elegido, acción |
| EstadoVacio | Sin datos o error con reintento | mensaje, acción |

## Botones
- Alto 46, radio 10 y margen interno 16. Ocupan todo el ancho o la mitad, con separación de 12.
- El botón amarillo se usa para una sola acción por pantalla; el resto lleva borde.
- Las acciones destructivas usan botón rojo y siempre piden confirmación.
- Al pulsarlo, el botón se deshabilita y muestra un indicador de carga hasta terminar, sin cambiar de tamaño.
- El texto es un verbo seguido del objeto cuando hace falta: "Guardar cambios", no "Aceptar".

## RuedaFiltro
Círculo de 64 dp. La rueda seleccionada lleva un borde amarillo de 3. Mientras se aplica un filtro, solo esa rueda muestra la imagen oscurecida y un indicador circular, y las demás quedan bloqueadas. Si el filtro falla, muestra un icono de alerta en rojo. "Original" es siempre la primera.

| Filtro | Control |
|---|---|
| Media | Tres niveles: Bajo, Medio, Fuerte |
| UPS, Nitidez, Laplaciano, Relieve | Barra de intensidad, se envía al soltar |
| Sobel | Tres opciones: Horizontal, Vertical, Ambas |

## Estados
- **Carga:** bloques grises con la forma final del contenido, para que nada cambie de posición. No se muestra una pantalla en blanco.
- **Vacío y error:** `EstadoVacio`, con una acción.
- **Recarga:** el contenido anterior se mantiene mientras llega el nuevo.

## Restricciones
- No se copia un componente para cambiar un detalle; en su lugar se le agrega un parámetro.
- Los componentes no contienen textos ni datos fijos.
