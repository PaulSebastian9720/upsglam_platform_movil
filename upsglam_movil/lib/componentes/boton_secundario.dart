import 'package:flutter/material.dart';

import '../tema/app_theme.dart';
import 'app_icono.dart';

class BotonSecundario extends StatelessWidget {
  const BotonSecundario({
    super.key,
    required this.texto,
    required this.alPulsar,
    this.icono,
  });

  final String texto;
  final VoidCallback? alPulsar;
  final Iconos? icono;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: alPulsar,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icono != null) ...[
          AppIcono(icono!),
          const SizedBox(width: AppEspacio.m),
        ],
        Flexible(child: Text(texto, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}
