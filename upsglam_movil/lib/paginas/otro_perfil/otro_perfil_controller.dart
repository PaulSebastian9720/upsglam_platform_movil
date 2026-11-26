import 'package:flutter/foundation.dart';

import '../../modelos/publicacion/publicacion.dart';
import '../../modelos/usuario/perfil.dart';
import '../../repositorios/perfil/perfil_repositorio.dart';
import '../../repositorios/publicaciones/publicaciones_repositorio.dart';
import '../../repositorios/seguidos/seguidos_repositorio.dart';

class OtroPerfilController extends ChangeNotifier {
  OtroPerfilController(
    this._perfiles,
    this._publicaciones,
    this._seguidos,
    this.id,
  );

  final PerfilRepositorio _perfiles;
  final PublicacionesRepositorio _publicaciones;
  final SeguidosRepositorio _seguidos;
  final String id;

  Perfil? _perfil;
  List<Publicacion> _lista = const [];
  bool _cargando = false;
  bool _fallo = false;
  bool _enviando = false;
  bool _viva = true;

  /// Nulo mientras llega por primera vez.
  Perfil? get perfil => _perfil;

  /// Las privadas ya vienen filtradas por el repositorio.
  List<Publicacion> get publicaciones => _lista;
  bool get cargando => _cargando;
  bool get fallo => _fallo;

  /// Uno no se sigue a sí mismo.
  bool get esMio => id == _perfiles.miId;

  /// Al recargar se mantiene lo que había mientras llega lo nuevo.
  Future<void> cargar() async {
    if (_cargando) return;
    _cambiar(() {
      _cargando = true;
      _fallo = false;
    });
    try {
      final (perfil, lista) = await (
        _perfiles.perfil(id),
        _publicaciones.deUsuario(id),
      ).wait;
      _cambiar(() {
        _perfil = perfil;
        _lista = lista;
      });
    } catch (_) {
      _cambiar(() => _fallo = true);
    } finally {
      _cambiar(() => _cargando = false);
    }
  }

  /// Cambia al instante y se deshace si no se pudo guardar.
  Future<void> alternarSeguir() async {
    final antes = _perfil;
    if (antes == null || esMio || _enviando) return;
    _enviando = true;
    final seguir = !antes.loSigo;
    _cambiar(
      () => _perfil = antes.copyWith(
        loSigo: seguir,
        seguidores: antes.seguidores + (seguir ? 1 : -1),
      ),
    );
    try {
      final nuevo = seguir
          ? await _seguidos.seguir(id)
          : await _seguidos.dejarDeSeguir(id);
      _cambiar(() => _perfil = nuevo);
    } catch (_) {
      _cambiar(() => _perfil = antes);
    } finally {
      _enviando = false;
    }
  }

  void _cambiar(VoidCallback cambio) {
    cambio();
    if (_viva) notifyListeners();
  }

  @override
  void dispose() {
    _viva = false;
    super.dispose();
  }
}
