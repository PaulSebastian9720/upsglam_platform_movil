import 'package:flutter/material.dart';

/// Tercios para encuadrar.
class RejillaCamara extends StatelessWidget {
  const RejillaCamara({super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(
      painter: _Tercios(Theme.of(context).colorScheme.onSurface),
    ),
  );
}

class _Tercios extends CustomPainter {
  const _Tercios(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final trazo = Paint()..color = color.withValues(alpha: 0.4);
    for (final tercio in const [1 / 3, 2 / 3]) {
      final x = size.width * tercio;
      final y = size.height * tercio;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), trazo);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), trazo);
    }
  }

  @override
  bool shouldRepaint(_Tercios otro) => otro.color != color;
}
