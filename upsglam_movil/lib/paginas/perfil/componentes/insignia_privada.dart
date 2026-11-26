import 'package:flutter/material.dart';

import '../../../componentes/app_icono.dart';
import '../../../tema/app_theme.dart';

/// Círculo con un candado, arriba a la derecha de una foto privada.
class InsigniaPrivada extends StatelessWidget {
  const InsigniaPrivada({super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    // Tocar la insignia abre la foto, como el resto de la celda.
    child: Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(AppEspacio.s),
        child: Semantics(
          label: 'Privada',
          child: Container(
            width: AppMedida.insignia,
            height: AppMedida.insignia,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: const AppIcono(Iconos.privada, tamano: AppEspacio.base),
          ),
        ),
      ),
    ),
  );
}
