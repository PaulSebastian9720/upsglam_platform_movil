import 'package:flutter/material.dart';

import '../../../tema/app_theme.dart';

/// Bloques grises con la forma del perfil mientras llega, para que nada salte.
class PerfilCargando extends StatelessWidget {
  const PerfilCargando({super.key, this.conBoton = true});

  /// Reserva el sitio del botón Seguir; en el perfil propio no hay.
  final bool conBoton;

  @override
  Widget build(BuildContext context) {
    final campo = Theme.of(context).colorScheme.surfaceContainerHighest;
    final bloque = BoxDecoration(
      color: campo,
      borderRadius: BorderRadius.circular(AppRadio.base),
    );
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppEspacio.base),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox.square(
                      dimension: AppMedida.avatarPerfil,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: campo,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppEspacio.base),
                    Expanded(
                      child: SizedBox(
                        height: AppMedida.toque,
                        child: DecoratedBox(decoration: bloque),
                      ),
                    ),
                  ],
                ),
                if (conBoton) ...[
                  const SizedBox(height: AppEspacio.base),
                  SizedBox(
                    height: AppMedida.boton,
                    child: DecoratedBox(decoration: bloque),
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverGrid.builder(
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppMedida.separacionCelda,
            crossAxisSpacing: AppMedida.separacionCelda,
            mainAxisExtent: AppMedida.celdaAlto,
          ),
          itemBuilder: (_, _) => ColoredBox(color: campo),
        ),
      ],
    );
  }
}
