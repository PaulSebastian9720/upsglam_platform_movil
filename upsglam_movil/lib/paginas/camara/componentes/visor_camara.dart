import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Lo que ve la cámara, a pantalla completa y sin deformarse.
class VisorCamara extends StatelessWidget {
  const VisorCamara({super.key, required this.control});

  final CameraController? control;

  @override
  Widget build(BuildContext context) {
    final tamano = control?.value.previewSize;
    if (tamano == null) return const SizedBox.shrink();
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        // La cámara informa el tamaño acostado; la app va en vertical.
        child: SizedBox(
          width: tamano.shortestSide,
          height: tamano.longestSide,
          child: CameraPreview(control!),
        ),
      ),
    );
  }
}
