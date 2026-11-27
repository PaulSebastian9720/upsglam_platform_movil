import 'package:flutter/material.dart';

import 'package:upsglam_movil/componentes/app_icono.dart';
import 'package:upsglam_movil/tema/app_theme.dart';

/// Opción de la lista de configuración: icono y texto, sin bordes.
class FilaOpcion extends StatelessWidget {
  const FilaOpcion({
    super.key,
    required this.icono,
    required this.texto,
    required this.alPulsar,
    this.valor,
  });

  final Iconos icono;
  final String texto;
  final VoidCallback alPulsar;

  /// Lo elegido ahora, a la derecha; por ejemplo, el tema.
  final String? valor;

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
    trailing: valor == null
        ? null
        : Text(valor!, style: Theme.of(context).textTheme.bodySmall),
  );
}
