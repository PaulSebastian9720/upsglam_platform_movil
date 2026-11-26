import '../modelos/perfil.dart';
import '../servicios/datos_prueba_service.dart';

/// Única fuente de a quién sigo. Hoy lee datos de prueba.
class SeguidosRepositorio {
  SeguidosRepositorio(this._datos);

  final DatosPruebaService _datos;

  /// Las personas que sigo, por nombre de usuario.
  Future<List<Perfil>> seguidos() async =>
      _datos.perfiles.values.where((p) => p.loSigo).toList()
        ..sort((a, b) => a.usuario.compareTo(b.usuario));

  /// Las personas que me siguen, por nombre de usuario.
  Future<List<Perfil>> seguidores() async =>
      [for (final id in _datos.meSiguen) ?_datos.perfiles[id]]
        ..sort((a, b) => a.usuario.compareTo(b.usuario));

  Future<Perfil> seguir(String id) => _cambiar(id, seguir: true);

  Future<Perfil> dejarDeSeguir(String id) => _cambiar(id, seguir: false);

  Future<Perfil> _cambiar(String id, {required bool seguir}) async {
    final actual = _datos.perfiles[id];
    if (actual == null) throw StateError('No existe el perfil $id');
    if (actual.loSigo == seguir) return actual;
    return _datos.perfiles[id] = actual.copyWith(
      loSigo: seguir,
      seguidores: actual.seguidores + (seguir ? 1 : -1),
    );
  }
}
