import 'package:flutter/material.dart';

import 'package:upsglam_movil/repositorios/preferencias_repositorio.dart';

/// El tema elegido para toda la app: oscuro, claro o el del sistema.
class TemaController extends ChangeNotifier {
  TemaController(this._preferencias);

  final PreferenciasRepositorio _preferencias;

  ThemeMode _modo = ThemeMode.dark;
  ThemeMode get modo => _modo;

  /// Lee la elección guardada; se llama antes de mostrar la app.
  Future<void> cargar() async {
    _modo = await _preferencias.tema();
    notifyListeners();
  }

  Future<void> elegir(ThemeMode modo) async {
    if (modo == _modo) return;
    _modo = modo;
    notifyListeners();
    await _preferencias.guardarTema(modo);
  }
}
