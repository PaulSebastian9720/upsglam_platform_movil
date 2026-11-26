import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../componentes/encabezado_pagina.dart';
import '../../componentes/estado_vacio.dart';
import '../../componentes/tarjeta_publicacion.dart';
import '../../rutas/rutas.dart';
import '../../tema/app_theme.dart';
import 'publicacion_controller.dart';

class PublicacionPage extends StatelessWidget {
  const PublicacionPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => PublicacionController(context.read(), id)..cargar(),
    child: const _PublicacionVista(),
  );
}

class _PublicacionVista extends StatefulWidget {
  const _PublicacionVista();

  @override
  State<_PublicacionVista> createState() => _PublicacionVistaState();
}

class _PublicacionVistaState extends State<_PublicacionVista> {
  late final _control = context.read<PublicacionController>();
  void _verAutor(String autorId) => context.push(Rutas.usuario(autorId));

  Future<void> _verComentarios() async {
    await context.push(Rutas.comentarios(_control.id));
    if (mounted) await _control.cargar(); // el número de comentarios cambió
  }

  @override
  Widget build(BuildContext context) {
    final control = context.watch<PublicacionController>();
    return Scaffold(
      body: SafeArea(
        bottom: false, // el menú flotante ya reserva su espacio
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppEspacio.s,
                AppEspacio.s,
                AppEspacio.base,
                AppEspacio.s,
              ),
              child: EncabezadoPagina(titulo: 'Publicación'),
            ),
            Expanded(child: _contenido(control)),
          ],
        ),
      ),
    );
  }

  Widget _contenido(PublicacionController control) {
    final p = control.publicacion;
    if (control.noExiste) {
      return EstadoVacio(
        mensaje: 'Esta publicación ya no está disponible',
        accion: 'Volver',
        alPulsar: () => Navigator.maybePop(context),
      );
    }
    if (p == null && control.fallo) {
      return EstadoVacio(
        mensaje: 'No se pudo cargar la publicación',
        accion: 'Reintentar',
        alPulsar: control.cargar,
      );
    }
    final fin = SizedBox(height: MediaQuery.paddingOf(context).bottom);
    if (p == null) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [const TarjetaPublicacion.cargando(), fin],
      );
    }
    return RefreshIndicator(
      onRefresh: control.cargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          TarjetaPublicacion(
            publicacion: p,
            alPulsarAutor: () => _verAutor(p.autor.id),
            alPulsarMeGusta: control.alternarMeGusta,
            alPulsarComentarios: _verComentarios,
          ),
          fin,
        ],
      ),
    );
  }
}
