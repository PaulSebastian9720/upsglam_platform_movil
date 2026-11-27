import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/componentes/app_icono.dart';
import 'package:upsglam_movil/componentes/boton_redondo.dart';

/// Foto del campus con los filtros, el logo montado sobre su borde y el nombre.
class PortadaAcceso extends StatelessWidget {
  const PortadaAcceso({super.key, this.alVolver});

  /// Con él aparece la flecha para regresar, sobre la foto.
  final VoidCallback? alVolver;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final marca = tema.extension<AppMarca>()!;
    return SizedBox(
      height: AppMedida.portada + AppMedida.logoPortada / 2,
      child: Stack(
        children: [
          Image.asset(
            'assets/imagenes/login/portada.webp',
            width: double.infinity,
            height: AppMedida.portada,
            fit: BoxFit.cover,
            semanticLabel: 'Campus de la UPS con los filtros de la app',
          ),
          Positioned(
            left: AppEspacio.base,
            bottom: 0,
            child: Container(
              width: AppMedida.logoPortada,
              height: AppMedida.logoPortada,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: marca.fondoLogo,
                borderRadius: BorderRadius.circular(AppRadio.hoja),
                boxShadow: [
                  BoxShadow(
                    color: tema.scaffoldBackgroundColor,
                    spreadRadius: AppMedida.borde,
                  ),
                ],
              ),
              child: SvgPicture.asset(
                marca.logoSobreFondoLogo,
                width: AppMedida.logoEnPortada,
                excludeFromSemantics: true,
              ),
            ),
          ),
          Positioned(
            left:
                AppEspacio.base +
                AppMedida.logoPortada +
                AppMedida.borde +
                AppEspacio.m,
            right: AppEspacio.base,
            bottom: 0,
            height: AppMedida.logoPortada / 2, // la franja bajo la foto
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                child: Text('UPSGlam', style: tema.textTheme.headlineSmall),
              ),
            ),
          ),
          if (alVolver != null)
            SafeArea(
              minimum: const EdgeInsets.all(AppEspacio.base),
              child: BotonRedondo(
                icono: Iconos.atras,
                descripcion: 'Volver a iniciar sesión',
                alPulsar: alVolver,
              ),
            ),
        ],
      ),
    );
  }
}
