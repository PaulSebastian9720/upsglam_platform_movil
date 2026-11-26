import 'package:flutter/foundation.dart';

import '../../modelos/publicacion/publicacion.dart';
import '../../modelos/usuario/perfil.dart';
import '../../repositorios/perfil/perfil_repositorio.dart';
import '../../repositorios/publicaciones/publicaciones_repositorio.dart';

class PerfilController extends ChangeNotifier {
  PerfilController(this._perfiles, this._publicaciones) {
    cargar();
  }

  final PerfilRepositorio _perfiles;
  final PublicacionesRepositorio _publicaciones;

  Perfil? _perfil;
  List<Publicacion> _lista = const [];
  bool _cargando = false;
  bool _fallo = false;
  bool _viva = true;

  Perfil? get perfil => _perfil;
  List<Publicacion> get publicaciones => _lista;
  bool get cargando => _cargando;

  /// Solo cuenta si no hay nada que mostrar; si ya había datos, se conservan.
  bool get fallo => _fallo && _perfil == null;

  /// Solo las fotos, sin tocar la cabecera.
  Future<void> cargarPublicaciones() async {
    final perfil = _perfil;
    if (perfil == null) return cargar();
    try {
      final lista = await _publicaciones.deUsuario(perfil.id);
      _cambiar(() => _lista = lista);
    } catch (_) {
      // Se conserva lo que había.
    }
  }

  /// Al recargar se mantiene lo que había mientras llega lo nuevo.
  Future<void> cargar() async {
    if (_cargando) return;
    _cambiar(() {
      _cargando = true;
      _fallo = false;
    });
    try {
      final perfil = await _perfiles.miPerfil();
      final lista = await _publicaciones.deUsuario(perfil.id);
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
