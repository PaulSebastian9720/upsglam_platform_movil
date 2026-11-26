import 'package:flutter/material.dart';

import '../../../componentes/app_icono.dart';
import '../../../tema/app_theme.dart';

/// Botón redondo sobre una foto de la cuadrícula. Activo va en amarillo.
class BotonCelda extends StatelessWidget {
  const BotonCelda({
    super.key,
    required this.icono,
    required this.descripcion,
    required this.alPulsar,
    this.activo = false,
  });

  final Iconos icono;
  final String descripcion;
  final VoidCallback alPulsar;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return IconButton(
      tooltip: descripcion,
      onPressed: alPulsar,
      isSelected: activo,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppMedida.toque),
        minimumSize: const Size.square(AppMedida.toque),
        backgroundColor: activo
            ? tema.colorScheme.primary
            : tema.scaffoldBackgroundColor,
      ),
      icon: AppIcono(
        icono,
        color: activo ? tema.colorScheme.onPrimary : tema.colorScheme.onSurface,
      ),
    );
  }
}
