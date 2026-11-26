import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:upsglam_movil/componentes/encabezado_pagina.dart';
import 'package:upsglam_movil/componentes/estado_vacio.dart';
import 'package:upsglam_movil/rutas/rutas.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/paginas/seguidores/componentes/fila_seguidor.dart';
import 'package:upsglam_movil/paginas/seguidores/seguidores_controller.dart';

class SeguidoresPage extends StatelessWidget {
  const SeguidoresPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => SeguidoresController(context.read())..cargar(),
    child: const _SeguidoresVista(),
  );
}

class _SeguidoresVista extends StatefulWidget {
  const _SeguidoresVista();

  @override
  State<_SeguidoresVista> createState() => _SeguidoresVistaState();
}

class _SeguidoresVistaState extends State<_SeguidoresVista> {
  late final _control = context.read<SeguidoresController>();
  bool _abriendo = false;

  Future<void> _abrir(String id) async {
    if (_abriendo) return; // un doble toque no lo abre dos veces
    _abriendo = true;
    await context.push(Rutas.seguidor(id));
    _abriendo = false;
    // Pudo seguir o dejar de seguir desde su perfil.
    if (mounted) await _control.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final control = context.watch<SeguidoresController>();
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
              child: EncabezadoPagina(titulo: 'Seguidores'),
            ),
            Expanded(child: _contenido(control)),
          ],
        ),
      ),
    );
  }

  Widget _contenido(SeguidoresController control) {
    final personas = control.personas;
    if (personas == null && control.fallo) {
      return EstadoVacio(
        mensaje: 'No se pudo cargar a tus seguidores',
        accion: 'Reintentar',
        alPulsar: control.cargar,
      );
    }
    if (personas == null) return const _ListaCargando();
    if (personas.isEmpty) {
      return const EstadoVacio(mensaje: 'Aún no te sigue nadie');
    }
    return ListView.builder(
      // Para que el menú flotante no tape lo último.
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      itemCount: personas.length,
      itemBuilder: (_, i) {
        final perfil = personas[i];
        return FilaSeguidor(
          key: ValueKey(perfil.id),
          perfil: perfil,
          alAbrir: () => _abrir(perfil.id),
          alAlternar: () => control.alternar(perfil.id),
        );
      },
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
