import 'package:flutter/foundation.dart';

import 'package:upsglam_movil/modelos/comentario.dart';
import 'package:upsglam_movil/repositorios/comentarios_repositorio.dart';

class ComentariosController extends ChangeNotifier {
  ComentariosController(this._comentarios, this.publicacionId) {
    cargar();
  }

  final ComentariosRepositorio _comentarios;
  final String publicacionId;

  List<Comentario>? _lista;
  bool _fallo = false;
  bool _enviando = false;
  bool _viva = true;

  /// Nula mientras llega la primera vez.
  List<Comentario>? get comentarios => _lista;
  bool get fallo => _fallo && _lista == null;
  bool get enviando => _enviando;

  Future<void> cargar() async {
    _cambiar(() => _fallo = false);
    try {
      final lista = await _comentarios.dePublicacion(publicacionId);
      _cambiar(() => _lista = lista);
    } catch (_) {
      _cambiar(() => _fallo = true);
    }
  }

  /// Verdadero si se publicó. Un doble toque no lo envía dos veces.
  Future<bool> enviar(String texto) async {
    if (_enviando || texto.trim().isEmpty) return false;
    _cambiar(() => _enviando = true);
    try {
      final nuevo = await _comentarios.comentar(publicacionId, texto);
      _cambiar(() => _lista = [...?_lista, nuevo]);
      return true;
    } catch (_) {
      return false;
    } finally {
      _cambiar(() => _enviando = false);
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
