import 'package:flutter/material.dart';

import '../../modelos/filtro/filtro.dart';
import '../../tema/app_theme.dart';
import '../rueda_filtro/rueda_filtro.dart';

/// Fila de ruedas con todos los filtros; "Original" va primero.
class SelectorFiltro extends StatelessWidget {
  const SelectorFiltro({
    super.key,
    required this.elegido,
    required this.alElegir,
  });

  final Filtro elegido;
  final ValueChanged<Filtro> alElegir;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: AppEspacio.s),
    child: Row(
      children: [
        for (final filtro in Filtro.values)
          RuedaFiltro(
            filtro: filtro,
            seleccionada: filtro == elegido,
            alPulsar: () => alElegir(filtro),
          ),
      ],
    ),
  );
}
