# Estructura

La arquitectura sigue la guía oficial de Flutter, con una capa de interfaz (vista y modelo de vista) y una capa de datos (repositorio y servicio) ([guía](https://docs.flutter.dev/app-architecture/guide), [recomendaciones](https://docs.flutter.dev/app-architecture/recommendations)).

Por el tamaño del proyecto se tomaron tres decisiones: las páginas se organizan en carpetas propias, no hay capa de dominio y los nombres están en español.

```
lib/
  main.dart              arranque
  app.dart               MaterialApp, tema y proveedores
  config/                direcciones y claves públicas del entorno (no implementado)
  tema/                  app_theme.dart (único lugar de colores y medidas) y tema_controller.dart (modo elegido)
  rutas/                 navegación
  modelos/               un archivo por modelo: perfil, autor, publicacion, comentario, procesamiento, filtro, foto
  servicios/             un archivo por servicio: camara, galeria, imagen, preferencias, datos_prueba
  repositorios/          un archivo por dato: publicaciones, comentarios, perfil, procesamiento, seguidos, fotos
  componentes/           un archivo por pieza reutilizable en dos o más páginas
  paginas/<pagina>/      la página, su controlador y sus piezas propias
  utilidades/            validadores y formatos
assets/  logo/ iconos/ iconos_aplicacion/ imagenes/filtros/ imagenes/login/ fuentes/
```

## Cada clase
| Tipo | Archivo | Hace | No hace |
|---|---|---|---|
| Página | `inicio_page.dart` | Construye la interfaz | Lógica, red, caché |
| Controlador | `inicio_controller.dart` | Estado de la página (`ChangeNotifier`) | Construir widgets o navegar |
| Repositorio | `publicaciones_repositorio.dart` | Única fuente del dato; decide caché o red | Conocer widgets u otros repositorios |
| Servicio | `api_service.dart` | Envuelve una sola cosa externa, sin estado de pantalla | Decidir qué se muestra |
| Modelo | `publicacion.dart` | Datos inmutables | Llamar a nada |

- Cada archivo contiene una sola clase pública. `componentes/`, `servicios/`, `modelos/` y `repositorios/` contienen archivos sueltos; solo las páginas tienen carpeta propia. Los archivos se nombran en `snake_case` y las clases en `PascalCase`.
- Los imports son absolutos desde la raíz del paquete, por ejemplo `import 'package:upsglam_movil/tema/app_theme.dart';`. No se usan rutas relativas (`../`); el analizador lo exige con `always_use_package_imports`.
- Las dependencias se inyectan con `provider`, como recomienda la guía. No se usan variables globales ni singletons.
- Las dependencias van en un solo sentido: página → controlador → repositorio → servicio.

## Quién puede usar a quién
| Desde | Puede usar | Prohibido |
|---|---|---|
| páginas | su controlador, componentes, tema, rutas | repositorios, servicios, otras páginas |
| controladores | repositorios, modelos, utilidades | widgets, servicios de red |
| repositorios | servicios, modelos | páginas, otros repositorios |
| componentes | tema, modelos | controladores, repositorios |

## Páginas y rutas
| Lámina | Ruta | Carpeta | Menú |
|---|---|---|---|
| Login | `/login` | login | No |
| Crear cuenta | `/registro` | registro | No |
| Inicio | `/inicio` | inicio | Sí |
| Comentarios | `/publicacion/:id/comentarios`, hoja sobre Inicio o Ver publicación | comentarios | No |
| Cámara | `/camara` | camara | No |
| Aplicando, Media, UPS | `/editar` | editar | No |
| Publicar | `/publicar`, recibe la foto con su filtro desde Editar o Historial | publicar | No |
| Perfil | `/perfil` | perfil | Sí |
| Historial (pestaña) | Pestaña de `/perfil`, sin ruta propia | perfil | Sí |
| Historial, lista o falló | `/perfil/historial/:id` | historial_detalle | No |
| Configuración y actividad | `/configuracion` | configuracion | No |
| Editar perfil | `/configuracion/perfil` | editar_perfil | No |
| Mis publicaciones | `/configuracion/publicaciones` | mis_publicaciones | No |
| Editar publicación | `/publicacion/:id/editar` | editar_publicacion | No |
| Perfil de otra persona | `/usuario/:id` | otro_perfil | Sí |
| Seguidores | `/perfil/seguidores` y `/perfil/seguidores/:id` (perfil de cada seguidor); solo desde el perfil propio | seguidores | Sí |
| Ver publicación | `/publicacion/:id`, sobre la pantalla actual, igual que el detalle del historial | publicacion | No |

## Agregar una página
1. Crear la carpeta en `paginas/`.
2. Crear la página y su controlador.
3. Crear el repositorio, si el dato es nuevo.
4. Registrar la ruta en `rutas/`.
