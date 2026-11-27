# Componentes

Se extrae un componente cuando se usa en **dos o más páginas**. Si es de una sola, va en la carpeta de esa página.

| Componente | Para qué | Recibe |
|---|---|---|
| BarraPrincipal | Menú inferior | pestaña activa |
| AppAlerta | Todas las alertas | tipo de alerta |
| BotonPrincipal | Acción amarilla | texto, acción, cargando |
| BotonSecundario | Acción con borde | texto, icono, acción, cargando |
| CampoTexto | Todos los campos, con etiqueta flotante: dentro de la caja y sube al borde al tocarla | etiqueta, validador, tipo, líneas |
| AppIcono | Todos los iconos | nombre, tamaño, color, descripción |
| ImagenApp | Todas las fotos | origen, marco |
| VisorImagen | Zoom en ventana nueva: solo la foto de perfil | imagen |
| ZoomEnSitio | Zoom con dos dedos sobre la misma foto de una publicación | foto |
| AvatarUsuario | Foto de perfil | imagen, tamaño |
| TarjetaPublicacion | Publicación en Inicio y Ver publicación | publicación, acciones |
| RuedaFiltro | Filtros en editar e historial | filtro, seleccionada, cargando, falló |
| ListaPaginada | Toda lista o cuadrícula con páginas | controlador, elemento |
| HojaApp | Hojas inferiores (comentarios) | título, contenido |
| EncabezadoPagina | Flecha y título | título, acción |
| BotonRedondo | Icono sobre una foto | icono, descripción, acción |
| SelectorFiltro | Fila de ruedas, en editar | filtro elegido, acción |
| EstadoVacio | Sin datos o error con reintento | mensaje, acción |

## Botones
- Alto 46, radio 10, padding 16, ancho completo o a mitades con separación 12.
- Amarillo: una sola acción por pantalla. El resto, con borde.
- Destructivo: rojo, y siempre pide confirmación.
- Al pulsar se deshabilita y muestra carga hasta terminar. El tamaño no cambia.
- Texto: verbo y, si hace falta, objeto. "Guardar cambios", no "Aceptar".

## RuedaFiltro
64 dp, círculo. Seleccionada: borde amarillo de 3. Cargando: imagen oscurecida y aro girando **solo en ella**; las demás se bloquean. Falló: icono de alerta en rojo. "Original" siempre es la primera.

| Filtro | Control |
|---|---|
| Media | Tres niveles: Bajo, Medio, Fuerte |
| UPS, Nitidez, Laplaciano, Relieve | Barra de intensidad, se envía al soltar |
| Sobel | Tres opciones: Horizontal, Vertical, Ambas |

## Estados
- **Carga:** bloques grises con la forma final, para que nada salte. Nunca pantalla en blanco.
- **Vacío y error:** `EstadoVacio`, con una acción.
- **Recarga:** se mantiene lo que había mientras llega lo nuevo.

## Prohibido
Copiar un componente para cambiarle un detalle (se le agrega un parámetro), y texto o datos fijos dentro de un componente.
