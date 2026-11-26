import 'package:flutter/material.dart';

import '../../../tema/app_theme.dart';

/// Bloques grises con la forma de la cabecera mientras llega el perfil.
class CabeceraCargando extends StatelessWidget {
  const CabeceraCargando({super.key});

  @override
  Widget build(BuildContext context) {
    final campo = Theme.of(context).colorScheme.surfaceContainerHighest;
    final bloque = BoxDecoration(
      color: campo,
      borderRadius: BorderRadius.circular(AppRadio.base),
    );
    return Row(
      children: [
        Container(
          width: AppMedida.avatarPerfil,
          height: AppMedida.avatarPerfil,
          decoration: BoxDecoration(shape: BoxShape.circle, color: campo),
        ),
        const SizedBox(width: AppEspacio.base),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Container(height: AppMedida.toque, decoration: bloque)],
          ),
        ),
      ],
    );
  }
}
