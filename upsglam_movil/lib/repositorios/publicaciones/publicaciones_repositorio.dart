import '../../modelos/publicacion/publicacion.dart';
import '../../servicios/datos_prueba_service.dart';

/// Única fuente de las publicaciones. Hoy lee datos de prueba.
class PublicacionesRepositorio {
  PublicacionesRepositorio(this._datos);

  final DatosPruebaService _datos;

  /// De la más nueva a la más antigua. Las privadas solo las ve su autor.
  Future<List<Publicacion>> deUsuario(String usuarioId) async {
    final propias = usuarioId == DatosPruebaService.yoId;
    return _datos.publicaciones
        .where((p) => p.autor.id == usuarioId && (propias || !p.privada))
        .toList()
      ..sort((a, b) => b.creada.compareTo(a.creada));
  }

  /// Inicio: las publicaciones de todos, las sigas o no, de la más nueva a
  /// la más antigua. Las privadas solo las ve su autor.
  Future<List<Publicacion>> inicio() async {
    bool visible(Publicacion p) =>
        p.autor.id == DatosPruebaService.yoId || !p.privada;
    return _datos.publicaciones.where(visible).toList()
      ..sort((a, b) => b.creada.compareTo(a.creada));
  }

  Future<Publicacion> alternarMeGusta(String id) => _cambiar(
    id,
    (p) => p.copyWith(
      meGustaMio: !p.meGustaMio,
      meGusta: p.meGusta + (p.meGustaMio ? -1 : 1),
    ),
  );

  Future<Publicacion> publicacion(String id) async =>
      _datos.publicaciones.firstWhere(
        (p) => p.id == id,
        orElse: () => throw StateError('No existe la publicación $id'),
      );

  Future<Publicacion> editarTexto(String id, String texto) =>
      _cambiar(id, (p) => p.copyWith(texto: texto));

  Future<Publicacion> cambiarPrivacidad(String id, {required bool privada}) =>
      _cambiar(id, (p) => p.copyWith(privada: privada));

  Future<void> eliminar(String id) async =>
      _datos.publicaciones.removeWhere((p) => p.id == id);

  Future<Publicacion> _cambiar(
    String id,
    Publicacion Function(Publicacion) cambio,
  ) async {
    final i = _datos.publicaciones.indexWhere((p) => p.id == id);
    if (i < 0) throw StateError('No existe la publicación $id');
    return _datos.publicaciones[i] = cambio(_datos.publicaciones[i]);
  }
}
