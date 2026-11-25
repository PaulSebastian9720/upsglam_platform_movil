import 'package:flutter/material.dart';

import '../../tema/app_theme.dart';
import '../app_icono/app_icono.dart';
import '../boton_principal/boton_principal.dart';

enum TipoAlerta {
  archivoNoValido(
    'Ese archivo no es una foto JPG, PNG o WEBP',
    Iconos.alertaArchivo,
    'Elegir otra',
  );

  const TipoAlerta(this.mensaje, this.icono, this.accion);

  final String mensaje;
  final Iconos icono;
  final String accion;
}

/// Única alerta de la app. Nadie más abre diálogos.
class AppAlerta extends StatelessWidget {
  const AppAlerta._(this.tipo);

  final TipoAlerta tipo;

  /// Verdadero si la persona eligió la acción.
  static Future<bool> mostrar(BuildContext context, TipoAlerta tipo) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => AppAlerta._(tipo),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacio.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppEspacio.s),
            AppIcono(
              tipo.icono,
              tamano: AppMedida.iconoAlerta,
              color: tema.colorScheme.error,
            ),
            const SizedBox(height: AppEspacio.m),
            Text(
              tipo.mensaje,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleLarge,
            ),
            const SizedBox(height: AppEspacio.base),
            BotonPrincipal(
              texto: tipo.accion,
              alPulsar: () => Navigator.pop(context, true),
            ),
            const SizedBox(height: AppEspacio.xs),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
