import 'package:flutter/material.dart';

import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/componentes/app_icono.dart';
import 'package:upsglam_movil/componentes/boton_principal.dart';

enum TipoAlerta {
  archivoNoValido(
    'Ese archivo no es una foto JPG, PNG o WEBP',
    Iconos.alertaArchivo,
    'Elegir otra',
  ),
  eliminarPublicacion(
    '¿Eliminar esta publicación?',
    Iconos.eliminar,
    'Eliminar',
    destructiva: true,
  );

  const TipoAlerta(
    this.mensaje,
    this.icono,
    this.accion, {
    this.destructiva = false,
  });

  final String mensaje;
  final Iconos icono;
  final String accion;

  /// La acción va en rojo en vez de amarillo.
  final bool destructiva;
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
            if (tipo.destructiva)
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: tema.colorScheme.errorContainer,
                  foregroundColor: tema.colorScheme.onErrorContainer,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(tipo.accion),
              )
            else
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
