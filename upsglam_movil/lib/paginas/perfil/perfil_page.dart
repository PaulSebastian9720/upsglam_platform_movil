import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../componentes/cabecera_perfil.dart';
import '../../modelos/procesamiento/procesamiento.dart';
import '../../componentes/cuadricula_publicaciones.dart';
import '../../componentes/estado_vacio.dart';
import '../../rutas/rutas.dart';
import '../../tema/app_theme.dart';
import 'componentes/cabecera_cargando.dart';
import 'componentes/fila_historial.dart';
import 'componentes/fila_historial_cargando.dart';
import 'componentes/insignia_privada.dart';
import 'componentes/barra_pestanas.dart';
import 'componentes/titulo_perfil.dart';
import 'historial_controller.dart';
import 'perfil_controller.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => PerfilController(context.read(), context.read()),
      ),
      ChangeNotifierProvider(
        create: (_) => HistorialController(context.read()),
      ),
    ],
    child: const _PerfilVista(),
  );
}

class _PerfilVista extends StatefulWidget {
  const _PerfilVista();

  @override
  State<_PerfilVista> createState() => _PerfilVistaState();
}

class _PerfilVistaState extends State<_PerfilVista>
    with SingleTickerProviderStateMixin {
  late final _pestanas = TabController(length: 2, vsync: this)
    ..addListener(_alCambiarPestana);

  @override
  void dispose() {
    _pestanas.dispose();
    super.dispose();
  }

  /// Al llegar a una pestaña, con el dedo o tocándola, solo se recarga lo
  /// de esa pestaña; la cabecera se queda como está.
  void _alCambiarPestana() {
    if (_pestanas.indexIsChanging) return;
    if (_pestanas.index == 0) {
      context.read<PerfilController>().cargarPublicaciones();
    } else {
      context.read<HistorialController>().cargar();
    }
  }

  /// Configuración y la publicación pueden cambiar el perfil o la lista.
  Future<void> _abrir(String ruta) async {
    final perfil = context.read<PerfilController>();
    await context.push(ruta);
    if (mounted) await perfil.cargar();
  }

  /// El detalle puede cambiar el historial; la cabecera no.
  Future<void> _abrirDetalle(String ruta) async {
    final historial = context.read<HistorialController>();
    await context.push(ruta);
    if (mounted) await historial.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilController>();
    final datos = perfil.perfil;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: perfil.fallo
            ? EstadoVacio(
                mensaje: 'No se pudo cargar tu perfil',
                accion: 'Reintentar',
                alPulsar: perfil.cargar,
              )
            : GestureDetector(
                // Sobre la cabecera también se cambia de pestaña deslizando:
                // de derecha a izquierda va a Historial y al revés vuelve.
                onHorizontalDragEnd: _deslizar,
                child: NestedScrollView(
                  headerSliverBuilder: (context, _) => [
                    SliverToBoxAdapter(
                      child: TituloPerfil(
                        titulo: datos?.usuario ?? '',
                        alPulsarAjustes: () => _abrir(Rutas.configuracion),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppEspacio.base,
                        AppEspacio.xs,
                        AppEspacio.base,
                        AppEspacio.base,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: datos == null
                            ? const CabeceraCargando()
                            : CabeceraPerfil(
                                perfil: datos,
                                mostrarUsuario: false,
                                alPulsarSeguidores: () =>
                                    _abrir(Rutas.seguidores),
                              ),
                      ),
                    ),
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                      sliver: SliverPersistentHeader(
                        pinned: true,
                        delegate: BarraPestanas(
                          TabBar(
                            controller: _pestanas,
                            tabs: const [
                              Tab(text: 'Publicaciones'),
                              Tab(text: 'Historial'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Se pasa de una pestaña a otra arrastrando con el dedo.
                  body: TabBarView(
                    controller: _pestanas,
                    children: [
                      _Pestana(
                        nombre: 'publicaciones',
                        contenido: _publicaciones(perfil),
                      ),
                      _Pestana(
                        nombre: 'historial',
                        contenido: _historial(context),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _deslizar(DragEndDetails fin) {
    final velocidad = fin.primaryVelocity ?? 0;
    if (velocidad.abs() < kMinFlingVelocity) return;
    final destino = velocidad < 0 ? 1 : 0;
    if (destino != _pestanas.index) _pestanas.animateTo(destino);
  }

  List<Widget> _publicaciones(PerfilController perfil) => [
    const SliverToBoxAdapter(
      child: SizedBox(height: AppMedida.separacionCelda),
    ),
    if (perfil.perfil == null)
      const _CuadriculaCargando()
    else if (perfil.publicaciones.isEmpty)
      SliverFillRemaining(
        hasScrollBody: false,
        child: EstadoVacio(
          mensaje: 'Aún no tienes publicaciones',
          accion: 'Tomar una foto',
          alPulsar: () => context.push(Rutas.camara),
        ),
      )
    else
      CuadriculaPublicaciones(
        publicaciones: perfil.publicaciones,
        alPulsar: (p) => _abrir(Rutas.publicacion(p.id)),
        encima: (p) =>
            p.privada ? const InsigniaPrivada() : const SizedBox.shrink(),
      ),
  ];

  List<Widget> _historial(BuildContext context) {
    final historial = context.watch<HistorialController>();
    final List<Procesamiento>? lista = historial.historial;
    return [
      const SliverToBoxAdapter(child: SizedBox(height: AppEspacio.s)),
      if (historial.fallo)
        SliverFillRemaining(
          hasScrollBody: false,
          child: EstadoVacio(
            mensaje: 'No se pudo cargar tu historial',
            accion: 'Reintentar',
            alPulsar: historial.cargar,
          ),
        )
      else if (lista == null)
        SliverList.builder(
          itemCount: 4,
          itemBuilder: (_, _) => const FilaHistorialCargando(),
        )
      else if (lista.isEmpty)
        const SliverFillRemaining(
          hasScrollBody: false,
          child: EstadoVacio(
            mensaje: 'Aquí verás las fotos a las que les pongas un filtro',
          ),
        )
      else
        SliverList.builder(
          itemCount: lista.length,
          itemBuilder: (context, i) => FilaHistorial(
            procesamiento: lista[i],
            alPulsar: () => _abrirDetalle(Rutas.historialDetalle(lista[i].id)),
          ),
        ),
    ];
  }
}

/// Contenido de una pestaña: se desplaza por su cuenta bajo las pestañas
/// fijas. No se actualiza deslizando: ya se recarga al volver o al cambiar
/// de pestaña.
class _Pestana extends StatelessWidget {
  const _Pestana({required this.nombre, required this.contenido});

  final String nombre;
  final List<Widget> contenido;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    // Cada pestaña recuerda hasta dónde se bajó.
    key: PageStorageKey(nombre),
    slivers: [
      SliverOverlapInjector(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      ),
      ...contenido,
      SliverToBoxAdapter(
        // Para que el menú flotante no tape lo último.
        child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
      ),
    ],
  );
}

/// Celdas grises con la forma de la cuadrícula mientras cargan las fotos.
class _CuadriculaCargando extends StatelessWidget {
  const _CuadriculaCargando();

  @override
  Widget build(BuildContext context) => SliverGrid.builder(
    itemCount: 6,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: AppMedida.separacionCelda,
      crossAxisSpacing: AppMedida.separacionCelda,
      mainAxisExtent: AppMedida.celdaAlto,
    ),
    itemBuilder: (context, _) => ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    ),
  );
}
