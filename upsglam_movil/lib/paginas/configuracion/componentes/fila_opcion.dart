import 'package:flutter/material.dart';

import '../../../componentes/app_icono.dart';
import '../../../tema/app_theme.dart';

/// Opción de la lista de configuración: icono y texto, sin bordes.
class FilaOpcion extends StatelessWidget {
  const FilaOpcion({
    super.key,
    required this.icono,
    required this.texto,
    required this.alPulsar,
  });

  final Iconos icono;
  final String texto;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: alPulsar,
    minTileHeight: AppMedida.toque,
    contentPadding: const EdgeInsets.symmetric(horizontal: AppEspacio.base),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadio.base),
    ),
    leading: AppIcono(icono),
    title: Text(texto, style: Theme.of(context).textTheme.titleMedium),
  );
}
