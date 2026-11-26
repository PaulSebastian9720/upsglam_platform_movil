import 'package:flutter/material.dart';

import '../../../componentes/app_icono.dart';
import '../../../tema/app_theme.dart';

/// Nombre de usuario centrado arriba, con el botón de ajustes a la derecha.
class TituloPerfil extends StatelessWidget {
  const TituloPerfil({
    super.key,
    required this.titulo,
    required this.alPulsarAjustes,
  });

  final String titulo;
  final VoidCallback alPulsarAjustes;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppEspacio.xs,
      vertical: AppEspacio.s,
    ),
    child: Row(
      children: [
        // Equilibra el botón de la derecha para que el nombre quede al centro.
        const SizedBox(width: AppMedida.toque),
        Expanded(
          child: Text(
            titulo,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          tooltip: 'Ajustes',
          onPressed: alPulsarAjustes,
          icon: const AppIcono(Iconos.ajustes),
        ),
      ],
    ),
  );
}
