import 'package:flutter/material.dart';

import 'package:upsglam_movil/componentes/app_icono.dart';
import 'package:upsglam_movil/componentes/imagen_app.dart';
import 'package:upsglam_movil/modelos/procesamiento.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/utilidades/formatos.dart';

/// Original → resultado, filtro, cuándo y en qué estado va.
class FilaHistorial extends StatelessWidget {
  const FilaHistorial({
    super.key,
    required this.procesamiento,
    required this.alPulsar,
  });

  final Procesamiento procesamiento;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estados = tema.extension<AppEstados>()!;
    final p = procesamiento;
    final (texto, color) = switch (p.estado) {
      EstadoProcesamiento.aplicando => ('Aplicando', estados.aplicando),
      EstadoProcesamiento.lista => ('Lista', estados.lista),
      EstadoProcesamiento.fallo => ('Falló', estados.fallo),
    };
    return Semantics(
      button: true,
      label: '${p.filtro.nombre}, $texto',
      excludeSemantics: true,
      child: InkWell(
        onTap: alPulsar,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppEspacio.base,
            vertical: AppEspacio.s,
          ),
          child: Row(
            children: [
              _Miniatura(
                child: ImagenApp.recurso(p.original, descripcion: 'Original'),
              ),
              const SizedBox(width: AppEspacio.s),
              AppIcono(Iconos.flecha, color: tema.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppEspacio.s),
              _Miniatura(child: _resultado(tema, estados)),
              const SizedBox(width: AppEspacio.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.filtro.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleMedium,
                    ),
                    Text(
                      Formatos.hace(p.creado),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppEspacio.s),
              Text(
                texto,
                style: tema.textTheme.labelMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultado(ThemeData tema, AppEstados estados) {
    final resultado = procesamiento.resultado;
    if (procesamiento.estado == EstadoProcesamiento.lista &&
        resultado != null) {
      return ImagenApp.recurso(resultado, descripcion: 'Resultado');
    }
    return ColoredBox(
      color: tema.colorScheme.surfaceContainerHighest,
      child: Center(
        child: procesamiento.estado == EstadoProcesamiento.fallo
            ? AppIcono(Iconos.alerta, color: estados.fallo)
            : SizedBox.square(
                dimension: AppMedida.icono,
                child: CircularProgressIndicator(
                  strokeWidth: AppMedida.bordeRueda,
                  backgroundColor: tema.colorScheme.outline,
                ),
              ),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  const _Miniatura({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: AppMedida.miniatura, child: child);
}
