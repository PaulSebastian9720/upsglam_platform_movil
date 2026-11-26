import 'package:flutter/material.dart';

import '../tema/app_theme.dart';
import 'app_icono.dart';

/// Icono sobre un círculo, para ponerlo encima de una foto.
class BotonRedondo extends StatelessWidget {
  const BotonRedondo({
    super.key,
    required this.icono,
    required this.descripcion,
    this.alPulsar,
  });

  final Iconos icono;
  final String descripcion;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return IconButton(
      tooltip: descripcion,
      onPressed: alPulsar,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppMedida.toque),
        backgroundColor: tema.scaffoldBackgroundColor,
        disabledBackgroundColor: tema.scaffoldBackgroundColor,
      ),
      icon: AppIcono(
        icono,
        color: alPulsar == null ? tema.colorScheme.outline : null,
      ),
    );
  }
}
