import 'package:flutter/material.dart';

import 'package:upsglam_movil/tema/app_theme.dart';

/// Bloques grises con la forma del formulario mientras llega el perfil.
class FormularioCarga extends StatelessWidget {
  const FormularioCarga({super.key});

  @override
  Widget build(BuildContext context) {
    final campo = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget bloque(double alto) => Container(
      height: alto,
      decoration: BoxDecoration(
        color: campo,
        borderRadius: BorderRadius.circular(AppRadio.base),
      ),
    );
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppEspacio.s),
              child: Container(
                width: AppMedida.avatarEditar,
                height: AppMedida.avatarEditar,
                decoration: BoxDecoration(color: campo, shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(height: AppEspacio.xl),
          bloque(AppMedida.campo),
          const SizedBox(height: AppEspacio.xl),
          bloque(AppMedida.campo * 2),
        ],
      ),
    );
  }
}
