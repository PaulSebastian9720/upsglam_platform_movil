import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tema/app_theme.dart';
import 'app_icono.dart';

/// Menú inferior. Existe una sola vez, en el armazón de las rutas.
///
/// Mide el alto total (la bola completa con su anillo) porque
/// Flutter no entrega toques fuera de los límites del padre.
class BarraPrincipal extends StatelessWidget {
  const BarraPrincipal({
    super.key,
    required this.actual,
    required this.alElegir,
    required this.alAbrirCamara,
  });

  final int actual;
  final ValueChanged<int> alElegir;
  final VoidCallback alAbrirCamara;

  static const _sobresale =
      (AppMedida.bola - AppMedida.barra) / 2 +
      AppMedida.bolaSube +
      AppMedida.borde;

  // La bola y su anillo son lo más alto: mandan sobre la barra.
  static const _alto = AppMedida.bola + AppMedida.borde * 2;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final fondo = Theme.of(context).scaffoldBackgroundColor;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppEspacio.base),
      child: SizedBox(
        height: _alto,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: _sobresale,
              child: Container(
                width: AppMedida.barraAncho,
                height: AppMedida.barra,
                decoration: BoxDecoration(
                  color: esquema.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppMedida.barra / 2),
                  boxShadow: [
                    BoxShadow(color: fondo, spreadRadius: AppEspacio.xs),
                  ],
                ),
                child: Row(
                  children: [
                    _Pestana(
                      texto: 'Inicio',
                      icono: Iconos.inicio,
                      iconoActivo: Iconos.inicioActivo,
                      activa: actual == 0,
                      alPulsar: () => alElegir(0),
                    ),
                    const SizedBox(width: AppMedida.bola),
                    _Pestana(
                      texto: 'Perfil',
                      icono: Iconos.perfil,
                      iconoActivo: Iconos.perfilActivo,
                      activa: actual == 1,
                      alPulsar: () => alElegir(1),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: AppMedida.borde,
              child: _Bola(alPulsar: alAbrirCamara),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  const _Pestana({
    required this.texto,
    required this.icono,
    required this.iconoActivo,
    required this.activa,
    required this.alPulsar,
  });

  final String texto;
  final Iconos icono;
  final Iconos iconoActivo;
  final bool activa;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Expanded(
      child: Semantics(
        button: true,
        selected: activa,
        label: texto,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: alPulsar,
          child: SizedBox.expand(
            child: Center(
              child: AppIcono(
                activa ? iconoActivo : icono,
                tamano: 28,
                color: activa ? esquema.onSurface : esquema.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bola extends StatelessWidget {
  const _Bola({required this.alPulsar});

  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Semantics(
      button: true,
      label: 'Cámara',
      child: GestureDetector(
        onTap: alPulsar,
        child: Container(
          width: AppMedida.bola,
          height: AppMedida.bola,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tema.colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: tema.scaffoldBackgroundColor,
                spreadRadius: AppMedida.borde,
              ),
            ],
          ),
          child: SvgPicture.asset(
            'assets/logo/logo_amarillo.svg',
            width: 62,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
