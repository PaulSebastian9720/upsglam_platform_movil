import 'package:flutter/material.dart';

import 'package:upsglam_movil/componentes/avatar_usuario.dart';
import 'package:upsglam_movil/modelos/comentario.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/utilidades/formatos.dart';

/// Un comentario: foto, usuario, cuándo y el texto completo debajo.
class FilaComentario extends StatelessWidget {
  const FilaComentario({super.key, required this.comentario});

  final Comentario comentario;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarUsuario(
          imagen: comentario.autor.avatar,
          usuario: comentario.autor.usuario,
          tamano: AppMedida.avatarComentario,
        ),
        const SizedBox(width: AppEspacio.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: comentario.autor.usuario,
                      style: tema.textTheme.titleMedium,
                    ),
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: Formatos.hace(comentario.creado),
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppEspacio.xs),
              Text(comentario.texto, style: tema.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
