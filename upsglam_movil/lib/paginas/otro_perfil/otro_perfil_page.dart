import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../componentes/boton_principal.dart';
import '../../componentes/boton_secundario.dart';
import '../../componentes/cabecera_perfil.dart';
import '../../componentes/cuadricula_publicaciones.dart';
import '../../componentes/encabezado_pagina.dart';
import '../../componentes/estado_vacio.dart';
import '../../modelos/publicacion.dart';
import '../../rutas/rutas.dart';
import '../../tema/app_theme.dart';
import 'componentes/perfil_cargando.dart';
import 'otro_perfil_controller.dart';

class OtroPerfilPage extends StatelessWidget {
  const OtroPerfilPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) =>
        OtroPerfilController(context.read(), context.read(), context.read(), id)
          ..cargar(),
    child: const _OtroPerfilVista(),
  );
}

class _OtroPerfilVista extends StatefulWidget {
  const _OtroPerfilVista();

  @override
  State<_OtroPerfilVista> createState() => _OtroPerfilVistaState();
}

class _OtroPerfilVistaState extends State<_OtroPerfilVista> {
  late final _control = context.read<OtroPerfilController>();
  bool _abriendo = false;

  Future<void> _abrir(Publicacion publicacion) async {
    if (_abriendo) return; // un doble toque no la abre dos veces
    _abriendo = true;
    await context.push(Rutas.publicacion(publicacion.id));
    _abriendo = false;
    // Pudo cambiar al editarla o al seguir desde otra pantalla.
    if (mounted) await _control.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final control = context.watch<OtroPerfilController>();
    return Scaffold(
      body: SafeArea(
        bottom: false, // el menú flotante ya reserva su espacio
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppEspacio.s,
                AppEspacio.s,
                AppEspacio.base,
                AppEspacio.s,
              ),
              child: EncabezadoPagina(titulo: control.perfil?.usuario ?? ''),
            ),
            Expanded(child: _contenido(control)),
          ],
        ),
      ),
    );
  }

  Widget _contenido(OtroPerfilController control) {
    final perfil = control.perfil;
    if (perfil == null && control.fallo) {
      return EstadoVacio(
        mensaje: 'No se pudo cargar este perfil',
        accion: 'Reintentar',
        alPulsar: control.cargar,
      );
    }
    if (perfil == null) return PerfilCargando(conBoton: !control.esMio);
    return RefreshIndicator(
      onRefresh: control.cargar,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppEspacio.base),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CabeceraPerfil(perfil: perfil, mostrarUsuario: false),
                  if (!control.esMio) ...[
                    const SizedBox(height: AppEspacio.base),
                    perfil.loSigo
                        ? BotonSecundario(
                            texto: 'Dejar de seguir',
                            alPulsar: control.alternarSeguir,
                          )
                        : BotonPrincipal(
                            texto: 'Seguir',
                            alPulsar: control.alternarSeguir,
                          ),
                  ],
                ],
              ),
            ),
          ),
          if (control.publicaciones.isEmpty)
            const SliverToBoxAdapter(
              child: EstadoVacio(mensaje: 'Aún no hay publicaciones'),
            )
          else
            CuadriculaPublicaciones(
              publicaciones: control.publicaciones,
              alPulsar: _abrir,
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    );
  }
}
