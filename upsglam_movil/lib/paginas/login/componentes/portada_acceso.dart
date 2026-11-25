import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../tema/app_theme.dart';

/// Foto del campus con los filtros, el logo montado sobre su borde y el nombre.
class PortadaAcceso extends StatelessWidget {
  const PortadaAcceso({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
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
                color: tema.colorScheme.primary,
                borderRadius: BorderRadius.circular(AppRadio.hoja),
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
        ],
      ),
    );
  }
}
