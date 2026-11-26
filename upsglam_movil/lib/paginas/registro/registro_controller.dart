import 'package:flutter/foundation.dart';

class RegistroController extends ChangeNotifier {
  bool _cargando = false;
  bool get cargando => _cargando;

  /// Aún no hay Supabase: siempre deja pasar. Aquí se creará la cuenta.
  Future<bool> crear() async {
    if (_cargando) return false;
    _cargando = true;
    notifyListeners();
    _cargando = false;
    notifyListeners();
    return true;
  }
}
