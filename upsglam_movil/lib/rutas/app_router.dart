import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../componentes/armazon_principal/armazon_principal.dart';
import '../modelos/foto/foto.dart';
import '../paginas/camara/camara_page.dart';
import '../paginas/configuracion/configuracion_page.dart';
import '../paginas/editar/editar_page.dart';
import '../paginas/editar_perfil/editar_perfil_page.dart';
import '../paginas/editar_publicacion/editar_publicacion_page.dart';
import '../paginas/historial/historial_page.dart';
import '../paginas/historial_detalle/historial_detalle_page.dart';
import '../paginas/inicio/inicio_page.dart';
import '../paginas/login/login_page.dart';
import '../paginas/mis_publicaciones/mis_publicaciones_page.dart';
import '../paginas/otro_perfil/otro_perfil_page.dart';
import '../paginas/perfil/perfil_page.dart';
import '../paginas/publicacion/publicacion_page.dart';
import '../paginas/publicar/publicar_page.dart';
import '../paginas/registro/registro_page.dart';
import '../paginas/seguidos/seguidos_page.dart';
import 'rutas.dart';

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

  return GoRouter(
    navigatorKey: raiz,
    initialLocation: Rutas.login,
    routes: [
      sobre(Rutas.login, const LoginPage()),
      sobre(Rutas.registro, const RegistroPage()),
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
                builder: (_, _) => const OtroPerfilPage(),
              ),
              GoRoute(
                path: '/publicacion/:id',
                builder: (_, _) => const PublicacionPage(),
                routes: [sobre('editar', const EditarPublicacionPage())],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rutas.perfil,
                builder: (_, _) => const PerfilPage(),
                routes: [
                  GoRoute(
                    path: 'historial',
                    builder: (_, _) => const HistorialPage(),
                    routes: [sobre(':id', const HistorialDetallePage())],
                  ),
                  sobre('seguidos', const SeguidosPage()),
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
