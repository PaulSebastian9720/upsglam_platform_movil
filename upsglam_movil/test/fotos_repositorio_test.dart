import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:upsglam_movil/modelos/foto/archivo_no_valido.dart';
import 'package:upsglam_movil/repositorios/fotos/fotos_repositorio.dart';
import 'package:upsglam_movil/servicios/camara/camara_service.dart';
import 'package:upsglam_movil/servicios/galeria/galeria_service.dart';

class _Galeria implements GaleriaService {
  _Galeria(this.ruta);

  final String ruta;

  @override
  Future<String?> elegir() async => ruta;
}

void main() {
  late Directory carpeta;
  setUp(() => carpeta = Directory.systemTemp.createTempSync());
  tearDown(() => carpeta.deleteSync(recursive: true));

  FotosRepositorio con(List<int> bytes) {
    final archivo = File('${carpeta.path}/foto.jpg')..writeAsBytesSync(bytes);
    return FotosRepositorio(CamaraService(), _Galeria(archivo.path));
  }

  test('acepta JPG, PNG y WEBP por su contenido', () async {
    for (final bytes in [
      [0xFF, 0xD8, 0xFF, 0xE0],
      [0x89, 0x50, 0x4E, 0x47],
      [...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits],
    ]) {
      expect(await con(bytes).elegir(), isNotNull);
    }
  });

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
