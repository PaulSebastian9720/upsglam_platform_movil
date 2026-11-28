import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:upsglam_movil/modelos/archivo_no_valido.dart';
import 'package:upsglam_movil/repositorios/fotos_repositorio.dart';
import 'package:upsglam_movil/servicios/camara_service.dart';
import 'package:upsglam_movil/servicios/galeria_service.dart';
import 'package:upsglam_movil/servicios/imagen_service.dart';

class _Galeria implements GaleriaService {
  _Galeria(this.ruta);

  final String ruta;

  @override
  Future<String?> elegir() async => ruta;
}

/// Copia la foto tal cual, como si ya estuviera optimizada.
class _Imagen implements ImagenService {
  @override
  Future<String?> optimizar(String ruta) async =>
      (await File(ruta).copy('$ruta.webp')).path;
}

void main() {
  late Directory carpeta;
  setUp(() => carpeta = Directory.systemTemp.createTempSync());
  tearDown(() => carpeta.deleteSync(recursive: true));

  FotosRepositorio con(List<int> bytes) {
    final archivo = File('${carpeta.path}/foto.jpg')..writeAsBytesSync(bytes);
    return FotosRepositorio(CamaraService(), _Galeria(archivo.path), _Imagen());
  }

  test(
    'acepta JPG, PNG, WEBP y HEIC por su contenido y entrega la optimizada',
    () async {
      for (final bytes in [
        [0xFF, 0xD8, 0xFF, 0xE0],
        [0x89, 0x50, 0x4E, 0x47],
        [...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits],
        [0, 0, 0, 24, ...'ftypheic'.codeUnits],
      ]) {
        final foto = await con(bytes).elegir();
        expect(foto!.ruta, endsWith('.webp'));
        expect(carpeta.listSync(), hasLength(1)); // la copia original se borró
        File(foto.ruta).deleteSync();
      }
    },
  );

  test('rechaza lo demás aunque se llame .jpg, y borra la copia', () async {
    for (final bytes in [
      <int>[],
      'GIF89a'.codeUnits,
      'RIFF0000WAVE'.codeUnits,
    ]) {
      await expectLater(con(bytes).elegir(), throwsA(isA<ArchivoNoValido>()));
      expect(carpeta.listSync(), isEmpty);
    }
  });
}
