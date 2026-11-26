import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../componentes/app_alerta.dart';
import '../../componentes/app_icono.dart';
import '../../componentes/boton_redondo.dart';
import '../../componentes/estado_vacio.dart';
import '../../modelos/foto/archivo_no_valido.dart';
import '../../modelos/foto/foto.dart';
import '../../rutas/rutas.dart';
import '../../tema/app_theme.dart';
import 'camara_controller.dart';
import 'componentes/boton_disparo.dart';
import 'componentes/control_camara.dart';
import 'componentes/rejilla_camara.dart';
import 'componentes/visor_camara.dart';

class CamaraPage extends StatelessWidget {
  const CamaraPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => CamaraController(context.read()),
    child: const _CamaraVista(),
  );
}

class _CamaraVista extends StatefulWidget {
  const _CamaraVista();

  @override
  State<_CamaraVista> createState() => _CamaraVistaState();
}

class _CamaraVistaState extends State<_CamaraVista> {
  late final _camara = context.read<CamaraController>();
  late final AppLifecycleListener _ciclo;
  bool _fuera = false; // en la galería o editando la foto

  @override
  void initState() {
    super.initState();
    _ciclo = AppLifecycleListener(
      onHide: _camara.cerrar,
      onShow: () {
        if (!_fuera) _camara.abrir();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _camara.abrir());
  }

  @override
  void dispose() {
    _ciclo.dispose();
    super.dispose();
  }

  Future<void> _tomar() async {
    final foto = await _camara.tomar();
    if (foto != null) await _editar(foto);
  }

  Future<void> _elegir() async {
    if (_fuera) return;
    _fuera = true;
    Foto? foto;
    var otra = false;
    try {
      foto = await _camara.elegirDeGaleria();
    } on ArchivoNoValido {
      if (mounted) {
        otra = await AppAlerta.mostrar(context, TipoAlerta.archivoNoValido);
      }
    } on PlatformException {
      foto = null; // no hay galería en el teléfono
    }
    _fuera = false;
    if (!mounted) return;
    if (otra) return _elegir();
    if (foto != null) return _editar(foto);
    await _camara.abrir();
  }

  Future<void> _editar(Foto foto) async {
    if (!mounted) return _camara.descartar(foto);
    _fuera = true;
    final regreso = context.push(Rutas.editar, extra: foto);
    await _camara.cerrar();
    await regreso;
    await _camara.descartar(foto);
    _fuera = false;
    if (mounted) await _camara.abrir();
  }

  @override
  Widget build(BuildContext context) {
    final camara = context.watch<CamaraController>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _fondo(camara),
            SafeArea(
              minimum: const EdgeInsets.all(AppEspacio.base),
              child: Column(
                children: [_arriba(camara), const Spacer(), _abajo(camara)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fondo(CamaraController camara) => switch (camara.estado) {
    EstadoCamara.lista => Stack(
      fit: StackFit.expand,
      children: [
        VisorCamara(control: camara.visor),
        const RejillaCamara(),
      ],
    ),
    EstadoCamara.cerrada || EstadoCamara.abriendo => const SizedBox.shrink(),
    EstadoCamara.sinPermiso => EstadoVacio(
      mensaje: 'Permite usar la cámara para tomar fotos',
      accion: 'Permitir',
      alPulsar: camara.abrir,
    ),
    EstadoCamara.permisoBloqueado => EstadoVacio(
      mensaje: 'Permite usar la cámara en los ajustes del teléfono',
      accion: 'Abrir ajustes',
      alPulsar: camara.abrirAjustes,
    ),
    EstadoCamara.sinCamara => const EstadoVacio(
      mensaje: 'Este teléfono no tiene cámara. Elige una foto de la galería',
    ),
    EstadoCamara.fallo => EstadoVacio(
      mensaje: 'No se pudo usar la cámara',
      accion: 'Reintentar',
      alPulsar: camara.abrir,
    ),
  };

  // Los filtros se eligen después de tomar la foto, en Editar.
  Widget _arriba(CamaraController camara) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      BotonRedondo(
        icono: Iconos.cerrar,
        descripcion: 'Cerrar cámara',
        alPulsar: () => context.pop(),
      ),
      BotonRedondo(
        icono: camara.flash ? Iconos.flash : Iconos.flashApagado,
        descripcion: camara.flash ? 'Flash encendido' : 'Flash apagado',
        alPulsar: camara.puedeFlash ? camara.alternarFlash : null,
      ),
    ],
  );

  Widget _abajo(CamaraController camara) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      ControlCamara(
        icono: Iconos.galeria,
        texto: 'Galería',
        alPulsar: camara.ocupada ? null : _elegir,
      ),
      BotonDisparo(
        ocupado: camara.ocupada,
        alPulsar: camara.puedeTomar ? _tomar : null,
      ),
      ControlCamara(
        icono: Iconos.girar,
        texto: 'Girar',
        alPulsar: camara.puedeGirar ? camara.girar : null,
      ),
    ],
  );
}
