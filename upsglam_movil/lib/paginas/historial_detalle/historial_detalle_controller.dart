import 'package:flutter/foundation.dart';

import '../../modelos/procesamiento/procesamiento.dart';
import '../../repositorios/procesamiento/procesamiento_repositorio.dart';

class HistorialDetalleController extends ChangeNotifier {
  HistorialDetalleController(this._procesamientos, this.id) {
    cargar();
  }

  final ProcesamientoRepositorio _procesamientos;
  final String id;

  Procesamiento? _procesamiento;
  bool _cargando = false;
  bool _fallo = false;
  bool _verOriginal = false;
  bool _viva = true;

  Procesamiento? get procesamiento => _procesamiento;
  bool get cargando => _cargando;
  bool get fallo => _fallo && _procesamiento == null;

  /// Hay resultado que mostrar: el filtro terminó bien.
  bool get lista =>
      _procesamiento?.estado == EstadoProcesamiento.lista &&
      _procesamiento?.resultado != null;

  /// La foto grande: el resultado, salvo que se elija ver la original.
  String? get foto {
    final p = _procesamiento;
    if (p == null) return null;
    return lista && !_verOriginal ? p.resultado : p.original;
  }

  bool get viendoOriginal => !lista || _verOriginal;

  Future<void> cargar() async {
    if (_cargando) return;
    _cambiar(() {
      _cargando = true;
      _fallo = false;
    });
    try {
      final p = await _procesamientos.procesamiento(id);
      _cambiar(() => _procesamiento = p);
    } catch (_) {
      _cambiar(() => _fallo = true);
    } finally {
      _cambiar(() => _cargando = false);
    }
  }

  void verOriginal() => _cambiar(() => _verOriginal = true);

  void verResultado() => _cambiar(() => _verOriginal = false);

  // Sin backend: aquí se guardará el resultado en la galería del teléfono.
  Future<void> guardar() async {}

  // Sin backend: aquí se pedirá de nuevo el filtro al servidor.
  Future<void> reintentar() async {}

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
