import 'package:flutter/material.dart';

import '../../../componentes/avatar_usuario.dart';
import '../../../modelos/usuario/perfil.dart';
import '../../../tema/app_theme.dart';

/// Una persona que sigo: foto, usuario y el botón para seguir o dejar de
/// seguir. Tocar la fila abre su perfil.
class FilaSeguido extends StatelessWidget {
  const FilaSeguido({
    super.key,
    required this.perfil,
    required this.alAbrir,
    required this.alAlternar,
  });

  final Perfil perfil;
  final VoidCallback alAbrir;
  final VoidCallback alAlternar;

  static const _seguir = 'Seguir';
  static const _dejar = 'Dejar de seguir';

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final texto = perfil.loSigo ? _dejar : _seguir;
    // Los dos botones reservan el ancho del texto más largo: no salta nada.
    final etiqueta = Stack(
      alignment: Alignment.center,
      children: [
        const Visibility.maintain(visible: false, child: Text(_dejar)),
        Text(texto),
      ],
    );
    const forma = Size(AppMedida.toque, AppMedida.boton);
    return InkWell(
      onTap: alAbrir,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppEspacio.base,
          vertical: AppEspacio.s,
        ),
        child: Row(
          children: [
            AvatarUsuario(
              imagen: perfil.avatar,
              usuario: perfil.usuario,
              tamano: AppMedida.avatarLista,
            ),
            const SizedBox(width: AppEspacio.m),
            Expanded(
              child: Text(
                perfil.usuario,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: AppEspacio.m),
            Semantics(
              label: perfil.loSigo
                  ? 'Dejar de seguir a ${perfil.usuario}'
                  : 'Seguir a ${perfil.usuario}',
              child: perfil.loSigo
                  ? OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: forma),
                      onPressed: alAlternar,
                      child: ExcludeSemantics(child: etiqueta),
                    )
                  : FilledButton(
                      style: FilledButton.styleFrom(minimumSize: forma),
                      onPressed: alAlternar,
                      child: ExcludeSemantics(child: etiqueta),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
