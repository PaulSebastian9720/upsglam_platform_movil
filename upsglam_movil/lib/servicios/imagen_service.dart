import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Deja la foto lista para enviar: WEBP, calidad 85 y lado mayor de
/// [ladoMaximo] px como máximo, sin agrandar las pequeñas.
class ImagenService {
  static const ladoMaximo = 2560;
  static const calidad = 85;

  /// Ruta del WEBP nuevo junto a la original, o nulo si no se pudo convertir.
  Future<String?> optimizar(String ruta) async {
    final destino = '${ruta.replaceFirst(RegExp(r'\.[^./]*$'), '')}_lista.webp';
    // La biblioteca reduce hasta que un lado llegue al mínimo pedido. Pidiendo
    // el lado corto final en los dos ejes, el resultado no depende de si la
    // foto viene girada.
    final corto = await _ladoCortoFinal(ruta);
    final hecho = await FlutterImageCompress.compressAndGetFile(
      ruta,
      destino,
      minWidth: corto,
      minHeight: corto,
      quality: calidad,
      format: CompressFormat.webp,
    );
    return hecho?.path;
  }

  Future<int> _ladoCortoFinal(String ruta) async {
    try {
      final datos = await ui.ImmutableBuffer.fromFilePath(ruta);
      final foto = await ui.ImageDescriptor.encoded(datos);
      final (corto, largo) = (
        min(foto.width, foto.height),
        max(foto.width, foto.height),
      );
      foto.dispose();
      datos.dispose();
      if (largo <= ladoMaximo) return corto;
      return (corto * ladoMaximo / largo).round();
    } on Exception {
      // Formato que Flutter no lee (HEIC en algunos Android): se asume 3:4.
      return ladoMaximo * 3 ~/ 4;
    }
  }
}
