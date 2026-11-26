import 'package:flutter/material.dart';

import 'package:upsglam_movil/tema/app_theme.dart';

/// Celdas grises con la forma de la cuadrícula mientras llegan las fotos.
class CuadriculaCarga extends StatelessWidget {
  const CuadriculaCarga({super.key});

  static const _celdas = 9;

  @override
  Widget build(BuildContext context) => SliverGrid.builder(
    itemCount: _celdas,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: AppMedida.separacionCelda,
      crossAxisSpacing: AppMedida.separacionCelda,
      mainAxisExtent: AppMedida.celdaAlto,
    ),
    itemBuilder: (context, _) => ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    ),
  );
}
