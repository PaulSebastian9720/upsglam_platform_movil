import 'package:flutter/material.dart';

import '../modelos/filtro.dart';
import '../tema/app_theme.dart';

class RuedaFiltro extends StatelessWidget {
  const RuedaFiltro({
    super.key,
    required this.filtro,
    required this.seleccionada,
    required this.alPulsar,
  });

  final Filtro filtro;
  final bool seleccionada;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = seleccionada ? tema.colorScheme.primary : null;
    return Semantics(
      button: true,
      selected: seleccionada,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: alPulsar,
        child: SizedBox(
          width: AppMedida.rueda + AppEspacio.base,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppMedida.rueda,
                height: AppMedida.rueda,
                padding: const EdgeInsets.all(AppMedida.bordeRueda),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color ?? tema.scaffoldBackgroundColor,
                ),
                child: ClipOval(
                  child: Image.asset(
                    filtro.muestra,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              const SizedBox(height: AppEspacio.xs),
              Text(
                filtro.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
