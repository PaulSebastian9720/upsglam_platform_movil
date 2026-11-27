import 'package:upsglam_movil/modelos/autor.dart';

class Perfil {
  const Perfil({
    required this.id,
    required this.usuario,
    this.nombre = '',
    this.correo,
    this.descripcion = '',
    this.avatar,
    this.publicaciones = 0,
    this.meGusta = 0,
    this.seguidores = 0,
    this.loSigo = false,
  });

  final String id;

  /// Único y no se puede cambiar después de crear la cuenta.
  final String usuario;

  /// Nombre completo; se puede editar.
  final String nombre;

  /// Solo viene en el perfil propio; no se puede editar.
  final String? correo;
  final String descripcion;
  final String? avatar;
  final int publicaciones;
  final int meGusta;
  final int seguidores;
  final bool loSigo;

  Autor get autor => Autor(id: id, usuario: usuario, avatar: avatar);

  /// El usuario y el correo no se cambian.
  Perfil copyWith({
    String? nombre,
    String? descripcion,
    int? publicaciones,
    int? seguidores,
    bool? loSigo,
  }) => Perfil(
    id: id,
    usuario: usuario,
    nombre: nombre ?? this.nombre,
    correo: correo,
    descripcion: descripcion ?? this.descripcion,
    avatar: avatar,
    publicaciones: publicaciones ?? this.publicaciones,
    meGusta: meGusta,
    seguidores: seguidores ?? this.seguidores,
    loSigo: loSigo ?? this.loSigo,
  );
}
