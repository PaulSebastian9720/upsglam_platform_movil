import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:upsglam_movil/componentes/armazon_principal.dart';
import 'package:upsglam_movil/modelos/foto.dart';
import 'package:upsglam_movil/paginas/camara/camara_page.dart';
import 'package:upsglam_movil/paginas/comentarios/comentarios_page.dart';
import 'package:upsglam_movil/paginas/configuracion/configuracion_page.dart';
import 'package:upsglam_movil/paginas/editar/editar_page.dart';
import 'package:upsglam_movil/paginas/editar_perfil/editar_perfil_page.dart';
import 'package:upsglam_movil/paginas/editar_publicacion/editar_publicacion_page.dart';
import 'package:upsglam_movil/paginas/historial_detalle/historial_detalle_page.dart';
import 'package:upsglam_movil/paginas/inicio/inicio_page.dart';
import 'package:upsglam_movil/paginas/login/login_page.dart';
import 'package:upsglam_movil/paginas/mis_publicaciones/mis_publicaciones_page.dart';
import 'package:upsglam_movil/paginas/otro_perfil/otro_perfil_page.dart';
import 'package:upsglam_movil/paginas/perfil/perfil_page.dart';
import 'package:upsglam_movil/paginas/publicacion/publicacion_page.dart';
import 'package:upsglam_movil/paginas/publicar/publicar_page.dart';
import 'package:upsglam_movil/paginas/registro/registro_page.dart';
import 'package:upsglam_movil/paginas/seguidores/seguidores_page.dart';
import 'package:upsglam_movil/rutas/pagina_hoja.dart';
import 'package:upsglam_movil/rutas/rutas.dart';

/// Crea las rutas. Las pestañas viven dentro del armazón, con menú; el resto
/// se abre en el navegador raíz, por encima y sin menú.
GoRouter crearRouter() {
  final raiz = GlobalKey<NavigatorState>();

  GoRoute sobre(
    String ruta,
    Widget pagina, [
    List<RouteBase> hijas = const [],
  ]) => GoRoute(
    path: ruta,
    parentNavigatorKey: raiz,
    builder: (_, _) => pagina,
    routes: hijas,
  );

  String id(GoRouterState estado) => estado.pathParameters['id']!;

  return GoRouter(
    navigatorKey: raiz,
    initialLocation: Rutas.login,
    routes: [
      sobre(Rutas.login, const LoginPage()),
      sobre(Rutas.registro, const RegistroPage()),
      // Comentarios y editar van sueltos y antes, para que ganen a
      // /publicacion/:id y no apilen la publicación debajo.
      GoRoute(
        path: '/publicacion/:id/comentarios',
        parentNavigatorKey: raiz,
        pageBuilder: (_, estado) =>
            PaginaHoja(child: ComentariosPage(id: id(estado))),
      ),
      GoRoute(
        path: '/publicacion/:id/editar',
        parentNavigatorKey: raiz,
        builder: (_, estado) => EditarPublicacionPage(id: id(estado)),
      ),
      // Ver publicación se abre encima, como el detalle del historial, desde
      // cualquier pestaña y sin cambiarla.
      GoRoute(
        path: '/publicacion/:id',
        parentNavigatorKey: raiz,
        builder: (_, estado) => PublicacionPage(id: id(estado)),
      ),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: raiz,
        builder: (_, _, pestanas) => ArmazonPrincipal(pestanas: pestanas),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rutas.inicio,
                builder: (_, _) => const InicioPage(),
              ),
              GoRoute(
                path: '/usuario/:id',
                builder: (_, estado) => OtroPerfilPage(id: id(estado)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rutas.perfil,
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: PerfilPage()),
                routes: [
                  // Historial es una pestaña dentro de Perfil; solo su
                  // detalle tiene ruta propia, encima y sin menú.
                  GoRoute(
                    path: 'historial/:id',
                    parentNavigatorKey: raiz,
                    builder: (_, estado) =>
                        HistorialDetallePage(id: id(estado)),
                  ),
                  // Dentro de la pestaña: la lista y el perfil de cada
                  // seguidor se abren con el menú y Atrás vuelve a la lista.
                  GoRoute(
                    path: 'seguidores',
                    builder: (_, _) => const SeguidoresPage(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (_, estado) => OtroPerfilPage(id: id(estado)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      sobre(Rutas.camara, const CamaraPage()),
      GoRoute(
        path: Rutas.editar,
        parentNavigatorKey: raiz,
        // Sin foto no hay nada que editar.
        redirect: (_, estado) => estado.extra is Foto ? null : Rutas.inicio,
        builder: (_, estado) => EditarPage(foto: estado.extra! as Foto),
      ),
      sobre(Rutas.publicar, const PublicarPage()),
      sobre(Rutas.configuracion, const ConfiguracionPage(), [
        sobre('perfil', const EditarPerfilPage()),
        sobre('publicaciones', const MisPublicacionesPage()),
      ]),
    ],
  );
}
