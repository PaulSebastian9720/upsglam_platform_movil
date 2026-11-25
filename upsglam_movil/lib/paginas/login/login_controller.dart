import 'package:flutter/foundation.dart';

class LoginController extends ChangeNotifier {
  bool _cargando = false;
  bool get cargando => _cargando;

  /// Aún no hay Supabase: siempre deja pasar. Aquí se conectará la sesión.
  Future<bool> entrar() async {
    if (_cargando) return false;
    _cargando = true;
    notifyListeners();
    _cargando = false;
    notifyListeners();
    return true;
  }
}
