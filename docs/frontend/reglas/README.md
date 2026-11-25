# Reglas del frontend

App móvil Flutter (Android), pequeña, por páginas. Léelas antes de programar una pantalla.

**Si algo se contradice:** 1) PDF del proyecto, 2) estas reglas, 3) láminas en [upsglam.html](../../views/upsglam.html).
Las láminas usan padding 24 en formularios y radios mayores; manda lo de aquí: **padding 16, radio 10, hojas 20**.

| Archivo | Qué define |
|---|---|
| [01-tema.md](01-tema.md) | Colores, tipografía, padding, radio |
| [02-estructura.md](02-estructura.md) | Carpetas, clases, páginas y rutas |
| [03-componentes.md](03-componentes.md) | Piezas reutilizables y botones |
| [04-menu-inferior.md](04-menu-inferior.md) | Menú global sin bugs |
| [05-alertas.md](05-alertas.md) | Componente único de alertas |
| [06-formularios.md](06-formularios.md) | Validaciones y teclado |
| [07-sesion-y-token.md](07-sesion-y-token.md) | Dónde está el token y cómo se usa |
| [08-datos-y-cache.md](08-datos-y-cache.md) | Paginación, esquemas y caché |
| [09-imagenes-y-zoom.md](09-imagenes-y-zoom.md) | Marcos, zoom y peso |
| [10-iconos-y-assets.md](10-iconos-y-assets.md) | Iconos permitidos, logos, carga |
| [11-camara.md](11-camara.md) | Cámara, galería y permiso |

## Diez reglas que no se negocian
1. Un color, medida o letra se escribe **solo** en `lib/tema/app_theme.dart`.
2. Una clase por archivo y su propia carpeta.
3. La página no llama a Supabase, a la API ni al caché: pasa por su controlador y un repositorio.
4. El token se lee solo en `servicios/sesion` y se envía solo desde `servicios/api`.
5. Un solo menú inferior, en la raíz. Ninguna página crea otro.
6. Alertas solo con `AppAlerta`.
7. Los campos se validan al salir y el error no mueve nada.
8. Solo iconos de `assets/iconos`.
9. Toda lista se pide por páginas y no se vuelve a pedir lo ya traído.
10. Nada técnico para el usuario: ni GPU, ni matrices, ni colas.

## Antes de dar por lista una pantalla
- [ ] Coincide con su lámina y con estas reglas.
- [ ] Tiene carga, vacío y error.
- [ ] Sin desbordes a 360 dp de ancho ni con letra del sistema al 130 %.
- [ ] El teclado no tapa el campo activo.
- [ ] Un botón no envía dos veces.
- [ ] No hay colores, radios ni tamaños sueltos.
