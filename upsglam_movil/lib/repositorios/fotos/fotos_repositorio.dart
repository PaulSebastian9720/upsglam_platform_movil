import 'dart:io';

import 'package:camera/camera.dart';

import '../../modelos/foto/archivo_no_valido.dart';
import '../../modelos/foto/foto.dart';
import '../../servicios/camara/camara_service.dart';
import '../../servicios/galeria/galeria_service.dart';

/// Única fuente de fotos nuevas: la cámara y la galería.
class FotosRepositorio {
  FotosRepositorio(this._camara, this._galeria);

  final CamaraService _camara;
  final GaleriaService _galeria;

  CameraController? get visor => _camara.control;

  bool get tieneVarias => _camara.tieneVarias;

  Future<void> abrir({required bool frontal, required bool flash}) =>
      _camara.abrir(frontal: frontal, flash: flash);

  Future<void> cerrar() => _camara.cerrar();

  Future<bool> ponerFlash(bool encendido) => _camara.ponerFlash(encendido);

  Future<void> abrirAjustes() => _camara.abrirAjustes();

  Future<Foto> tomar() async => Foto(ruta: await _camara.tomar());

  Future<Foto?> elegir() async {
    final ruta = await _galeria.elegir();
    if (ruta == null) return null;
    final foto = Foto(ruta: ruta);
    if (await _esFoto(ruta)) return foto;
    await descartar(foto);
    throw const ArchivoNoValido();
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
          (dice(0, 'RIFF'.codeUnits) && dice(8, 'WEBP'.codeUnits));
    } on FileSystemException {
      return false;
    }
  }
}
