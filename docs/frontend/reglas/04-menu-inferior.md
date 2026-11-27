# Menú inferior

**Uno solo, global, en la raíz de la navegación.** Se usa `StatefulShellRoute.indexedStack` de go_router, con una rama por pestaña y `goBranch` para cambiar
([fuente](https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html)).

- Dos pestañas: Inicio y Perfil. La cámara **no** es pestaña: se abre encima, a pantalla completa y sin menú.
- Cada pestaña conserva su posición y sus datos.
- Tocar la pestaña activa sube al inicio de la lista.
- Barra de 54 de alto y 250 de ancho, iconos de 24, bola de 64 con logo de 42 que sobresale, fondo `campo`, sin textos. Cada botón con descripción para lectores de pantalla.
- La bola usa `logo_amarillo.svg`.

## Bugs que hay que evitar
| Bug | Regla | Cómo se prueba |
|---|---|---|
| La parte que sobresale no responde | El área del menú mide el alto **total** (barra más bola). Flutter no entrega toques fuera de los límites del padre | Tocar el borde superior de la bola |
| Tapa el último elemento | Toda lista termina con espacio igual al alto total más el margen del sistema | Llegar al final de Inicio y de Perfil |
| Se monta en los botones del sistema | Respetar el área segura inferior | Probar con gestos y con tres botones |
| Salta al abrir el teclado | Se oculta con el teclado visible | Abrir comentarios y escribir |
| Se pierde el scroll al cambiar de pestaña | Una rama por pestaña, sin recrearla | Bajar en Inicio, ir a Perfil y volver |
| Se abre la cámara dos veces | Se ignora el segundo toque mientras navega | Doble toque rápido en la bola |
| Atrás cierra la app desde Perfil | Atrás en Perfil vuelve a Inicio; en Inicio, sale | Gesto atrás en ambas |
| Parpadea entre páginas | Ninguna página dibuja su propio menú | Buscar BarraPrincipal: solo en rutas |
