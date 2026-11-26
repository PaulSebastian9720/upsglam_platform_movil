import 'package:image_picker/image_picker.dart';

/// Envuelve el selector de fotos del teléfono; no necesita permisos.
class GaleriaService {
  final _selector = ImagePicker();

  /// Ruta de una copia temporal, o nulo si la persona canceló.
  Future<String?> elegir() async =>
      (await _selector.pickImage(source: ImageSource.gallery))?.path;
}
