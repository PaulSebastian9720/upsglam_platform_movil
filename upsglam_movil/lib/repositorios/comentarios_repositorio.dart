import '../modelos/comentario.dart';
import '../servicios/datos_prueba_service.dart';

/// Única fuente de los comentarios. Hoy lee datos de prueba.
class ComentariosRepositorio {
  ComentariosRepositorio(this._datos);

  final DatosPruebaService _datos;

  /// Del más antiguo al más nuevo: el último queda junto al campo de escribir.
  Future<List<Comentario>> dePublicacion(String publicacionId) async =>
      _datos.comentarios.where((c) => c.publicacionId == publicacionId).toList()
        ..sort((a, b) => a.creado.compareTo(b.creado));

  Future<Comentario> comentar(String publicacionId, String texto) async {
    final comentario = Comentario(
      id: _datos.nuevoId('c'),
      publicacionId: publicacionId,
      autor: _datos.perfiles[DatosPruebaService.yoId]!.autor,
      texto: texto.trim(),
      creado: DateTime.now(),
    );
    _datos.comentarios.add(comentario);
    final i = _datos.publicaciones.indexWhere((p) => p.id == publicacionId);
    if (i >= 0) {
      final p = _datos.publicaciones[i];
      _datos.publicaciones[i] = p.copyWith(comentarios: p.comentarios + 1);
    }
    return comentario;
  }
}
