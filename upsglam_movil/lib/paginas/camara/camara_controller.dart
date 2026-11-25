import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../../modelos/fallo_camara/fallo_camara.dart';
import '../../modelos/filtro/filtro.dart';
import '../../modelos/foto/foto.dart';
import '../../repositorios/fotos/fotos_repositorio.dart';

enum EstadoCamara {
  cerrada,
  abriendo,
  lista,
  sinPermiso,
  permisoBloqueado,
  sinCamara,
  fallo,
}

class CamaraController extends ChangeNotifier {
  CamaraController(this._fotos);

  final FotosRepositorio _fotos;

  EstadoCamara _estado = EstadoCamara.cerrada;
  bool _viva = true;
  bool _frontal = false;
  bool _flash = false;
  bool _ocupada = false;
  bool _verFiltros = false;
  Filtro _filtro = Filtro.original;

  EstadoCamara get estado => _estado;
  bool get lista => _estado == EstadoCamara.lista;
  bool get ocupada => _ocupada;
  bool get flash => _flash;
  bool get verFiltros => _verFiltros;
  Filtro get filtro => _filtro;
  bool get puedeTomar => lista && !_ocupada;
  bool get puedeGirar => puedeTomar && _fotos.tieneVarias;
  bool get puedeFlash => puedeTomar && !_frontal;
  CameraController? get visor => lista ? _fotos.visor : null;

  // Abrir, cerrar y disparar van en fila: nunca se pisan entre sí.
  Future<void> _fila = Future.value();

  Future<T> _enFila<T>(Future<T> Function() tarea) {
    final resultado = _fila.then((_) => tarea());
    _fila = resultado.then<void>((_) {}, onError: (_) {});
    return resultado;
  }

  Future<void> abrir() => _enFila(() async {
    if (!_viva || lista) return;
    await _abrir();
  });

  Future<void> _abrir() async {
    _cambiar(() => _estado = EstadoCamara.abriendo);
    try {
      await _fotos.abrir(frontal: _frontal, flash: _flash);
      _cambiar(() => _estado = EstadoCamara.lista);
    } on FalloCamara catch (e) {
      _cambiar(
        () => _estado = switch (e.tipo) {
          TipoFalloCamara.sinPermiso => EstadoCamara.sinPermiso,
          TipoFalloCamara.permisoBloqueado => EstadoCamara.permisoBloqueado,
          TipoFalloCamara.sinCamara => EstadoCamara.sinCamara,
          TipoFalloCamara.error => EstadoCamara.fallo,
        },
      );
    }
  }

  Future<void> cerrar() => _enFila(() async {
    // Primero se quita el visor de la pantalla; después se suelta la cámara.
    _cambiar(() => _estado = EstadoCamara.cerrada);
    await _fotos.cerrar();
  });

  Future<void> girar() async {
    if (!puedeGirar) return;
    _cambiar(() => _ocupada = true);
    await _enFila(() async {
      if (!_viva || !lista) return;
      _frontal = !_frontal;
      await _abrir();
    });
    _cambiar(() => _ocupada = false);
  }

  Future<void> alternarFlash() async {
    if (!puedeFlash) return;
    final nuevo = !_flash;
    if (await _fotos.ponerFlash(nuevo)) _cambiar(() => _flash = nuevo);
  }

  void mostrarFiltros(bool ver) => _cambiar(() => _verFiltros = ver);

  void elegirFiltro(Filtro filtro) => _cambiar(() => _filtro = filtro);

  Future<Foto?> tomar() async {
    if (!puedeTomar) return null;
    _cambiar(() => _ocupada = true);
    try {
      return await _enFila(() async {
        if (!_viva || !lista) return null;
        return (await _fotos.tomar()).conFiltro(_filtro);
      });
    } on FalloCamara {
      if (lista) _cambiar(() => _estado = EstadoCamara.fallo);
      return null;
    } finally {
      _cambiar(() => _ocupada = false);
    }
  }

  Future<Foto?> elegirDeGaleria() async {
    if (_ocupada) return null;
    _cambiar(() => _ocupada = true);
    try {
      return (await _fotos.elegir())?.conFiltro(_filtro);
    } finally {
      _cambiar(() => _ocupada = false);
    }
  }

  Future<void> descartar(Foto foto) => _fotos.descartar(foto);

  Future<void> abrirAjustes() => _fotos.abrirAjustes();

  void _cambiar(VoidCallback cambio) {
    cambio();
    if (_viva) notifyListeners();
  }

  @override
  void dispose() {
    _viva = false;
    _enFila(_fotos.cerrar);
    super.dispose();
  }
}
