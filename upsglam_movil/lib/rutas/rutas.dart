abstract final class Rutas {
  static const login = '/login';
  static const registro = '/registro';
  static const inicio = '/inicio';
  static const perfil = '/perfil';
  static const seguidores = '/perfil/seguidores';
  static const camara = '/camara';
  static const editar = '/editar';
  static const publicar = '/publicar';
  static const configuracion = '/configuracion';
  static const editarPerfil = '/configuracion/perfil';
  static const misPublicaciones = '/configuracion/publicaciones';

  static String historialDetalle(String id) => '/perfil/historial/$id';
  static String usuario(String id) => '/usuario/$id';
  static String seguidor(String id) => '/perfil/seguidores/$id';
  static String publicacion(String id) => '/publicacion/$id';
  static String editarPublicacion(String id) => '/publicacion/$id/editar';
  static String comentarios(String id) => '/publicacion/$id/comentarios';
}
