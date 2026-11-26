import 'package:flutter/foundation.dart';

import '../../modelos/publicacion/publicacion.dart';
import '../../repositorios/perfil/perfil_repositorio.dart';
import '../../repositorios/publicaciones/publicaciones_repositorio.dart';
import '../../repositorios/seguidos/seguidos_repositorio.dart';

class InicioController extends ChangeNotifier {
  InicioController(this._publicaciones, this._perfil, this._seguidos) {
    cargar();
  }

  final PublicacionesRepositorio _publicaciones;
  final PerfilRepositorio _perfil;
  final SeguidosRepositorio _seguidos;

  Set<String> _sigo = const {};

  List<Publicacion>? _lista;
  bool _fallo = false;
  bool _cargando = false;
  bool _viva = true;

  /// Nula mientras llega la primera vez.
  List<Publicacion>? get publicaciones => _lista;
  bool get fallo => _fallo && _lista == null;

  bool esMia(Publicacion publicacion) => publicacion.autor.id == _perfil.miId;

  /// Nulo en las mías; así la tarjeta no muestra Seguir ni Siguiendo.
  bool? loSigo(Publicacion publicacion) =>
      esMia(publicacion) ? null : _sigo.contains(publicacion.autor.id);

  /// Se ve al instante en todas sus publicaciones; si falla, se deshace.
  Future<void> seguir(String autorId) async {
    if (_sigo.contains(autorId)) return; // un doble toque no envía dos veces
    _cambiar(() => _sigo = {..._sigo, autorId});
    try {
      await _seguidos.seguir(autorId);
    } catch (_) {
      _cambiar(() => _sigo = {..._sigo}..remove(autorId));
    }
  }

  /// Al recargar se mantiene lo que había mientras llega lo nuevo.
  Future<void> cargar() async {
    if (_cargando) return;
    _cargando = true;
    _cambiar(() => _fallo = false);
    try {
      final lista = await _publicaciones.inicio();
      final sigo = await _seguidos.seguidos();
      _cambiar(() {
        _lista = lista;
        _sigo = {for (final p in sigo) p.id};
      });
    } catch (_) {
      _cambiar(() => _fallo = true);
    } finally {
      _cargando = false;
    }
  }

  /// Se ve al instante; si no se guarda, vuelve a como estaba.
  Future<void> alternarMeGusta(Publicacion publicacion) async {
    final antes = publicacion;
    _reemplazar(
      antes.copyWith(
        meGustaMio: !antes.meGustaMio,
        meGusta: antes.meGusta + (antes.meGustaMio ? -1 : 1),
      ),
    );
    try {
      _reemplazar(await _publicaciones.alternarMeGusta(antes.id));
    } catch (_) {
      _reemplazar(antes);
    }
  }

  /// Tras comentar solo cambia esa tarjeta, sin recargar todo.
  Future<void> actualizar(String id) async {
    try {
      _reemplazar(await _publicaciones.publicacion(id));
    } catch (_) {
      // Si ya no existe, se quita en la próxima carga.
    }
  }

  void _reemplazar(Publicacion nueva) => _cambiar(
    () => _lista = [
      for (final p in _lista ?? const <Publicacion>[])
        p.id == nueva.id ? nueva : p,
    ],
  );

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
