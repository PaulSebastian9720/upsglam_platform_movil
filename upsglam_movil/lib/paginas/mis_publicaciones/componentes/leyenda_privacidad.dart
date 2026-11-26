import 'package:flutter/material.dart';

import 'package:upsglam_movil/componentes/app_icono.dart';
import 'package:upsglam_movil/tema/app_theme.dart';

/// Explica qué significa cada botón de privacidad de la cuadrícula.
class LeyendaPrivacidad extends StatelessWidget {
  const LeyendaPrivacidad({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    Widget marca(Iconos icono, String texto, Color fondo, Color color) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppMedida.insignia,
          height: AppMedida.insignia,
          decoration: BoxDecoration(color: fondo, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: AppIcono(
            icono,
            tamano: AppMedida.insignia - AppEspacio.s,
            color: color,
          ),
        ),
        const SizedBox(width: AppEspacio.s),
        Text(texto, style: tema.textTheme.labelMedium),
      ],
    );
    return Wrap(
      spacing: AppEspacio.base,
      runSpacing: AppEspacio.s,
      children: [
        marca(
          Iconos.publica,
          'Pública',
          tema.colorScheme.surfaceContainerHighest,
          tema.colorScheme.onSurface,
        ),
        marca(
          Iconos.privada,
          'Privada',
          tema.colorScheme.primary,
          tema.colorScheme.onPrimary,
        ),
      ],
    );
  }
}
