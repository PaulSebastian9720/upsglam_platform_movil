import 'package:flutter/material.dart';

import '../../../componentes/app_icono.dart';
import '../../../tema/app_theme.dart';

/// Círculo con icono y nombre debajo: galería, filtros y girar.
class ControlCamara extends StatelessWidget {
  const ControlCamara({
    super.key,
    required this.icono,
    required this.texto,
    this.alPulsar,
  });

  final Iconos icono;
  final String texto;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final fondo = tema.scaffoldBackgroundColor;
    return Semantics(
      button: true,
      enabled: alPulsar != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: alPulsar,
        child: SizedBox(
          width: AppMedida.control + AppEspacio.l,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppMedida.control,
                height: AppMedida.control,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: fondo, shape: BoxShape.circle),
                child: AppIcono(
                  icono,
                  color: alPulsar == null ? tema.colorScheme.outline : null,
                ),
              ),
              const SizedBox(height: AppEspacio.xs),
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: fondo,
                  shape: const StadiumBorder(),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppEspacio.s,
                    vertical: AppEspacio.xs,
                  ),
                  child: Text(
                    texto,
                    maxLines: 1,
                    style: tema.textTheme.labelSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
