enum Filtro {
  original('Original', 'normal'),
  ups('UPS', 'ups'),
  nitidez('Nitidez', 'nitidez'),
  media('Media', 'media'),
  laplaciano('Laplaciano', 'laplaciano'),
  sobel('Sobel', 'sobel'),
  relieve('Relieve', 'relieve');

  const Filtro(this.nombre, this._muestra);

  final String nombre;
  final String _muestra;

  String get muestra => 'assets/imagenes/filtros/$_muestra.webp';
}
