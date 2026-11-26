import 'package:upsglam_movil/modelos/filtro.dart';

enum EstadoProcesamiento { aplicando, lista, fallo }

/// Un filtro pedido al servidor, con su foto original y su resultado.
class Procesamiento {
  const Procesamiento({
    required this.id,
    required this.filtro,
    required this.estado,
    required this.original,
    required this.creado,
    this.resultado,
  });

  final String id;
  final Filtro filtro;
  final EstadoProcesamiento estado;
  final String original;

  /// Solo existe cuando el estado es lista.
  final String? resultado;
  final DateTime creado;
}
