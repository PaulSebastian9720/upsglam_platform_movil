import 'dart:io';

import 'package:flutter/material.dart';

import '../tema/app_theme.dart';
import 'app_icono.dart';

/// Foto que llena su marco, recortada al centro y sin esquinas redondas.
class ImagenApp extends StatelessWidget {
  /// Foto guardada en el teléfono, como la recién tomada.
  const ImagenApp.archivo(this.ruta, {super.key, required this.descripcion})
    : _archivo = true;

  /// Foto de una publicación o de un perfil: un asset de prueba hoy, una URL
  /// del servidor mañana.
  const ImagenApp.recurso(this.ruta, {super.key, required this.descripcion})
    : _archivo = false;

  final String ruta;
  final bool _archivo;
  final String descripcion;

  ImageProvider _origen() {
    if (_archivo) return FileImage(File(ruta));
    if (ruta.startsWith('assets/')) return AssetImage(ruta);
    return NetworkImage(ruta);
  }

  @override
  Widget build(BuildContext context) {
    final campo = Theme.of(context).colorScheme.surfaceContainerHighest;
    return LayoutBuilder(
      builder: (context, marco) {
        // Se decodifica al tamaño del marco, con margen para el recorte.
        final lado =
            (marco.maxWidth + marco.maxHeight) *
            MediaQuery.devicePixelRatioOf(context);
        return ColoredBox(
          color: campo,
          child: Image(
            image: ResizeImage(
              _origen(),
              width: lado.round(),
              height: lado.round(),
              policy: ResizeImagePolicy.fit,
            ),
            width: marco.maxWidth,
            height: marco.maxHeight,
            fit: BoxFit.cover,
            semanticLabel: descripcion,
            errorBuilder: (_, _, _) => const Center(
              child: AppIcono(Iconos.alerta, tamano: AppMedida.iconoAlerta),
            ),
          ),
        );
      },
    );
  }
}
