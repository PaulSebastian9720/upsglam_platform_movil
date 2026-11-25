abstract final class Validadores {
  static final _correo = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? correo(String? valor) => _correo.hasMatch((valor ?? '').trim())
      ? null
      : 'Escribe un correo válido';

  /// Para entrar solo se exige que haya algo escrito.
  static String? claveObligatoria(String? valor) =>
      (valor ?? '').isEmpty ? 'Escribe tu contraseña' : null;
}
