import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

/// Acción amarilla de la pantalla. Solo una por pantalla.
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.alPulsar,
    this.cargando = false,
  });

  final String texto;
  final VoidCallback? alPulsar;
  final bool cargando;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: cargando ? null : alPulsar,
    child: cargando
        ? const SizedBox.square(
            dimension: AppMedida.icono,
            child: CircularProgressIndicator(strokeWidth: 3),
          )
        : Text(texto),
  );
}
