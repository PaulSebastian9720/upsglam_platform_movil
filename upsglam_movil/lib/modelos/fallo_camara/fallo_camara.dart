enum TipoFalloCamara { sinPermiso, permisoBloqueado, sinCamara, error }

class FalloCamara implements Exception {
  const FalloCamara(this.tipo);

  final TipoFalloCamara tipo;
}
