import 'package:flutter/foundation.dart';

import 'package:upsglam_movil/modelos/publicacion.dart';
import 'package:upsglam_movil/repositorios/publicaciones_repositorio.dart';

class EditarPublicacionController extends ChangeNotifier {
  EditarPublicacionController(this._publicaciones, this.id) {
    cargar();
  }

  final PublicacionesRepositorio _publicaciones;
  final String id;

  Publicacion? _publicacion;
  Publicacion? get publicacion => _publicacion;

  bool _fallo = false;
  bool get fallo => _fallo;

  bool _privada = false;

  /// Lo elegido en el interruptor; se guarda junto con el texto.
  bool get privada => _privada;

  bool _guardando = false;
  bool get guardando => _guardando;

  bool _eliminando = false;
  bool get eliminando => _eliminando;

  /// Mientras guarda o elimina, ningún botón responde.
  bool get ocupado => _guardando || _eliminando;

  bool _cerrado = false;

  Future<void> cargar() async {
    _fallo = false;
    notifyListeners();
    try {
      final publicacion = await _publicaciones.publicacion(id);
      _publicacion = publicacion;
      _privada = publicacion.privada;
    } catch (_) {
      _fallo = true;
    }
    _avisar();
  }

  void cambiarPrivada(bool valor) {
    if (ocupado) return;
    _privada = valor;
    notifyListeners();
  }

  /// Verdadero si se guardó. Un segundo toque mientras guarda no hace nada.
  Future<bool> guardar(String texto) async {
    final actual = _publicacion;
    if (actual == null || ocupado) return false;
    _guardando = true;
    notifyListeners();
    var guardado = true;
    try {
      final limpio = texto.trim();
      if (limpio != actual.texto) {
        _publicacion = await _publicaciones.editarTexto(id, limpio);
      }
      if (_privada != actual.privada) {
        _publicacion = await _publicaciones.cambiarPrivacidad(
          id,
          privada: _privada,
        );
      }
    } catch (_) {
      guardado = false;
    }
    _guardando = false;
    _avisar();
    return guardado;
  }

  /// Verdadero si se eliminó.
  Future<bool> eliminar() async {
    if (_publicacion == null || ocupado) return false;
    _eliminando = true;
    notifyListeners();
    var eliminada = true;
    try {
      await _publicaciones.eliminar(id);
    } catch (_) {
      eliminada = false;
    }
    _eliminando = false;
    _avisar();
    return eliminada;
  }

  // Pendiente de pasar a utilidades/validadores.dart.

  void _avisar() {
    if (!_cerrado) notifyListeners();
  }

  @override
  void dispose() {
    _cerrado = true;
    super.dispose();
  }
}
