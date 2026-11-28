import 'dart:io';

import 'package:camera/camera.dart';

import 'package:upsglam_movil/modelos/archivo_no_valido.dart';
import 'package:upsglam_movil/modelos/fallo_camara.dart';
import 'package:upsglam_movil/modelos/foto.dart';
import 'package:upsglam_movil/servicios/camara_service.dart';
import 'package:upsglam_movil/servicios/galeria_service.dart';
import 'package:upsglam_movil/servicios/imagen_service.dart';

/// Única fuente de fotos nuevas: la cámara y la galería. Toda foto sale ya
/// optimizada; la vista previa y el envío usan ese mismo archivo.
class FotosRepositorio {
  FotosRepositorio(this._camara, this._galeria, this._imagen);

  final CamaraService _camara;
  final GaleriaService _galeria;
  final ImagenService _imagen;

  CameraController? get visor => _camara.control;

  bool get tieneVarias => _camara.tieneVarias;

  Future<void> abrir({required bool frontal, required bool flash}) =>
      _camara.abrir(frontal: frontal, flash: flash);

  Future<void> cerrar() => _camara.cerrar();

  Future<bool> ponerFlash(bool encendido) => _camara.ponerFlash(encendido);

  Future<void> abrirAjustes() => _camara.abrirAjustes();

  Future<Foto> tomar() async {
    final lista = await _optimizar(await _camara.tomar());
    if (lista == null) throw const FalloCamara(TipoFalloCamara.error);
    return lista;
  }

  Future<Foto?> elegir() async {
    final ruta = await _galeria.elegir();
    if (ruta == null) return null;
    final lista = await _esFoto(ruta) ? await _optimizar(ruta) : null;
    if (lista != null) return lista;
    await descartar(Foto(ruta: ruta));
    throw const ArchivoNoValido();
  }

  /// Cambia la copia temporal por la optimizada y borra la primera.
  Future<Foto?> _optimizar(String ruta) async {
    final lista = await _imagen.optimizar(ruta);
    await descartar(Foto(ruta: ruta));
    return lista == null ? null : Foto(ruta: lista);
  }

  /// Borra la copia temporal; la foto de la galería no se toca.
  Future<void> descartar(Foto foto) async {
    try {
      await File(foto.ruta).delete();
    } on FileSystemException {
      // Ya no estaba.
    }
  }

  /// Mira el contenido, no la extensión, que puede mentir.
  Future<bool> _esFoto(String ruta) async {
    try {
      final b = await File(ruta).openRead(0, 12).expand<int>((x) => x).toList();
      bool dice(int desde, List<int> firma) =>
          b.length >= desde + firma.length &&
          Iterable<int>.generate(
            firma.length,
          ).every((i) => b[desde + i] == firma[i]);
      return dice(0, const [0xFF, 0xD8, 0xFF]) || // JPG
          dice(0, const [0x89, 0x50, 0x4E, 0x47]) || // PNG
          (dice(0, 'RIFF'.codeUnits) && dice(8, 'WEBP'.codeUnits)) ||
          (dice(4, 'ftyp'.codeUnits) && // HEIC del iPhone
              ['heic', 'heix', 'mif1'].any((m) => dice(8, m.codeUnits)));
    } on FileSystemException {
      return false;
    }
  }
}
