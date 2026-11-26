import '../filtro/filtro.dart';
import '../usuario/autor.dart';

class Publicacion {
  const Publicacion({
    required this.id,
    required this.autor,
    required this.imagen,
    required this.filtro,
    required this.creada,
    this.texto = '',
    this.meGusta = 0,
    this.meGustaMio = false,
    this.comentarios = 0,
    this.privada = false,
  });

  final String id;
  final Autor autor;

  /// Ruta o URL de la foto ya filtrada.
  final String imagen;
  final Filtro filtro;
  final DateTime creada;
  final String texto;
  final int meGusta;
  final bool meGustaMio;
  final int comentarios;
  final bool privada;

  Publicacion copyWith({
    String? texto,
    bool? privada,
    int? meGusta,
    bool? meGustaMio,
    int? comentarios,
  }) => Publicacion(
    id: id,
    autor: autor,
    imagen: imagen,
    filtro: filtro,
    creada: creada,
    texto: texto ?? this.texto,
    meGusta: meGusta ?? this.meGusta,
    meGustaMio: meGustaMio ?? this.meGustaMio,
    comentarios: comentarios ?? this.comentarios,
    privada: privada ?? this.privada,
  );
}
