import 'package:camera/camera.dart';
import 'package:upsglam_movil/modelos/fallo_camara.dart';
import 'package:upsglam_movil/modelos/foto.dart';
import 'package:upsglam_movil/repositorios/fotos_repositorio.dart';

class FotosFalsas implements FotosRepositorio {
  bool abierta = false;
  bool frontal = false;
  bool flash = false;
  int tomadas = 0;
  int descartadas = 0;
  int ajustes = 0;
  TipoFalloCamara? fallo;
  Foto? Function() alElegir = () => null;

  @override
  CameraController? get visor => null;

  @override
  bool get tieneVarias => true;

  @override
  Future<void> abrir({required bool frontal, required bool flash}) async {
    if (fallo != null) throw FalloCamara(fallo!);
    this.frontal = frontal;
    abierta = true;
  }

  @override
  Future<void> cerrar() async => abierta = false;

  @override
  Future<bool> ponerFlash(bool encendido) async {
    flash = encendido;
    return true;
  }

  @override
  Future<void> abrirAjustes() async => ajustes++;

  @override
  Future<Foto> tomar() async {
    tomadas++;
    return const Foto(ruta: 'x.jpg');
  }

  @override
  Future<Foto?> elegir() async => alElegir();

  @override
  Future<void> descartar(Foto foto) async => descartadas++;
}
