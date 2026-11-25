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
  modelos/<modelo>/      usuario, publicacion, comentario, procesamiento, filtro, pagina
  servicios/<servicio>/  sesion, api, cache, guardado, camara, galeria
  repositorios/<dato>/   publicaciones, comentarios, perfil, procesamiento, seguidos, fotos
  componentes/<pieza>/   reutilizables en dos o más páginas
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

- Una clase pública por archivo; carpeta con el mismo nombre; archivos en `snake_case`, clases en `PascalCase`.
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
| Comentarios | hoja sobre Inicio | inicio/componentes | No |
| Cámara y Filtros | `/camara` | camara | No |
| Aplicando, Media, UPS | `/editar` | editar | No |
| Publicar | `/publicar` | publicar | No |
| Perfil | `/perfil` | perfil | Sí |
| Historial (pestaña) | `/perfil/historial` | historial | Sí |
| Historial, lista o falló | `/perfil/historial/:id` | historial_detalle | No |
| Configuración y actividad | `/configuracion` | configuracion | No |
| Editar perfil | `/configuracion/perfil` | editar_perfil | No |
| Mis publicaciones | `/configuracion/publicaciones` | mis_publicaciones | No |
| Editar publicación | `/publicacion/:id/editar` | editar_publicacion | No |
| Perfil de otra persona | `/usuario/:id` | otro_perfil | Sí |
| Seguidos (opcional) | `/perfil/seguidos` | seguidos | No |
| Ver publicación (opcional) | `/publicacion/:id` | publicacion | Sí |

## Agregar una página
1. Carpeta en `paginas/`. 2. Página y controlador. 3. Repositorio, si el dato es nuevo. 4. Ruta en `rutas/`. 5. Revisar con la lista del [README](README.md).
