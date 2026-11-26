import 'package:flutter/material.dart';

import '../tema/app_theme.dart';
import 'app_icono.dart';
import 'imagen_app.dart';

/// Foto de perfil redonda; sin foto, el icono de perfil.
class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({
    super.key,
    required this.imagen,
    required this.usuario,
    this.tamano = AppMedida.avatarLista,
  });

  final String? imagen;
  final String usuario;
  final double tamano;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: tamano,
    child: ClipOval(
      child: imagen == null
          ? ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(child: AppIcono(Iconos.perfil, tamano: tamano / 2)),
            )
          : ImagenApp.recurso(imagen!, descripcion: 'Foto de $usuario'),
    ),
  );
}
