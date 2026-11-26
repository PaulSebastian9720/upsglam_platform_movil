/// Lo mínimo de un usuario que acompaña a una publicación o a una lista.
class Autor {
  const Autor({required this.id, required this.usuario, this.avatar});

  final String id;
  final String usuario;

  /// Ruta o URL de la foto; nulo si no tiene.
  final String? avatar;
}
