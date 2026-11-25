import 'package:flutter/material.dart';

import '../../../tema/app_theme.dart';

class BotonDisparo extends StatelessWidget {
  const BotonDisparo({super.key, required this.ocupado, this.alPulsar});

  final bool ocupado;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final fondo = tema.scaffoldBackgroundColor;
    return Semantics(
      button: true,
      enabled: alPulsar != null,
      label: 'Tomar foto',
      child: GestureDetector(
        onTap: alPulsar,
        child: Container(
          width: AppMedida.bola,
          height: AppMedida.bola,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: alPulsar != null || ocupado
                ? tema.colorScheme.primary
                : tema.colorScheme.outline,
            border: Border.all(color: fondo, width: AppMedida.borde),
            boxShadow: [
              BoxShadow(
                color: tema.colorScheme.onSurface,
                spreadRadius: AppEspacio.xs,
              ),
            ],
          ),
          child: ocupado
              ? Padding(
                  padding: const EdgeInsets.all(AppEspacio.l),
                  child: CircularProgressIndicator(color: fondo),
                )
              : null,
        ),
      ),
    );
  }
}
