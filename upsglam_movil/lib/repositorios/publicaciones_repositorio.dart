import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:upsglam_movil/modelos/filtro.dart';
import 'package:upsglam_movil/modelos/publicacion.dart';
import 'package:upsglam_movil/servicios/datos_prueba_service.dart';

/// Única fuente de las publicaciones. Hoy lee datos de prueba.
class PublicacionesRepositorio {
  PublicacionesRepositorio(this._datos);

  final DatosPruebaService _datos;

  /// Avisa cuando se publica, edita o elimina, para que Inicio y Perfil se
  /// actualicen solos. Los me gusta no cuentan: ya se ven al instante.
  Listenable get cambios => _cambios;
  final _cambios = _Aviso();

  void _avisar() => _cambios.avisar();

  /// Publica la foto con su filtro. La copia del archivo sobrevive a que la
  /// cámara borre su foto temporal.
  Future<Publicacion> publicar({
    required String ruta,
    required Filtro filtro,
    required String texto,
  }) async {
    final id = _datos.nuevoId('n');
    var imagen = ruta;
    if (!ruta.startsWith('assets/')) {
      final original = File(ruta);
      imagen = (await original.copy(
        '${original.parent.path}/upsglam_publicacion_$id.jpg',
      )).path;
    }
    final nueva = Publicacion(
      id: id,
      autor: _datos.perfiles[DatosPruebaService.yoId]!.autor,
      imagen: imagen,
      filtro: filtro,
      creada: DateTime.now(),
      texto: texto.trim(),
    );
    _datos.publicaciones.add(nueva);
    _avisar();
    return nueva;
  }

  /// De la más nueva a la más antigua. Las privadas solo las ve su autor.
  Future<List<Publicacion>> deUsuario(String usuarioId) async {
    final propias = usuarioId == DatosPruebaService.yoId;
    return _datos.publicaciones
        .where((p) => p.autor.id == usuarioId && (propias || !p.privada))
        .toList()
      ..sort((a, b) => b.creada.compareTo(a.creada));
  }

  /// Inicio: las publicaciones de todos, las sigas o no, de la más nueva a
  /// la más antigua. Las privadas solo las ve su autor.
  Future<List<Publicacion>> inicio() async {
    bool visible(Publicacion p) =>
        p.autor.id == DatosPruebaService.yoId || !p.privada;
    return _datos.publicaciones.where(visible).toList()
      ..sort((a, b) => b.creada.compareTo(a.creada));
  }

  Future<Publicacion> alternarMeGusta(String id) => _cambiar(
    id,
    (p) => p.copyWith(
      meGustaMio: !p.meGustaMio,
      meGusta: p.meGusta + (p.meGustaMio ? -1 : 1),
    ),
  );

  Future<Publicacion> publicacion(String id) async =>
      _datos.publicaciones.firstWhere(
        (p) => p.id == id,
        orElse: () => throw StateError('No existe la publicación $id'),
      );

  Future<Publicacion> editarTexto(String id, String texto) async {
    final p = await _cambiar(id, (p) => p.copyWith(texto: texto));
    _avisar();
    return p;
  }

  Future<Publicacion> cambiarPrivacidad(
    String id, {
    required bool privada,
  }) async {
    final p = await _cambiar(id, (p) => p.copyWith(privada: privada));
    _avisar();
    return p;
  }

  Future<void> eliminar(String id) async {
    _datos.publicaciones.removeWhere((p) => p.id == id);
    _avisar();
  }

  Future<Publicacion> _cambiar(
    String id,
    Publicacion Function(Publicacion) cambio,
  ) async {
    final i = _datos.publicaciones.indexWhere((p) => p.id == id);
    if (i < 0) throw StateError('No existe la publicación $id');
    return _datos.publicaciones[i] = cambio(_datos.publicaciones[i]);
  }
}

class _Aviso extends ChangeNotifier {
  void avisar() => notifyListeners();
}
