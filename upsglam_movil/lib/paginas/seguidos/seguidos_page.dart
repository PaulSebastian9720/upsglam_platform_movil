import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../componentes/encabezado_pagina.dart';
import '../../componentes/estado_vacio.dart';
import '../../rutas/rutas.dart';
import '../../tema/app_theme.dart';
import 'componentes/fila_seguido.dart';
import 'seguidos_controller.dart';

class SeguidosPage extends StatelessWidget {
  const SeguidosPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => SeguidosController(context.read())..cargar(),
    child: const _SeguidosVista(),
  );
}

class _SeguidosVista extends StatefulWidget {
  const _SeguidosVista();

  @override
  State<_SeguidosVista> createState() => _SeguidosVistaState();
}

class _SeguidosVistaState extends State<_SeguidosVista> {
  late final _control = context.read<SeguidosController>();
  bool _abriendo = false;

  Future<void> _abrir(String id) async {
    if (_abriendo) return; // un doble toque no lo abre dos veces
    _abriendo = true;
    await context.push(Rutas.usuario(id));
    _abriendo = false;
    // Pudo seguir o dejar de seguir desde su perfil.
    if (mounted) await _control.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final control = context.watch<SeguidosController>();
    return Scaffold(
      body: SafeArea(
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
              child: EncabezadoPagina(titulo: 'Seguidos'),
            ),
            Expanded(child: _contenido(control)),
          ],
        ),
      ),
    );
  }

  Widget _contenido(SeguidosController control) {
    final personas = control.personas;
    if (personas == null && control.fallo) {
      return EstadoVacio(
        mensaje: 'No se pudo cargar a quién sigues',
        accion: 'Reintentar',
        alPulsar: control.cargar,
      );
    }
    if (personas == null) return const _ListaCargando();
    if (personas.isEmpty) {
      return const EstadoVacio(mensaje: 'Aún no sigues a nadie');
    }
    return RefreshIndicator(
      onRefresh: control.cargar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: personas.length,
        itemBuilder: (_, i) {
          final perfil = personas[i];
          return FilaSeguido(
            key: ValueKey(perfil.id),
            perfil: perfil,
            alAbrir: () => _abrir(perfil.id),
            alAlternar: () => control.alternar(perfil.id),
          );
        },
      ),
    );
  }
}

/// Filas grises con la forma final mientras llega la lista.
class _ListaCargando extends StatelessWidget {
  const _ListaCargando();

  @override
  Widget build(BuildContext context) {
    final campo = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppEspacio.base,
          vertical: AppEspacio.s,
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: AppMedida.avatarLista,
              child: DecoratedBox(
                decoration: BoxDecoration(color: campo, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: AppEspacio.m),
            Expanded(
              child: SizedBox(
                height: AppMedida.boton,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: campo,
                    borderRadius: BorderRadius.circular(AppRadio.base),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
