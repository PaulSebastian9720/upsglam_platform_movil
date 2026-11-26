import '../modelos/filtro/filtro.dart';
import '../modelos/procesamiento/procesamiento.dart';
import '../modelos/publicacion/publicacion.dart';
import '../modelos/usuario/perfil.dart';

/// Datos de prueba en memoria, mientras no hay backend. Los repositorios lo
/// usan como si fuera la API; se reemplaza sin tocar páginas ni controladores.
class DatosPruebaService {
  DatosPruebaService() {
    final ahora = DateTime.now();
    DateTime hace(Duration d) => ahora.subtract(d);

    Publicacion pub(
      String id,
      Perfil de,
      String imagen,
      Filtro filtro,
      Duration antes, {
      String texto = '',
      int meGusta = 0,
      int comentarios = 0,
      bool privada = false,
    }) => Publicacion(
      id: id,
      autor: de.autor,
      imagen: _img(imagen),
      filtro: filtro,
      creada: hace(antes),
      texto: texto,
      meGusta: meGusta,
      comentarios: comentarios,
      privada: privada,
    );

    final yo = perfiles[yoId]!;
    final dani = perfiles['u2']!;
    _publicaciones.addAll([
      pub(
        'p1',
        yo,
        'p_campus',
        Filtro.ups,
        const Duration(minutes: 5),
        texto: 'Nuestro bloque con los colores de casa.',
        meGusta: 23,
        comentarios: 2,
      ),
      pub(
        'p2',
        yo,
        'p_arquitectura',
        Filtro.nitidez,
        const Duration(hours: 3),
        texto: 'La fachada con nitidez.',
        meGusta: 31,
        comentarios: 4,
      ),
      pub(
        'p3',
        yo,
        'p_sunflower',
        Filtro.ups,
        const Duration(days: 1),
        texto: 'Girasol en azul y amarillo.',
        meGusta: 18,
      ),
      pub(
        'p4',
        yo,
        'p_air_balloon',
        Filtro.sobel,
        const Duration(days: 2),
        texto: 'Solo los bordes del globo.',
        meGusta: 27,
        comentarios: 1,
      ),
      pub(
        'p5',
        yo,
        'p_chameleon',
        Filtro.nitidez,
        const Duration(days: 3),
        meGusta: 40,
        comentarios: 6,
      ),
      pub(
        'p6',
        yo,
        'p_soccer',
        Filtro.ups,
        const Duration(days: 4),
        texto: 'Partido del viernes.',
        meGusta: 22,
      ),
      pub(
        'p7',
        yo,
        'p_fish',
        Filtro.relieve,
        const Duration(days: 6),
        meGusta: 15,
      ),
      pub(
        'p8',
        yo,
        'p_books',
        Filtro.media,
        const Duration(days: 8),
        texto: 'Semana de exámenes.',
        privada: true,
      ),
      pub(
        'p9',
        yo,
        'p_pencils',
        Filtro.nitidez,
        const Duration(days: 10),
        meGusta: 38,
        comentarios: 3,
      ),
      pub(
        'd1',
        dani,
        'feed_loro',
        Filtro.ups,
        const Duration(hours: 2),
        texto: 'Encontré los colores de la U en el patio.',
        meGusta: 48,
        comentarios: 6,
      ),
      pub(
        'd2',
        dani,
        'p_cat',
        Filtro.sobel,
        const Duration(days: 1),
        meGusta: 20,
      ),
      pub(
        'd3',
        dani,
        'p_dog',
        Filtro.ups,
        const Duration(days: 2),
        meGusta: 25,
        comentarios: 2,
      ),
      pub(
        'd4',
        dani,
        'p_car',
        Filtro.nitidez,
        const Duration(days: 3),
        meGusta: 12,
      ),
      pub(
        'd5',
        dani,
        'feed_hoja',
        Filtro.relieve,
        const Duration(days: 5),
        meGusta: 9,
      ),
      pub(
        'd6',
        dani,
        'muestra_ups',
        Filtro.ups,
        const Duration(days: 7),
        meGusta: 17,
        comentarios: 1,
      ),
    ]);

    _historial.addAll([
      Procesamiento(
        id: 'h1',
        filtro: Filtro.media,
        estado: EstadoProcesamiento.aplicando,
        original: _img('filtro_normal'),
        creado: ahora,
      ),
      Procesamiento(
        id: 'h2',
        filtro: Filtro.ups,
        estado: EstadoProcesamiento.lista,
        original: _img('feed_campus'),
        resultado: _img('filtro_ups'),
        creado: hace(const Duration(minutes: 5)),
      ),
      Procesamiento(
        id: 'h3',
        filtro: Filtro.sobel,
        estado: EstadoProcesamiento.lista,
        original: _img('galeria_air_balloon'),
        resultado: _img('p_air_balloon'),
        creado: hace(const Duration(days: 1)),
      ),
      Procesamiento(
        id: 'h4',
        filtro: Filtro.relieve,
        estado: EstadoProcesamiento.fallo,
        original: _img('galeria_books'),
        creado: hace(const Duration(days: 1, hours: 2)),
      ),
      Procesamiento(
        id: 'h5',
        filtro: Filtro.nitidez,
        estado: EstadoProcesamiento.lista,
        original: _img('galeria_chameleon'),
        resultado: _img('p_chameleon'),
        creado: hace(const Duration(days: 3)),
      ),
      Procesamiento(
        id: 'h6',
        filtro: Filtro.media,
        estado: EstadoProcesamiento.lista,
        original: _img('historial_libros'),
        resultado: _img('p_books'),
        creado: hace(const Duration(days: 8)),
      ),
    ]);
  }

  static String _img(String nombre) => 'assets/mock/$nombre.webp';

  static const yoId = 'u1';

  final Map<String, Perfil> perfiles = {
    'u1': Perfil(
      id: 'u1',
      usuario: 'andre.luz',
      avatar: _img('avatar_1'),
      descripcion:
          'Computación, UPS Cuenca. Fotos del campus y lo que aparezca.',
      publicaciones: 9,
      meGusta: 214,
      seguidores: 36,
    ),
    'u2': Perfil(
      id: 'u2',
      usuario: 'dani.vega',
      avatar: _img('avatar_3'),
      descripcion: 'Animales, viajes y bastante filtro UPS.',
      publicaciones: 6,
      meGusta: 131,
      seguidores: 58,
      loSigo: true,
    ),
    'u3': Perfil(
      id: 'u3',
      usuario: 'sofi.mora',
      avatar: _img('avatar_2'),
      descripcion: 'Arquitectura y luz.',
      meGusta: 87,
      seguidores: 41,
      loSigo: true,
    ),
    'u4': Perfil(
      id: 'u4',
      usuario: 'nico.paz',
      avatar: _img('avatar_4'),
      meGusta: 12,
      seguidores: 9,
      loSigo: true,
    ),
    'u5': Perfil(
      id: 'u5',
      usuario: 'valen.rios',
      avatar: _img('avatar_5'),
      meGusta: 33,
      seguidores: 20,
      loSigo: true,
    ),
    'u6': Perfil(
      id: 'u6',
      usuario: 'maru.leon',
      avatar: _img('p_sunflower'),
      meGusta: 5,
      seguidores: 14,
    ),
    'u7': Perfil(
      id: 'u7',
      usuario: 'tomas.arce',
      avatar: _img('p_car'),
      meGusta: 51,
      seguidores: 30,
      loSigo: true,
    ),
  };

  final List<Publicacion> _publicaciones = [];
  final List<Procesamiento> _historial = [];

  List<Publicacion> get publicaciones => _publicaciones;
  List<Procesamiento> get historial => _historial;
}
