import 'package:flutter/foundation.dart';

import '../../modelos/publicacion.dart';
import '../../repositorios/perfil_repositorio.dart';
import '../../repositorios/publicaciones_repositorio.dart';

class MisPublicacionesController extends ChangeNotifier {
  MisPublicacionesController(this._perfiles, this._publicaciones) {
    cargar();
  }

  final PerfilRepositorio _perfiles;
  final PublicacionesRepositorio _publicaciones;

  List<Publicacion>? _lista;

  /// Nulo mientras llega la primera carga.
  List<Publicacion>? get publicaciones => _lista;

  bool _fallo = false;
  bool get fallo => _fallo;

  bool _pidiendo = false;
  bool _cerrado = false;

  /// Publicaciones cuya privacidad se está cambiando.
  final _cambiando = <String>{};

  /// Primera carga, o reintento tras un fallo.
  Future<void> cargar() async {
    _lista = null;
    _fallo = false;
    notifyListeners();
    await recargar();
  }

  /// Trae la lista de nuevo y mantiene la actual mientras llega.
  Future<void> recargar() async {
    if (_pidiendo) return;
    _pidiendo = true;
    try {
      _lista = await _publicaciones.deUsuario(_perfiles.miId);
      _fallo = false;
    } catch (_) {
      // Si ya había lista, se conserva; si no, se ofrece reintentar.
      _fallo = _lista == null;
    }
    _pidiendo = false;
    _avisar();
  }

  /// El cambio se ve al instante y se deshace si no se pudo guardar.
  Future<void> alternarPrivacidad(Publicacion publicacion) async {
    if (!_cambiando.add(publicacion.id)) return;
    final privada = !publicacion.privada;
    _reemplazar(publicacion.copyWith(privada: privada));
    try {
      _reemplazar(
        await _publicaciones.cambiarPrivacidad(
          publicacion.id,
          privada: privada,
        ),
      );
    } catch (_) {
      _reemplazar(publicacion);
    }
    _cambiando.remove(publicacion.id);
  }

  void _reemplazar(Publicacion nueva) {
    final lista = _lista;
    if (lista == null) return;
    _lista = [for (final p in lista) p.id == nueva.id ? nueva : p];
    _avisar();
  }

  void _avisar() {
    if (!_cerrado) notifyListeners();
  }

  @override
  void dispose() {
    _cerrado = true;
    super.dispose();
  }
}
