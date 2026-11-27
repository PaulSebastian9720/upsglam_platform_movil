import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:upsglam_movil/modelos/fallo_camara.dart';

/// Envuelve la cámara del teléfono y su permiso.
class CamaraService {
  CameraController? _control;
  List<CameraDescription> _camaras = const [];

  CameraController? get control => _control;

  bool get tieneVarias =>
      _hay(CameraLensDirection.front) && _hay(CameraLensDirection.back);

  bool _hay(CameraLensDirection lado) =>
      _camaras.any((c) => c.lensDirection == lado);

  Future<void> abrir({required bool frontal, required bool flash}) async {
    await cerrar();
    await _pedirPermiso();
    try {
      if (_camaras.isEmpty) _camaras = await availableCameras();
      if (_camaras.isEmpty) throw const FalloCamara(TipoFalloCamara.sinCamara);
      final lado = frontal
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final control = CameraController(
        _camaras.firstWhere(
          (c) => c.lensDirection == lado,
          orElse: () => _camaras.first,
        ),
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      _control = control;
      await control.initialize();
      await ponerFlash(flash && !frontal);
    } on CameraException catch (e) {
      await cerrar();
      throw FalloCamara(switch (e.code) {
        'CameraAccessDenied' => TipoFalloCamara.sinPermiso,
        'CameraAccessDeniedWithoutPrompt' ||
        'CameraAccessRestricted' => TipoFalloCamara.permisoBloqueado,
        'cameraNotFound' => TipoFalloCamara.sinCamara,
        _ => TipoFalloCamara.error,
      });
    } on PlatformException {
      await cerrar();
      throw const FalloCamara(TipoFalloCamara.error);
    }
  }

  /// En iOS lo pide la propia cámara al abrirse.
  Future<void> _pedirPermiso() async {
    if (!Platform.isAndroid) return;
    final permiso = await Permission.camera.request();
    if (permiso.isGranted) return;
    throw FalloCamara(
      permiso.isPermanentlyDenied
          ? TipoFalloCamara.permisoBloqueado
          : TipoFalloCamara.sinPermiso,
    );
  }

  Future<void> cerrar() async {
    final control = _control;
    _control = null;
    try {
      await control?.dispose();
    } on CameraException {
      // Ya estaba cerrada.
    }
  }

  /// Devuelve si quedó como se pidió: hay cámaras sin flash.
  Future<bool> ponerFlash(bool encendido) async {
    try {
      await _control?.setFlashMode(
        encendido ? FlashMode.always : FlashMode.off,
      );
      return true;
    } catch (_) {
      // Sin flash o sin permiso para usarlo: CameraException o
      // PlatformException según el teléfono.
      return false;
    }
  }

  Future<String> tomar() async {
    final control = _control;
    if (control == null) throw const FalloCamara(TipoFalloCamara.error);
    try {
      return (await control.takePicture()).path;
    } on CameraException {
      throw const FalloCamara(TipoFalloCamara.error);
    }
  }

  Future<void> abrirAjustes() => openAppSettings();
}
