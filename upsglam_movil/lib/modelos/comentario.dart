import 'package:upsglam_movil/modelos/autor.dart';

class Comentario {
  const Comentario({
    required this.id,
    required this.publicacionId,
    required this.autor,
    required this.texto,
    required this.creado,
  });

  final String id;
  final String publicacionId;
  final Autor autor;
  final String texto;
  final DateTime creado;
}
