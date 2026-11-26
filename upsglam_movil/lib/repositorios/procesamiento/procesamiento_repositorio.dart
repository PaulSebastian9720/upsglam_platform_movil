import '../../modelos/procesamiento/procesamiento.dart';
import '../../servicios/datos_prueba_service.dart';

/// Única fuente del historial de filtros. Hoy lee datos de prueba.
class ProcesamientoRepositorio {
  ProcesamientoRepositorio(this._datos);

  final DatosPruebaService _datos;

  /// Del más nuevo al más antiguo.
  Future<List<Procesamiento>> historial() async =>
      [..._datos.historial]..sort((a, b) => b.creado.compareTo(a.creado));

  Future<Procesamiento> procesamiento(String id) async =>
      _datos.historial.firstWhere(
        (p) => p.id == id,
        orElse: () => throw StateError('No existe el procesamiento $id'),
      );
}
