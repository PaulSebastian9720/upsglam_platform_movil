import 'package:flutter/foundation.dart';

import '../../modelos/publicacion.dart';
import '../../repositorios/publicaciones_repositorio.dart';

class PublicacionController extends ChangeNotifier {
  PublicacionController(this._publicaciones, this.id);

  final PublicacionesRepositorio _publicaciones;
  final String id;

  Publicacion? _publicacion;
  bool _cargando = false;
  bool _fallo = false;
  bool _noExiste = false;
  bool _viva = true;

  /// Nula mientras llega por primera vez.
  Publicacion? get publicacion => _publicacion;
  bool get cargando => _cargando;
  bool get fallo => _fallo;

  /// Se borró, por ejemplo desde Editar publicación.
  bool get noExiste => _noExiste;

  /// Al recargar se mantiene lo que había mientras llega lo nuevo.
  Future<void> cargar() async {
    if (_cargando) return;
    _cambiar(() {
      _cargando = true;
      _fallo = false;
    });
    try {
      final nueva = await _publicaciones.publicacion(id);
      _cambiar(() {
        _publicacion = nueva;
        _noExiste = false;
      });
    } on StateError {
      // Así responde hoy el repositorio cuando la publicación ya no está.
      _cambiar(() {
        _publicacion = null;
        _noExiste = true;
      });
    } catch (_) {
      _cambiar(() => _fallo = true);
    } finally {
      _cambiar(() => _cargando = false);
    }
  }

  /// Se ve al instante; si no se guarda, vuelve a como estaba.
  Future<void> alternarMeGusta() async {
    final antes = _publicacion;
    if (antes == null) return;
    _cambiar(
      () => _publicacion = antes.copyWith(
        meGustaMio: !antes.meGustaMio,
        meGusta: antes.meGusta + (antes.meGustaMio ? -1 : 1),
      ),
    );
    try {
      final guardada = await _publicaciones.alternarMeGusta(antes.id);
      _cambiar(() => _publicacion = guardada);
    } catch (_) {
      _cambiar(() => _publicacion = antes);
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
