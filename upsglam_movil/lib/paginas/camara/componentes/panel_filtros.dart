import 'package:flutter/material.dart';

import '../../../componentes/app_icono.dart';
import '../../../componentes/selector_filtro.dart';
import '../../../modelos/filtro/filtro.dart';
import '../../../tema/app_theme.dart';

class PanelFiltros extends StatelessWidget {
  const PanelFiltros({
    super.key,
    required this.elegido,
    required this.alElegir,
    required this.alCerrar,
  });

  final Filtro elegido;
  final ValueChanged<Filtro> alElegir;
  final VoidCallback alCerrar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Material(
      color: tema.scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(AppRadio.hoja),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppEspacio.m),
                child: SelectorFiltro(elegido: elegido, alElegir: alElegir),
              ),
            ),
            Material(
              color: tema.colorScheme.surface,
              child: IconButton(
                tooltip: 'Cerrar filtros',
                onPressed: alCerrar,
                icon: const AppIcono(Iconos.adelante),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
