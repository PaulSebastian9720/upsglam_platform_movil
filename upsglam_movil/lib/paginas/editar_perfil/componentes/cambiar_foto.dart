import 'package:flutter/material.dart';

import '../../../componentes/app_icono.dart';
import '../../../componentes/avatar_usuario.dart';
import '../../../tema/app_theme.dart';

/// Avatar grande con la marca de cámara y el texto "Cambiar foto".
class CambiarFoto extends StatelessWidget {
  const CambiarFoto({
    super.key,
    required this.imagen,
    required this.usuario,
    required this.alPulsar,
  });

  final String? imagen;
  final String usuario;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Semantics(
        button: true,
        label: 'Cambiar foto',
        excludeSemantics: true,
        child: InkWell(
          onTap: alPulsar,
          borderRadius: BorderRadius.circular(AppRadio.base),
          child: Padding(
            padding: const EdgeInsets.all(AppEspacio.s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    AvatarUsuario(
                      imagen: imagen,
                      usuario: usuario,
                      tamano: AppMedida.avatarEditar,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: AppMedida.toque,
                        height: AppMedida.toque,
                        decoration: BoxDecoration(
                          color: tema.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: tema.scaffoldBackgroundColor,
                            width: AppMedida.borde,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: AppIcono(
                          Iconos.camara,
                          tamano: AppMedida.icono,
                          color: tema.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppEspacio.m),
                Text(
                  'Cambiar foto',
                  style: tema.textTheme.labelLarge?.copyWith(
                    color: tema.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
