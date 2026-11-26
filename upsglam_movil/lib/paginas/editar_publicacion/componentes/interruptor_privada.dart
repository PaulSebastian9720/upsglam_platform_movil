import 'package:flutter/material.dart';

import '../../../tema/app_theme.dart';

/// Fila con el interruptor "Publicación privada".
class InterruptorPrivada extends StatelessWidget {
  const InterruptorPrivada({
    super.key,
    required this.privada,
    required this.alCambiar,
  });

  final bool privada;
  final ValueChanged<bool>? alCambiar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return SwitchListTile(
      value: privada,
      onChanged: alCambiar,
      tileColor: tema.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppEspacio.base),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadio.base),
      ),
      title: Text('Publicación privada', style: tema.textTheme.titleMedium),
      subtitle: Text('Solo la ves tú', style: tema.textTheme.bodySmall),
    );
  }
}
