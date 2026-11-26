# Estructura

Basada en la guía oficial: capa de interfaz (vista y modelo de vista) y capa de datos (repositorio y servicio)
([guía](https://docs.flutter.dev/app-architecture/guide), [recomendaciones](https://docs.flutter.dev/app-architecture/recommendations)).
**Decisión del proyecto, por ser pequeña:** carpetas por página, sin capa de dominio, y los nombres en español.

```
lib/
  main.dart              arranque
  app.dart               MaterialApp, tema y proveedores
  config/                direcciones y claves públicas del entorno
  tema/                  app_theme.dart, único
  rutas/                 navegación
  modelos/               un archivo por modelo: perfil, autor, publicacion, comentario, procesamiento, filtro, foto
  servicios/             un archivo por servicio: camara, galeria (luego sesion, api, cache)
  repositorios/          un archivo por dato: publicaciones, comentarios, perfil, procesamiento, seguidos, fotos
  componentes/           un archivo por pieza reutilizable en dos o más páginas
  paginas/<pagina>/      la página, su controlador y sus piezas propias
  utilidades/            validadores y formatos
assets/  logo/ iconos/ iconos_aplicacion/ imagenes/filtros/ imagenes/login/ fuentes/
```

## Cada clase
| Tipo | Archivo | Hace | No hace |
|---|---|---|---|
| Página | `inicio_page.dart` | Dibuja | Lógica, red, caché |
| Controlador | `inicio_controller.dart` | Estado de la página (`ChangeNotifier`) | Dibujar, navegar por su cuenta |
| Repositorio | `publicaciones_repositorio.dart` | Única fuente del dato; decide caché o red | Conocer widgets u otros repositorios |
| Servicio | `api_service.dart` | Envuelve una sola cosa externa, sin estado de pantalla | Decidir qué se muestra |
| Modelo | `publicacion.dart` | Datos inmutables | Llamar a nada |

- Una clase pública por archivo. `componentes/`, `servicios/`, `modelos/` y `repositorios/` llevan los archivos sueltos; solo las páginas van en carpeta con su nombre; archivos en `snake_case`, clases en `PascalCase`.
- Imports siempre absolutos desde la raíz del paquete: `import 'package:upsglam_movil/tema/app_theme.dart';`. Nunca rutas relativas (`../`). Lo exige el analizador (`always_use_package_imports`).
- Dependencias por `provider` (lo recomienda la guía). Sin variables globales ni singletons sueltos.
- La dependencia va en un sentido: página → controlador → repositorio → servicio.

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
| Cámara y Filtros | `/camara` | camara | No |
| Aplicando, Media, UPS | `/editar` | editar | No |
| Publicar | `/publicar` | publicar | No |
| Perfil | `/perfil` | perfil | Sí |
| Historial (pestaña) | Pestaña dentro de `/perfil`, sin ruta propia | perfil | Sí |
| Historial, lista o falló | `/perfil/historial/:id` | historial_detalle | No |
| Configuración y actividad | `/configuracion` | configuracion | No |
| Editar perfil | `/configuracion/perfil` | editar_perfil | No |
| Mis publicaciones | `/configuracion/publicaciones` | mis_publicaciones | No |
| Editar publicación | `/publicacion/:id/editar` | editar_publicacion | No |
| Perfil de otra persona | `/usuario/:id` | otro_perfil | Sí |
| Seguidores | `/perfil/seguidores` y `/perfil/seguidores/:id` (perfil de cada uno), solo desde el perfil propio | seguidores | Sí |
| Ver publicación | `/publicacion/:id`, encima, como el detalle del historial | publicacion | No |

## Agregar una página
1. Carpeta en `paginas/`. 2. Página y controlador. 3. Repositorio, si el dato es nuevo. 4. Ruta en `rutas/`. 5. Revisar con la lista del [README](README.md).
