import 'package:flutter/material.dart';

import 'package:upsglam_movil/componentes/app_icono.dart';
import 'package:upsglam_movil/tema/app_theme.dart';

/// Agarradera, título y cerrar. Queda fija arriba y, al arrastrarla, la hoja
/// sube hasta llenar la pantalla o baja hasta cerrarse.
class CabeceraHoja extends SliverPersistentHeaderDelegate {
  const CabeceraHoja({required this.titulo, required this.alCerrar});

  final String titulo;
  final VoidCallback alCerrar;

  static const _alto =
      AppEspacio.m +
      AppMedida.agarraderaAlto +
      AppEspacio.xs +
      AppMedida.toque +
      AppEspacio.xs;

  @override
  double get minExtent => _alto;

  @override
  double get maxExtent => _alto;

  @override
  Widget build(BuildContext context, double desplazado, bool encima) {
    final tema = Theme.of(context);
    return ColoredBox(
      color: tema.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppEspacio.m,
          left: AppEspacio.xs,
          right: AppEspacio.xs,
        ),
        child: Column(
          children: [
            Container(
              width: AppMedida.agarraderaAncho,
              height: AppMedida.agarraderaAlto,
              decoration: BoxDecoration(
                color: tema.colorScheme.outline,
                borderRadius: BorderRadius.circular(AppMedida.agarraderaAlto),
              ),
            ),
            const SizedBox(height: AppEspacio.xs),
            Row(
              children: [
                // Equilibra el botón de cerrar para que el título quede al
                // centro.
                const SizedBox(width: AppMedida.toque),
                Expanded(
                  child: Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar comentarios',
                  onPressed: alCerrar,
                  icon: AppIcono(
                    Iconos.cerrar,
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(CabeceraHoja anterior) => anterior.titulo != titulo;
}
