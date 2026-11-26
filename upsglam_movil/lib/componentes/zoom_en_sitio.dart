import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

/// Zoom sobre la misma foto: con dos dedos crece ahí mismo, por encima de
/// todo, y al soltar vuelve a su lugar. Con un dedo la lista se desplaza
/// como siempre.
class ZoomEnSitio extends StatefulWidget {
  const ZoomEnSitio({super.key, required this.child});

  final Widget child;

  @override
  State<ZoomEnSitio> createState() => _ZoomEnSitioState();
}

class _ZoomEnSitioState extends State<ZoomEnSitio>
    with SingleTickerProviderStateMixin {
  final _dedos = <int, Offset>{};
  OverlayEntry? _capa;
  ScrollHoldController? _freno; // detiene la lista mientras se amplía
  Rect _marco = Rect.zero;
  Offset _focoInicial = Offset.zero;
  double _distanciaInicial = 1;
  double _escala = 1;
  Offset _mover = Offset.zero;

  late final _vuelta = AnimationController(
    vsync: this,
    duration: kThemeAnimationDuration,
  );
  double _escalaAlSoltar = 1;
  Offset _moverAlSoltar = Offset.zero;

  @override
  void initState() {
    super.initState();
    _vuelta
      ..addListener(_alVolver)
      ..addStatusListener((estado) {
        if (estado == AnimationStatus.completed) _terminar();
      });
  }

  @override
  void dispose() {
    _terminar();
    _vuelta.dispose();
    super.dispose();
  }

  (Offset, double) get _focoYDistancia {
    final puntos = _dedos.values.take(2).toList();
    return (
      (puntos[0] + puntos[1]) / 2,
      (puntos[0] - puntos[1]).distance.clamp(1, double.infinity),
    );
  }

  void _empezar() {
    final caja = context.findRenderObject() as RenderBox?;
    if (caja == null || !caja.hasSize) return;
    _vuelta.stop();
    _marco = caja.localToGlobal(Offset.zero) & caja.size;
    final (foco, distancia) = _focoYDistancia;
    _focoInicial = foco;
    _distanciaInicial = distancia;
    _escala = 1;
    _mover = Offset.zero;
    _freno = Scrollable.maybeOf(context)?.position.hold(() {});
    _capa = OverlayEntry(builder: _dibujarCapa);
    Overlay.of(context, rootOverlay: true).insert(_capa!);
    setState(() {}); // oculta la original mientras la copia crece
  }

  void _actualizar() {
    final (foco, distancia) = _focoYDistancia;
    _escala = (distancia / _distanciaInicial).clamp(1, AppMedida.zoomMaximo);
    _mover = foco - _focoInicial;
    _capa?.markNeedsBuild();
  }

  void _soltar() {
    _escalaAlSoltar = _escala;
    _moverAlSoltar = _mover;
    _vuelta.forward(from: 0);
  }

  void _alVolver() {
    final t = Curves.easeOut.transform(_vuelta.value);
    _escala = _escalaAlSoltar + (1 - _escalaAlSoltar) * t;
    _mover = Offset.lerp(_moverAlSoltar, Offset.zero, t)!;
    _capa?.markNeedsBuild();
  }

  void _terminar() {
    _capa?.remove();
    _capa = null;
    _freno?.cancel();
    _freno = null;
    if (mounted) setState(() {});
  }

  Widget _dibujarCapa(BuildContext context) {
    final velo = Theme.of(context).colorScheme.scrim;
    final oscuro = ((_escala - 1) / (AppMedida.zoomDobleToque - 1)).clamp(
      0.0,
      1.0,
    );
    final foco = _focoInicial - _marco.topLeft;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(color: velo.withValues(alpha: velo.a * oscuro)),
          ),
        ),
        Positioned.fromRect(
          rect: _marco,
          child: IgnorePointer(
            child: Transform(
              // Crece alrededor del punto entre los dedos y lo sigue.
              transform: Matrix4.identity()
                ..translateByDouble(
                  _mover.dx + foco.dx,
                  _mover.dy + foco.dy,
                  0,
                  1,
                )
                ..scaleByDouble(_escala, _escala, 1, 1)
                ..translateByDouble(-foco.dx, -foco.dy, 0, 1),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (e) {
      _dedos[e.pointer] = e.position;
      if (_dedos.length == 2 && _capa == null) _empezar();
    },
    onPointerMove: (e) {
      _dedos[e.pointer] = e.position;
      if (_capa != null && _dedos.length >= 2 && !_vuelta.isAnimating) {
        _actualizar();
      }
    },
    onPointerUp: (e) => _quitarDedo(e.pointer),
    onPointerCancel: (e) => _quitarDedo(e.pointer),
    child: Opacity(opacity: _capa == null ? 1 : 0, child: widget.child),
  );

  void _quitarDedo(int dedo) {
    _dedos.remove(dedo);
    if (_capa != null && _dedos.length < 2 && !_vuelta.isAnimating) {
      _soltar();
    }
  }
}
