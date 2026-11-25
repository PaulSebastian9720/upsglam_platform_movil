import 'package:flutter/foundation.dart';

import '../../modelos/filtro/filtro.dart';
import '../../modelos/foto/foto.dart';

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
