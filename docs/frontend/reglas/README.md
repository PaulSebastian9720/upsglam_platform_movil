# Reglas del frontend

Normas de diseño y desarrollo de la aplicación móvil UPSGlam, construida en Flutter para Android e iOS.

## Orden de prioridad
Ante una contradicción entre documentos, prevalece este orden:

1. Enunciado del proyecto (PDF).
2. Estas reglas.
3. Diseño de pantallas en [upsglam.html](../../views/upsglam.html).

El diseño usa en algunos formularios un margen de 24 y radios mayores. En la aplicación rigen los valores de estas reglas: margen 16, radio 10 y hojas con radio 20.

## Documentos
| Archivo | Contenido |
|---|---|
| [01-tema.md](01-tema.md) | Colores, tipografía, márgenes y radios |
| [02-estructura.md](02-estructura.md) | Carpetas, capas, páginas y rutas |
| [03-componentes.md](03-componentes.md) | Componentes reutilizables y botones |
| [04-menu-inferior.md](04-menu-inferior.md) | Menú inferior global |
| [05-alertas.md](05-alertas.md) | Componente único de alertas |
| [06-formularios.md](06-formularios.md) | Validaciones y teclado |
| [07-sesion-y-token.md](07-sesion-y-token.md) | Almacenamiento y uso del token |
| [08-datos-y-cache.md](08-datos-y-cache.md) | Paginación, esquemas y caché |
| [09-imagenes-y-zoom.md](09-imagenes-y-zoom.md) | Marcos de imagen, zoom y rendimiento |
| [10-iconos-y-assets.md](10-iconos-y-assets.md) | Iconos, logos e imágenes |
| [11-camara.md](11-camara.md) | Cámara, galería, permisos y optimización de fotos |

## Normas generales
1. Los colores, medidas y estilos de texto se definen únicamente en `lib/tema/app_theme.dart`.
2. Cada archivo contiene una sola clase pública. Componentes, servicios, modelos y repositorios son archivos sueltos; cada página tiene su propia carpeta. Los imports parten de `package:upsglam_movil/` y nunca son relativos.
3. Las páginas no acceden a Supabase, a la API ni al caché: lo hacen a través de su controlador y de un repositorio.
4. El token se lee únicamente en el servicio de sesión y se envía únicamente desde el servicio de API.
5. Existe un solo menú inferior, definido en la raíz de la navegación.
6. Todas las alertas se muestran con `AppAlerta`.
7. Los campos se validan al salir de ellos y el mensaje de error no desplaza otros elementos.
8. Solo se usan los iconos de `assets/iconos`.
9. Las listas se solicitan por páginas y no se vuelve a pedir lo que ya se cargó.
10. La interfaz no muestra términos técnicos como GPU, matrices o colas.

## Convenciones de estado
Algunas secciones describen partes que aún no existen en la aplicación. Se indican así:

- **No implementado:** la regla está definida, pero el código todavía no existe.
- **Pendiente de definición:** el valor o el comportamiento debe acordarse con el backend o con el docente.
