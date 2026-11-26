import 'package:flutter/foundation.dart';

import '../../modelos/procesamiento.dart';
import '../../repositorios/procesamiento_repositorio.dart';

/// La lista de la pestaña Historial del perfil. Se carga al abrir la pestaña.
class HistorialController extends ChangeNotifier {
  HistorialController(this._procesamientos);

  final ProcesamientoRepositorio _procesamientos;

  List<Procesamiento>? _historial;
  bool _cargando = false;
  bool _fallo = false;
  bool _viva = true;

  /// Nulo mientras llega la primera vez.
  List<Procesamiento>? get historial => _historial;

  /// Solo cuenta si no hay nada que mostrar; si ya había datos, se conservan.
  bool get fallo => _fallo && _historial == null;

  /// Al recargar se mantiene lo que había mientras llega lo nuevo.
  Future<void> cargar() async {
    if (_cargando) return;
    _cargando = true;
    _cambiar(() => _fallo = false);
    try {
      final historial = await _procesamientos.historial();
      _cambiar(() => _historial = historial);
    } catch (_) {
      _cambiar(() => _fallo = true);
    } finally {
      _cargando = false;
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
