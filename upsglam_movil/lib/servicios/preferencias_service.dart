import 'package:shared_preferences/shared_preferences.dart';

/// Envuelve las preferencias sueltas guardadas en el teléfono. Nunca tokens.
class PreferenciasService {
  Future<String?> leer(String clave) async {
    try {
      return (await SharedPreferences.getInstance()).getString(clave);
    } catch (_) {
      return null; // sin almacenamiento disponible se usa lo de siempre
    }
  }

  Future<void> guardar(String clave, String valor) async {
    try {
      await (await SharedPreferences.getInstance()).setString(clave, valor);
    } catch (_) {
      // Si no se puede guardar, la elección vale solo hasta cerrar la app.
    }
  }
}
