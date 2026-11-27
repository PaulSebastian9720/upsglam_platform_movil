import 'package:flutter/material.dart';

import 'package:upsglam_movil/componentes/app_icono.dart';
import 'package:upsglam_movil/tema/app_theme.dart';

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
      // Se ve más pequeño, pero se sigue tocando en un área de 48.
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppMedida.botonCelda),
        minimumSize: const Size.square(AppMedida.botonCelda),
        tapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: activo
            ? tema.colorScheme.primary
            : tema.scaffoldBackgroundColor,
      ),
      icon: AppIcono(
        icono,
        tamano: AppMedida.iconoCelda,
        color: activo ? tema.colorScheme.onPrimary : tema.colorScheme.onSurface,
      ),
    );
  }
}
