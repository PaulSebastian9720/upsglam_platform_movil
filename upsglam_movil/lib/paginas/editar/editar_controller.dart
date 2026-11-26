import 'package:flutter/foundation.dart';

import 'package:upsglam_movil/modelos/filtro.dart';
import 'package:upsglam_movil/modelos/foto.dart';

class EditarController extends ChangeNotifier {
  EditarController(this._foto);

  Foto _foto;
  Foto get foto => _foto;

  /// Por ahora solo marca la rueda; el servidor aplicará el filtro.
  void elegirFiltro(Filtro filtro) {
    _foto = _foto.conFiltro(filtro);
    notifyListeners();
  }
}
