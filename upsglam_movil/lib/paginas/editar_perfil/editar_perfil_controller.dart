import 'package:flutter/foundation.dart';

import 'package:upsglam_movil/modelos/perfil.dart';
import 'package:upsglam_movil/repositorios/perfil_repositorio.dart';

class EditarPerfilController extends ChangeNotifier {
  EditarPerfilController(this._perfiles) {
    cargar();
  }

  final PerfilRepositorio _perfiles;

  Perfil? _perfil;
  Perfil? get perfil => _perfil;

  bool _cargando = true;
  bool get cargando => _cargando;

  bool _fallo = false;
  bool get fallo => _fallo;

  bool _guardando = false;
  bool get guardando => _guardando;

  bool _cerrado = false;

  Future<void> cargar() async {
    _cargando = true;
    _fallo = false;
    notifyListeners();
    try {
      _perfil = await _perfiles.miPerfil();
    } catch (_) {
      _fallo = true;
    }
    _cargando = false;
    _avisar();
  }

  /// Sin servidor aún: aquí se elegirá la foto de la galería y se subirá.
  void cambiarFoto() {}

  /// Verdadero si se guardó. Un segundo toque mientras guarda no hace nada.
  Future<bool> guardar({
    required String usuario,
    required String descripcion,
  }) async {
    if (_guardando) return false;
    _guardando = true;
    notifyListeners();
    var guardado = true;
    try {
      _perfil = await _perfiles.actualizar(
        usuario: usuario.trim(),
        descripcion: descripcion.trim(),
      );
    } catch (_) {
      guardado = false;
    }
    _guardando = false;
    _avisar();
    return guardado;
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
