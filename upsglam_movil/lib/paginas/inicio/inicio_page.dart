import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../componentes/estado_vacio.dart';
import '../../componentes/tarjeta_publicacion.dart';
import '../../modelos/publicacion.dart';
import '../../rutas/rutas.dart';
import '../../tema/app_theme.dart';
import 'inicio_controller.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) =>
        InicioController(context.read(), context.read(), context.read()),
    child: const _InicioVista(),
  );
}

class _InicioVista extends StatelessWidget {
  const _InicioVista();

  Future<void> _comentarios(BuildContext context, Publicacion p) async {
    final inicio = context.read<InicioController>();
    await context.push(Rutas.comentarios(p.id));
    await inicio.actualizar(p.id); // el número de comentarios cambió
  }

  /// Editar o ver otro perfil puede cambiar la lista.
  Future<void> _abrir(BuildContext context, String ruta) async {
    final inicio = context.read<InicioController>();
    await context.push(ruta);
    await inicio.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final inicio = context.watch<InicioController>();
    final lista = inicio.publicaciones;
    final tema = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppEspacio.base,
                  vertical: AppEspacio.s,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'UPSGlam',
                        style: tema.textTheme.headlineMedium,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/logo/logo_negro.svg',
                      width: AppMedida.logoInicio,
                      semanticsLabel: 'UPSGlam',
                    ),
                  ],
                ),
              ),
            ),
            if (inicio.fallo)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EstadoVacio(
                  mensaje: 'No se pudieron cargar las publicaciones',
                  accion: 'Reintentar',
                  alPulsar: inicio.cargar,
                ),
              )
            else if (lista == null)
              SliverList.separated(
                itemCount: 2,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppEspacio.l),
                itemBuilder: (_, _) => const TarjetaPublicacion.cargando(),
              )
            else if (lista.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EstadoVacio(
                  mensaje: 'Aún no hay publicaciones. Comparte la primera.',
                  accion: 'Tomar una foto',
                  alPulsar: () => context.push(Rutas.camara),
                ),
              )
            else
              // Se construyen solo las que se ven.
              SliverList.separated(
                itemCount: lista.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppEspacio.l),
                itemBuilder: (context, i) {
                  final p = lista[i];
                  return TarjetaPublicacion(
                    publicacion: p,
                    // Lo mío lleva a la pestaña Perfil; lo de otros, a su perfil.
                    alPulsarAutor: inicio.esMia(p)
                        ? () => context.go(Rutas.perfil)
                        : () => _abrir(context, Rutas.usuario(p.autor.id)),
                    loSigo: inicio.loSigo(p),
                    alPulsarSeguir: () => inicio.seguir(p.autor.id),
                    alPulsarMeGusta: () => inicio.alternarMeGusta(p),
                    alPulsarComentarios: () => _comentarios(context, p),
                  );
                },
              ),
            SliverToBoxAdapter(
              // Para que el menú flotante no tape lo último.
              child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
            ),
          ],
        ),
      ),
    );
  }
}
