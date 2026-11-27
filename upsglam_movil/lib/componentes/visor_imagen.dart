import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/componentes/app_icono.dart';
import 'package:upsglam_movil/componentes/boton_redondo.dart';

/// Zoom estándar: la foto completa a pantalla negra. Pellizcar amplía de 1 a
/// 4, doble toque alterna entre 1 y 2 y, sin zoom, deslizar hacia abajo
/// cierra.
class VisorImagen extends StatefulWidget {
  const VisorImagen._({
    required this.ruta,
    required this.descripcion,
    required this.archivo,
  });

  final String ruta;
  final String descripcion;

  /// La foto está guardada en el teléfono (recién tomada).
  final bool archivo;

  static Future<void> abrir(
    BuildContext context, {
    required String ruta,
    required String descripcion,
    bool archivo = false,
  }) => Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      pageBuilder: (_, animacion, _) => FadeTransition(
        opacity: animacion,
        child: VisorImagen._(
          ruta: ruta,
          descripcion: descripcion,
          archivo: archivo,
        ),
      ),
    ),
  );

  @override
  State<VisorImagen> createState() => _VisorImagenState();
}

class _VisorImagenState extends State<VisorImagen>
    with SingleTickerProviderStateMixin {
  final _zoom = TransformationController();
  late final _vuelta = AnimationController(
    vsync: this,
    duration: kThemeAnimationDuration,
  )..addListener(_alVolver);
  Animation<Matrix4>? _haciaZoom;
  TapDownDetails? _toque;
  double _bajada = 0;

  double get _escala => _zoom.value.getMaxScaleOnAxis();

  @override
  void dispose() {
    _vuelta.dispose();
    _zoom.dispose();
    super.dispose();
  }

  ImageProvider get _origen {
    if (widget.archivo) return FileImage(File(widget.ruta));
    if (widget.ruta.startsWith('assets/')) return AssetImage(widget.ruta);
    // Publicación hecha en este teléfono, mientras no hay servidor.
    if (widget.ruta.startsWith('/')) return FileImage(File(widget.ruta));
    return NetworkImage(widget.ruta);
  }

  void _alVolver() {
    final destino = _haciaZoom;
    if (destino != null) _zoom.value = destino.value;
  }

  void _dobleToque() {
    final punto = _toque?.localPosition ?? Offset.zero;
    final Matrix4 fin;
    if (_escala > 1) {
      fin = Matrix4.identity();
    } else {
      const s = AppMedida.zoomDobleToque;
      // Amplía alrededor del punto tocado.
      fin = Matrix4.identity()
        ..translateByDouble(-punto.dx * (s - 1), -punto.dy * (s - 1), 0, 1)
        ..scaleByDouble(s, s, 1, 1);
    }
    _haciaZoom = Matrix4Tween(
      begin: _zoom.value,
      end: fin,
    ).animate(CurvedAnimation(parent: _vuelta, curve: Curves.easeOut));
    _vuelta.forward(from: 0);
  }

  /// Sin zoom, un dedo que baja arrastra la foto; con zoom, la mueve dentro.
  void _alMover(ScaleUpdateDetails detalle) {
    if (_escala > 1.01 || detalle.pointerCount != 1) return;
    setState(
      () => _bajada = (_bajada + detalle.focalPointDelta.dy).clamp(
        0,
        double.infinity,
      ),
    );
  }

  void _alSoltar(ScaleEndDetails detalle) {
    if (_bajada == 0) return;
    final rapido = detalle.velocity.pixelsPerSecond.dy > kMinFlingVelocity * 10;
    if (_bajada > AppMedida.cerrarZoom || rapido) {
      Navigator.of(context).pop();
    } else {
      setState(() => _bajada = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avance = (_bajada / (AppMedida.cerrarZoom * 2)).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: AppColors.visor.withValues(alpha: 1 - avance),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onDoubleTapDown: (d) => _toque = d,
            onDoubleTap: _dobleToque,
            child: Transform.translate(
              offset: Offset(0, _bajada),
              child: InteractiveViewer(
                transformationController: _zoom,
                minScale: 1,
                maxScale: AppMedida.zoomMaximo,
                panEnabled: true,
                onInteractionUpdate: _alMover,
                onInteractionEnd: _alSoltar,
                child: SizedBox.expand(
                  child: Image(
                    image: _origen,
                    fit: BoxFit.contain, // completa, sin recorte
                    semanticLabel: widget.descripcion,
                    errorBuilder: (_, _, _) => const Center(
                      child: AppIcono(
                        Iconos.alerta,
                        tamano: AppMedida.iconoAlerta,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(AppEspacio.base),
            child: Align(
              alignment: Alignment.topLeft,
              child: BotonRedondo(
                icono: Iconos.cerrar,
                descripcion: 'Cerrar',
                alPulsar: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
