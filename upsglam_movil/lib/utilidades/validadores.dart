import 'package:flutter/widgets.dart';

abstract final class Validadores {
  static final _correo = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? correo(String? valor) => _correo.hasMatch((valor ?? '').trim())
      ? null
      : 'Escribe un correo válido';

  /// Para entrar solo se exige que haya algo escrito.
  static String? claveObligatoria(String? valor) =>
      (valor ?? '').isEmpty ? 'Escribe tu contraseña' : null;

  static const minimoClave = 8;

  /// Al crear la cuenta la contraseña debe ser segura; se avisa lo primero
  /// que falte.
  static String? claveNueva(String? valor) {
    final clave = valor ?? '';
    if (clave.length < minimoClave) return 'Mínimo $minimoClave caracteres';
    if (!clave.contains(RegExp('[A-Z]'))) return 'Falta una mayúscula';
    if (!clave.contains(RegExp('[a-z]'))) return 'Falta una minúscula';
    if (!clave.contains(RegExp('[0-9]'))) return 'Falta un número';
    if (!clave.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'Falta un carácter especial';
    }
    return null;
  }

  static const maximoNombre = 60;

  /// Nombre completo: obligatorio, hasta 60 caracteres.
  static String? nombre(String? valor) {
    final nombre = (valor ?? '').trim();
    if (nombre.length < 3) return 'Escribe tu nombre completo';
    return _maximo(nombre, maximoNombre);
  }

  /// La segunda contraseña debe ser igual a la primera.
  static FormFieldValidator<String> confirmacion(String Function() original) =>
      (valor) {
        if ((valor ?? '').isEmpty) return 'Vuelve a escribir tu contraseña';
        return valor == original() ? null : 'Las contraseñas no coinciden';
      };

  static const usuarioOcupado = 'Ese usuario ya existe';

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
