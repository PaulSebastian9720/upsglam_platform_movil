import 'package:flutter/foundation.dart';

import 'package:upsglam_movil/repositorios/perfil_repositorio.dart';

enum ResultadoRegistro { creada, usuarioOcupado, fallo }

class RegistroController extends ChangeNotifier {
  RegistroController(this._perfiles);

  final PerfilRepositorio _perfiles;

  bool _cargando = false;
  bool get cargando => _cargando;

  /// Aún no hay Supabase: comprueba que el usuario no exista y deja pasar.
  /// Aquí se creará la cuenta con nombre, usuario, correo y contraseña.
  Future<ResultadoRegistro?> crear({required String usuario}) async {
    if (_cargando) return null; // un doble toque no envía dos veces
    _cargando = true;
    notifyListeners();
    try {
      final libre = await _perfiles.usuarioDisponible(usuario);
      return libre
          ? ResultadoRegistro.creada
          : ResultadoRegistro.usuarioOcupado;
    } catch (_) {
      return ResultadoRegistro.fallo;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
