import 'filtro.dart';

/// Foto tomada o elegida, con el filtro que se aplicará después.
class Foto {
  const Foto({required this.ruta, this.filtro = Filtro.original});

  final String ruta;
  final Filtro filtro;

  Foto conFiltro(Filtro filtro) => Foto(ruta: ruta, filtro: filtro);
}
