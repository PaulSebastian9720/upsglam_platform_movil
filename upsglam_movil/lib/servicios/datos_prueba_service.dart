import 'package:upsglam_movil/modelos/comentario.dart';
import 'package:upsglam_movil/modelos/filtro.dart';
import 'package:upsglam_movil/modelos/procesamiento.dart';
import 'package:upsglam_movil/modelos/publicacion.dart';
import 'package:upsglam_movil/modelos/perfil.dart';

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
      // Otras personas: unas las sigo y otras no, para ver la diferencia.
      pub(
        's1',
        perfiles['u3']!,
        'feed_arquitectura',
        Filtro.nitidez,
        const Duration(minutes: 40),
        texto: 'Las ondas de la fachada en blanco y negro.',
        meGusta: 34,
        comentarios: 3,
      ),
      pub(
        's2',
        perfiles['u3']!,
        'feed_campus',
        Filtro.ups,
        const Duration(days: 2),
        texto: 'El patio central.',
        meGusta: 21,
      ),
      pub(
        'n1',
        perfiles['u4']!,
        'resultado_media',
        Filtro.media,
        const Duration(hours: 5),
        texto: 'Media en nivel fuerte.',
        meGusta: 8,
        comentarios: 1,
      ),
      pub(
        'v1',
        perfiles['u5']!,
        'galeria_chameleon',
        Filtro.original,
        const Duration(hours: 9),
        texto: 'Sin filtro, así salió.',
        meGusta: 14,
      ),
      pub(
        'm1',
        perfiles['u6']!,
        'historial_libros',
        Filtro.relieve,
        const Duration(hours: 1),
        texto: 'Relieve sobre los libros.',
        meGusta: 6,
        comentarios: 2,
      ),
      pub(
        'm2',
        perfiles['u6']!,
        'galeria_air_balloon',
        Filtro.sobel,
        const Duration(days: 3),
        meGusta: 11,
      ),
      pub(
        't1',
        perfiles['u7']!,
        'resultado_ups',
        Filtro.ups,
        const Duration(hours: 4),
        texto: 'Primera prueba con UPS.',
        meGusta: 29,
        comentarios: 2,
      ),
    ]);

    _sembrarComentarios(ahora);

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

  /// Quiénes me siguen. Solo se conocen mis seguidores.
  final Set<String> meSiguen = {'u2', 'u3', 'u4', 'u6', 'u7'};

  final List<Publicacion> _publicaciones = [];
  final List<Procesamiento> _historial = [];
  final List<Comentario> _comentarios = [];

  List<Publicacion> get publicaciones => _publicaciones;
  List<Procesamiento> get historial => _historial;
  List<Comentario> get comentarios => _comentarios;

  int _siguiente = 0;
  String nuevoId(String prefijo) => '$prefijo${++_siguiente}';

  /// Tantos comentarios como dice cada publicación, del más antiguo al último.
  void _sembrarComentarios(DateTime ahora) {
    const textos = [
      '¿Ese es el filtro UPS? Quedó increíble.',
      'Sí, con la intensidad al máximo.',
      'El ojo se ve clarísimo con los bordes amarillos.',
      'Voy a probarlo con la foto del campus.',
      'Pásala cuando la tengas.',
      'Ya me apunto también.',
    ];
    const autores = ['u3', 'u2', 'u1', 'u3', 'u5', 'u1'];
    for (final p in _publicaciones) {
      for (var i = 0; i < p.comentarios; i++) {
        _comentarios.add(
          Comentario(
            id: nuevoId('c'),
            publicacionId: p.id,
            autor: perfiles[autores[i % autores.length]]!.autor,
            texto: textos[i % textos.length],
            creado: p.creada.add(Duration(minutes: i + 1)),
          ),
        );
      }
    }
  }
}
