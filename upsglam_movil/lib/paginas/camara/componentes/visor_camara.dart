import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:upsglam_movil/paginas/camara/componentes/rejilla_camara.dart';

/// Lo que ve la cámara, entero y sin recortes: el cuadro tiene la forma de la
/// foto, así que lo que se ve es exactamente lo que se envía.
class VisorCamara extends StatelessWidget {
  const VisorCamara({super.key, required this.control});

  final CameraController? control;

  @override
  Widget build(BuildContext context) {
    final tamano = control?.value.previewSize;
    if (tamano == null) return const SizedBox.shrink();
    // La cámara informa el tamaño acostado; la app va en vertical.
    return AspectRatio(
      aspectRatio: tamano.shortestSide / tamano.longestSide,
      child: Stack(
        fit: StackFit.expand,
        children: [CameraPreview(control!), const RejillaCamara()],
      ),
    );
  }
}
