import 'package:flutter/material.dart';

import '../../../tema/app_theme.dart';

/// Bloques grises con la forma de una fila mientras llega el historial.
class FilaHistorialCargando extends StatelessWidget {
  const FilaHistorialCargando({super.key});

  @override
  Widget build(BuildContext context) {
    final campo = Theme.of(context).colorScheme.surfaceContainerHighest;
    final miniatura = SizedBox.square(
      dimension: AppMedida.miniatura,
      child: ColoredBox(color: campo),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppEspacio.base,
        vertical: AppEspacio.s,
      ),
      child: Row(
        children: [
          miniatura,
          const SizedBox(width: AppEspacio.s + AppMedida.icono + AppEspacio.s),
          miniatura,
          const SizedBox(width: AppEspacio.m),
          Expanded(
            child: Container(
              height: AppMedida.icono,
              decoration: BoxDecoration(
                color: campo,
                borderRadius: BorderRadius.circular(AppRadio.base),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
