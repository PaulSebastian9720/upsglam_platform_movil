import '../../modelos/usuario/perfil.dart';
import '../../servicios/datos_prueba_service.dart';

/// Única fuente de los perfiles. Hoy lee datos de prueba.
class PerfilRepositorio {
  PerfilRepositorio(this._datos);

  final DatosPruebaService _datos;

  String get miId => DatosPruebaService.yoId;

  Future<Perfil> miPerfil() => perfil(miId);

  Future<Perfil> perfil(String id) async {
    final perfil = _datos.perfiles[id];
    if (perfil == null) throw StateError('No existe el perfil $id');
    return perfil;
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
