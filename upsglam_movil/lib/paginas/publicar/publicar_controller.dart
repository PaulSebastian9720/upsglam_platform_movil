import 'package:flutter/foundation.dart';

import 'package:upsglam_movil/modelos/foto.dart';
import 'package:upsglam_movil/repositorios/publicaciones_repositorio.dart';

class PublicarController extends ChangeNotifier {
  PublicarController(this._publicaciones, this.foto);

  final PublicacionesRepositorio _publicaciones;
  final Foto foto;

  bool _publicando = false;
  bool get publicando => _publicando;

  /// Verdadero si se publicó. Un doble toque no publica dos veces.
  Future<bool> publicar(String texto) async {
    if (_publicando) return false;
    _publicando = true;
    notifyListeners();
    try {
      await _publicaciones.publicar(
        ruta: foto.ruta,
        filtro: foto.filtro,
        texto: texto,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _publicando = false;
      notifyListeners();
    }
  }
}
