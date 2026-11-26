import 'package:flutter/material.dart';

import 'package:upsglam_movil/tema/app_theme.dart';

class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.mensaje,
    this.accion,
    this.alPulsar,
  });

  final String mensaje;
  final String? accion;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppEspacio.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (accion != null) ...[
            const SizedBox(height: AppEspacio.base),
            OutlinedButton(onPressed: alPulsar, child: Text(accion!)),
          ],
        ],
      ),
    ),
  );
}
