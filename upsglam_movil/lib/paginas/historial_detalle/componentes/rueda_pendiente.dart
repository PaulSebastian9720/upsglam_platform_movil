import 'package:flutter/material.dart';

import '../../../componentes/app_icono.dart';
import '../../../modelos/filtro/filtro.dart';
import '../../../tema/app_theme.dart';

/// Rueda de un filtro sin resultado: girando si aún se aplica, con la alerta
/// en rojo si falló. No se puede elegir.
class RuedaPendiente extends StatelessWidget {
  const RuedaPendiente({super.key, required this.filtro, required this.fallo});

  final Filtro filtro;
  final bool fallo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estados = tema.extension<AppEstados>()!;
    final color = fallo ? estados.fallo : tema.colorScheme.onSurfaceVariant;
    return Semantics(
      label: '${filtro.nombre}, ${fallo ? 'falló' : 'aplicando'}',
      excludeSemantics: true,
      child: SizedBox(
        width: AppMedida.rueda + AppEspacio.base,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppMedida.rueda,
              height: AppMedida.rueda,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tema.colorScheme.surfaceContainerHighest,
              ),
              child: fallo
                  ? AppIcono(Iconos.alerta, color: color)
                  : SizedBox.square(
                      dimension: AppMedida.icono,
                      child: CircularProgressIndicator(
                        strokeWidth: AppMedida.bordeRueda,
                        backgroundColor: tema.colorScheme.outline,
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
    );
  }
}
