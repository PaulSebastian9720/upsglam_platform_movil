import 'dart:io';

import 'package:flutter/material.dart';

import '../../tema/app_theme.dart';
import '../app_icono/app_icono.dart';

/// Foto que llena su marco, recortada al centro y sin esquinas redondas.
class ImagenApp extends StatelessWidget {
  const ImagenApp.archivo(this.ruta, {super.key, required this.descripcion});

  final String ruta;
  final String descripcion;

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
              FileImage(File(ruta)),
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
