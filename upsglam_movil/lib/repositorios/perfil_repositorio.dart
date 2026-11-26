import '../modelos/perfil.dart';
import '../servicios/datos_prueba_service.dart';

/// Única fuente de los perfiles. Hoy lee datos de prueba.
class PerfilRepositorio {
  PerfilRepositorio(this._datos);

  final DatosPruebaService _datos;

  String get miId => DatosPruebaService.yoId;

  Future<Perfil> miPerfil() => perfil(miId);

  /// El número de publicaciones sale de las que hay: las privadas solo
  /// cuentan en el perfil propio.
  Future<Perfil> perfil(String id) async {
    final perfil = _datos.perfiles[id];
    if (perfil == null) throw StateError('No existe el perfil $id');
    final propio = id == miId;
    final cuantas = _datos.publicaciones
        .where((p) => p.autor.id == id && (propio || !p.privada))
        .length;
    return perfil.copyWith(
      publicaciones: cuantas,
      // En los datos de prueba solo se conocen mis seguidores.
      seguidores: propio ? _datos.meSiguen.length : perfil.seguidores,
    );
  }

  Future<Perfil> actualizar({
    required String usuario,
    required String descripcion,
  }) async {
    final nuevo = _datos.perfiles[miId]!.copyWith(
      usuario: usuario,
      descripcion: descripcion,
    );
    _datos.perfiles[miId] = nuevo;
    return nuevo;
  }
}
