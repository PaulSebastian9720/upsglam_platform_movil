abstract final class Validadores {
  static final _correo = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? correo(String? valor) => _correo.hasMatch((valor ?? '').trim())
      ? null
      : 'Escribe un correo válido';

  /// Para entrar solo se exige que haya algo escrito.
  static String? claveObligatoria(String? valor) =>
      (valor ?? '').isEmpty ? 'Escribe tu contraseña' : null;

  static final _usuario = RegExp(r'^[a-zA-Z0-9._]{3,20}$');
  static const maximoDescripcion = 150;
  static const maximoTextoPublicacion = 500;

  static String? usuario(String? valor) =>
      _usuario.hasMatch((valor ?? '').trim())
      ? null
      : 'Usa de 3 a 20 letras, números, punto o _';

  static String? descripcion(String? valor) =>
      _maximo(valor, maximoDescripcion);

  static String? textoPublicacion(String? valor) =>
      _maximo(valor, maximoTextoPublicacion);

  static String? _maximo(String? valor, int maximo) =>
      (valor ?? '').trim().length > maximo ? 'Máximo $maximo caracteres' : null;
}
