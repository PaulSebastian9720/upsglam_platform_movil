import 'package:flutter/foundation.dart';

import '../../modelos/perfil.dart';
import '../../repositorios/seguidos_repositorio.dart';

class SeguidoresController extends ChangeNotifier {
  SeguidoresController(this._seguidos);

  final SeguidosRepositorio _seguidos;

  List<Perfil>? _personas;
  bool _cargando = false;
  bool _fallo = false;
  final _enviando = <String>{};
  bool _viva = true;

  /// Las personas que me siguen; nula mientras llega por primera vez. A cada
  /// una la puedo seguir o dejar de seguir desde aquí.
  List<Perfil>? get personas => _personas;
  bool get cargando => _cargando;
  bool get fallo => _fallo;

  /// Al recargar se mantiene lo que había mientras llega lo nuevo.
  Future<void> cargar() async {
    if (_cargando) return;
    _cambiar(() {
      _cargando = true;
      _fallo = false;
    });
    try {
      final lista = await _seguidos.seguidores();
      _cambiar(() => _personas = lista);
    } catch (_) {
      _cambiar(() => _fallo = true);
    } finally {
      _cambiar(() => _cargando = false);
    }
  }

  /// Cambia al instante y se deshace si no se pudo guardar. Un doble toque
  /// no envía dos veces.
  Future<void> alternar(String id) async {
    final antes = _buscar(id);
    if (antes == null || _enviando.contains(id)) return;
    _enviando.add(id);
    final seguir = !antes.loSigo;
    _reemplazar(
      antes.copyWith(
        loSigo: seguir,
        seguidores: antes.seguidores + (seguir ? 1 : -1),
      ),
    );
    try {
      _reemplazar(
        seguir ? await _seguidos.seguir(id) : await _seguidos.dejarDeSeguir(id),
      );
    } catch (_) {
      _reemplazar(antes);
    } finally {
      _enviando.remove(id);
    }
  }

  Perfil? _buscar(String id) {
    for (final p in _personas ?? const <Perfil>[]) {
      if (p.id == id) return p;
    }
    return null;
  }

  void _reemplazar(Perfil nuevo) => _cambiar(
    () => _personas = [
      for (final p in _personas ?? const <Perfil>[])
        p.id == nuevo.id ? nuevo : p,
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
