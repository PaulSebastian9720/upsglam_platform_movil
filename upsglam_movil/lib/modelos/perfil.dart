import 'autor.dart';

class Perfil {
  const Perfil({
    required this.id,
    required this.usuario,
    this.descripcion = '',
    this.avatar,
    this.publicaciones = 0,
    this.meGusta = 0,
    this.seguidores = 0,
    this.loSigo = false,
  });

  final String id;
  final String usuario;
  final String descripcion;
  final String? avatar;
  final int publicaciones;
  final int meGusta;
  final int seguidores;
  final bool loSigo;

  Autor get autor => Autor(id: id, usuario: usuario, avatar: avatar);

  Perfil copyWith({
    String? usuario,
    String? descripcion,
    int? publicaciones,
    int? seguidores,
    bool? loSigo,
  }) => Perfil(
    id: id,
    usuario: usuario ?? this.usuario,
    descripcion: descripcion ?? this.descripcion,
    avatar: avatar,
    publicaciones: publicaciones ?? this.publicaciones,
    meGusta: meGusta,
    seguidores: seguidores ?? this.seguidores,
    loSigo: loSigo ?? this.loSigo,
  );
}
