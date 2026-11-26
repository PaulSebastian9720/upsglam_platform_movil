import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:upsglam_movil/componentes/zoom_en_sitio.dart';
import 'package:upsglam_movil/componentes/app_icono.dart';
import 'package:upsglam_movil/componentes/boton_principal.dart';
import 'package:upsglam_movil/componentes/boton_secundario.dart';
import 'package:upsglam_movil/componentes/encabezado_pagina.dart';
import 'package:upsglam_movil/componentes/estado_vacio.dart';
import 'package:upsglam_movil/componentes/imagen_app.dart';
import 'package:upsglam_movil/componentes/rueda_filtro.dart';
import 'package:upsglam_movil/modelos/filtro.dart';
import 'package:upsglam_movil/modelos/procesamiento.dart';
import 'package:upsglam_movil/rutas/rutas.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/utilidades/formatos.dart';
import 'package:upsglam_movil/paginas/historial_detalle/componentes/rueda_pendiente.dart';
import 'package:upsglam_movil/paginas/historial_detalle/historial_detalle_controller.dart';

class HistorialDetallePage extends StatelessWidget {
  const HistorialDetallePage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => HistorialDetalleController(context.read(), id),
    child: const _HistorialDetalleVista(),
  );
}

class _HistorialDetalleVista extends StatelessWidget {
  const _HistorialDetalleVista();

  @override
  Widget build(BuildContext context) {
    final detalle = context.watch<HistorialDetalleController>();
    final p = detalle.procesamiento;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppEspacio.xs,
                AppEspacio.s,
                AppEspacio.base,
                AppEspacio.s,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: EncabezadoPagina(titulo: p?.filtro.nombre ?? ''),
                  ),
                  if (p != null) _Estado(p),
                ],
              ),
            ),
            Expanded(
              child: detalle.fallo
                  ? EstadoVacio(
                      mensaje: 'No se pudo abrir este filtro',
                      accion: 'Reintentar',
                      alPulsar: detalle.cargar,
                    )
                  : _Cuerpo(detalle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado y fecha, a la derecha del título.
class _Estado extends StatelessWidget {
  const _Estado(this.procesamiento);

  final Procesamiento procesamiento;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estados = tema.extension<AppEstados>()!;
    final (texto, color) = switch (procesamiento.estado) {
      EstadoProcesamiento.aplicando => ('Aplicando', estados.aplicando),
      EstadoProcesamiento.lista => ('Lista', estados.lista),
      EstadoProcesamiento.fallo => ('Falló', estados.fallo),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(texto, style: tema.textTheme.labelMedium?.copyWith(color: color)),
        Text(
          Formatos.hace(procesamiento.creado),
          style: tema.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Cuerpo extends StatelessWidget {
  const _Cuerpo(this.detalle);

  final HistorialDetalleController detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final p = detalle.procesamiento;
    final foto = detalle.foto;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          // Publicación: todo el ancho, 5:6. El hueco existe antes de cargar.
          child: AspectRatio(
            aspectRatio: AppMedida.proporcionPublicacion,
            child: foto == null
                ? ColoredBox(color: tema.colorScheme.surfaceContainerHighest)
                : ZoomEnSitio(
                    child: ImagenApp.recurso(
                      foto,
                      descripcion: detalle.viendoOriginal
                          ? 'Foto original'
                          : 'Resultado con ${p!.filtro.nombre}',
                    ),
                  ),
          ),
        ),
        if (p != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(AppEspacio.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ruedas(context, p),
                  const Spacer(),
                  const SizedBox(height: AppEspacio.base),
                  ..._botones(context, p),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _ruedas(BuildContext context, Procesamiento p) {
    final tema = Theme.of(context);
    return Row(
      children: [
        RuedaFiltro(
          filtro: Filtro.original,
          seleccionada: detalle.viendoOriginal,
          alPulsar: detalle.verOriginal,
        ),
        const SizedBox(width: AppEspacio.s),
        if (detalle.lista)
          RuedaFiltro(
            filtro: p.filtro,
            seleccionada: !detalle.viendoOriginal,
            alPulsar: detalle.verResultado,
          )
        else
          RuedaPendiente(
            filtro: p.filtro,
            fallo: p.estado == EstadoProcesamiento.fallo,
          ),
        if (p.estado == EstadoProcesamiento.fallo) ...[
          const SizedBox(width: AppEspacio.m),
          Expanded(
            child: Text(
              'No se pudo aplicar. Tu foto sigue aquí.',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _botones(BuildContext context, Procesamiento p) =>
      switch (p.estado) {
        EstadoProcesamiento.lista => [
          Row(
            children: [
              Expanded(
                child: BotonSecundario(
                  texto: 'Guardar',
                  icono: Iconos.guardar,
                  alPulsar: detalle.guardar,
                ),
              ),
              const SizedBox(width: AppEspacio.m),
              Expanded(
                child: BotonPrincipal(
                  texto: 'Publicar',
                  alPulsar: () => context.push(Rutas.publicar),
                ),
              ),
            ],
          ),
        ],
        EstadoProcesamiento.fallo => [
          BotonPrincipal(texto: 'Reintentar', alPulsar: detalle.reintentar),
        ],
        EstadoProcesamiento.aplicando => const [],
      };
}
