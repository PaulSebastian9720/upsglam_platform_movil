# Menú inferior

La aplicación tiene un único menú inferior, global y ubicado en la raíz de la navegación. Se implementa con `StatefulShellRoute.indexedStack` de go_router, con una rama por pestaña, y el cambio de pestaña se hace con `goBranch` ([fuente](https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html)).

- Tiene dos pestañas: Inicio y Perfil. La cámara no es una pestaña: se abre a pantalla completa, por encima del resto y sin menú.
- Cada pestaña conserva su posición y sus datos.
- Al tocar la pestaña activa, la lista vuelve al inicio.
- La barra mide 54 de alto y 250 de ancho, con iconos de 24. La bola central mide 64, lleva un logo de 42 y sobresale de la barra. El fondo es `campo` y no hay textos. Cada botón tiene una descripción para lectores de pantalla.
- La bola usa `logo_amarillo.svg` en el tema oscuro y `logo_blanco.svg` en el claro.

## Comportamiento requerido
| Situación | Regla |
|---|---|
| Toques en la parte de la bola que sobresale | El área del menú mide el alto total (barra y bola), porque Flutter no entrega toques fuera de los límites del widget padre |
| Último elemento de una lista | Toda lista termina con un espacio igual al alto total del menú más el margen inferior del sistema |
| Botones de navegación del sistema | El menú respeta el área segura inferior |
| Teclado visible | El menú se oculta mientras el teclado está abierto |
| Cambio de pestaña | Cada pestaña es una rama que no se vuelve a crear, por lo que conserva el desplazamiento |
| Doble toque en la bola | Se ignora el segundo toque mientras la navegación está en curso |
| Gesto atrás | En Perfil vuelve a Inicio; en Inicio cierra la aplicación |
| Transición entre páginas | Ninguna página dibuja su propio menú; `BarraPrincipal` solo se usa en las rutas |
