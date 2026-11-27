import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:upsglam_movil/componentes/boton_principal.dart';
import 'package:upsglam_movil/componentes/boton_secundario.dart';
import 'package:upsglam_movil/componentes/cabecera_perfil.dart';
import 'package:upsglam_movil/componentes/cuadricula_publicaciones.dart';
import 'package:upsglam_movil/componentes/encabezado_pagina.dart';
import 'package:upsglam_movil/componentes/estado_vacio.dart';
import 'package:upsglam_movil/modelos/publicacion.dart';
import 'package:upsglam_movil/rutas/rutas.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/paginas/otro_perfil/componentes/perfil_cargando.dart';
import 'package:upsglam_movil/paginas/otro_perfil/otro_perfil_controller.dart';

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
    return CustomScrollView(
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
    );
  }
}
