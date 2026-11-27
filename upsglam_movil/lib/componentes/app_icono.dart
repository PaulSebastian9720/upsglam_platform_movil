import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:upsglam_movil/tema/app_theme.dart';

/// Únicos iconos permitidos; los archivos están en assets/iconos.
enum Iconos {
  inicio,
  inicioActivo('inicio_activo'),
  perfil,
  perfilActivo('perfil_activo'),
  atras,
  adelante,
  cerrar,
  camara,
  galeria,
  girar,
  filtros,
  flash,
  flashApagado('flash_apagado'),
  alerta,
  alertaArchivo('alerta_archivo'),
  ajustes,
  tema,
  publicaciones,
  publica,
  privada,
  editar,
  eliminar,
  guardar,
  flecha,
  mas,
  comentario,
  enviar,
  meGusta('me_gusta'),
  meGustaActivo('me_gusta_activo'),
  verClave('ver_clave'),
  ocultarClave('ocultar_clave');

  const Iconos([this._archivo]);

  final String? _archivo;

  String get ruta => 'assets/iconos/${_archivo ?? name}.svg';

  /// Filtros conserva sus colores.
  bool get conservaColor => this == filtros;
}

class AppIcono extends StatelessWidget {
  const AppIcono(
    this.icono, {
    super.key,
    this.tamano = AppMedida.icono,
    this.color,
  });

  final Iconos icono;
  final double tamano;
  final Color? color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    icono.ruta,
    width: tamano,
    height: tamano,
    excludeFromSemantics: true,
    colorFilter: icono.conservaColor
        ? null
        : ColorFilter.mode(
            color ?? Theme.of(context).colorScheme.onSurface,
            BlendMode.srcIn,
          ),
  );
}
