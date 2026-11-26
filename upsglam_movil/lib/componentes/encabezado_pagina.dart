import 'package:flutter/material.dart';

import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/componentes/app_icono.dart';

class EncabezadoPagina extends StatelessWidget {
  const EncabezadoPagina({super.key, required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'Volver',
        onPressed: () => Navigator.maybePop(context),
        icon: const AppIcono(Iconos.atras),
      ),
      const SizedBox(width: AppEspacio.s),
      Expanded(
        child: Text(
          titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    ],
  );
}
