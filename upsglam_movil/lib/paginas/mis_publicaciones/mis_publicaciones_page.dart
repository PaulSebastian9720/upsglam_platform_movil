import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:upsglam_movil/componentes/cuadricula_publicaciones.dart';
import 'package:upsglam_movil/componentes/encabezado_pagina.dart';
import 'package:upsglam_movil/componentes/estado_vacio.dart';
import 'package:upsglam_movil/modelos/publicacion.dart';
import 'package:upsglam_movil/repositorios/perfil_repositorio.dart';
import 'package:upsglam_movil/repositorios/publicaciones_repositorio.dart';
import 'package:upsglam_movil/rutas/rutas.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/paginas/mis_publicaciones/componentes/acciones_celda.dart';
import 'package:upsglam_movil/paginas/mis_publicaciones/componentes/cuadricula_carga.dart';
import 'package:upsglam_movil/paginas/mis_publicaciones/componentes/leyenda_privacidad.dart';
import 'package:upsglam_movil/paginas/mis_publicaciones/mis_publicaciones_controller.dart';

class MisPublicacionesPage extends StatelessWidget {
  const MisPublicacionesPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => MisPublicacionesController(
      context.read<PerfilRepositorio>(),
      context.read<PublicacionesRepositorio>(),
    ),
    child: const _MisPublicacionesVista(),
  );
}

class _MisPublicacionesVista extends StatelessWidget {
  const _MisPublicacionesVista();

  Future<void> _editar(BuildContext context, Publicacion publicacion) async {
    final controlador = context.read<MisPublicacionesController>();
    await context.push(Rutas.editarPublicacion(publicacion.id));
    // Al volver puede haber cambiado el texto, la privacidad o ya no existir.
    if (context.mounted) await controlador.recargar();
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<MisPublicacionesController>();
    final publicaciones = controlador.publicaciones;
    final Widget contenido;
    if (controlador.fallo) {
      contenido = EstadoVacio(
        mensaje: 'No pudimos cargar tus publicaciones',
        accion: 'Reintentar',
        alPulsar: controlador.cargar,
      );
    } else if (publicaciones == null) {
      contenido = const CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [CuadriculaCarga()],
      );
    } else if (publicaciones.isEmpty) {
      contenido = const EstadoVacio(mensaje: 'Aún no tienes publicaciones');
    } else {
      contenido = RefreshIndicator(
        onRefresh: controlador.recargar,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CuadriculaPublicaciones(
              publicaciones: publicaciones,
              alPulsar: (p) => _editar(context, p),
              encima: (p) => AccionesCelda(
                publicacion: p,
                alEditar: () => _editar(context, p),
                alCambiarPrivacidad: () => controlador.alternarPrivacidad(p),
              ),
            ),
            SliverSafeArea(
              top: false,
              sliver: const SliverToBoxAdapter(
                child: SizedBox(height: AppEspacio.base),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppEspacio.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EncabezadoPagina(titulo: 'Mis publicaciones'),
                  SizedBox(height: AppEspacio.m),
                  LeyendaPrivacidad(),
                ],
              ),
            ),
            Expanded(child: contenido),
          ],
        ),
      ),
    );
  }
}
