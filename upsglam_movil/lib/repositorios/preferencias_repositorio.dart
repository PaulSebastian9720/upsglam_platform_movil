import 'package:flutter/material.dart';

import 'package:upsglam_movil/servicios/preferencias_service.dart';

/// Única fuente de las preferencias de la app, como el tema.
class PreferenciasRepositorio {
  PreferenciasRepositorio(this._preferencias);

  final PreferenciasService _preferencias;

  static const _tema = 'tema';

  /// Oscuro si nunca se eligió otro.
  Future<ThemeMode> tema() async => switch (await _preferencias.leer(_tema)) {
    'claro' => ThemeMode.light,
    'sistema' => ThemeMode.system,
    _ => ThemeMode.dark,
  };

  Future<void> guardarTema(ThemeMode modo) =>
      _preferencias.guardar(_tema, switch (modo) {
        ThemeMode.light => 'claro',
        ThemeMode.system => 'sistema',
        ThemeMode.dark => 'oscuro',
      });
}
