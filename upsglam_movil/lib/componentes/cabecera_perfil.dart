import 'package:flutter/material.dart';

import 'package:upsglam_movil/modelos/perfil.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/componentes/avatar_usuario.dart';
import 'package:upsglam_movil/componentes/visor_imagen.dart';

/// Foto, cifras y descripción de un perfil, propio o de otra persona.
class CabeceraPerfil extends StatelessWidget {
  const CabeceraPerfil({
    super.key,
    required this.perfil,
    this.mostrarUsuario = true,
    this.alPulsarSeguidores,
    this.alPulsarSeguidos,
  });

  final Perfil perfil;

  /// En el perfil de otra persona el nombre ya va en el título.
  final bool mostrarUsuario;

  /// Solo en el perfil propio: abre la lista de seguidores.
  final VoidCallback? alPulsarSeguidores;

  /// Solo en el perfil propio: muestra la cifra de seguidos y abre la lista.
  final VoidCallback? alPulsarSeguidos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Tocar la foto de perfil la abre a pantalla completa.
            Semantics(
              button: perfil.avatar != null,
              label: 'Ver foto de perfil',
              child: GestureDetector(
                onTap: perfil.avatar == null
                    ? null
                    : () => VisorImagen.abrir(
                        context,
                        ruta: perfil.avatar!,
                        descripcion: 'Foto de ${perfil.usuario}',
                      ),
                child: AvatarUsuario(
                  imagen: perfil.avatar,
                  usuario: perfil.usuario,
                  tamano: AppMedida.avatarPerfil,
                ),
              ),
            ),
            const SizedBox(width: AppEspacio.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mostrarUsuario) ...[
                    Text(
                      perfil.usuario,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppEspacio.s),
                  ],
                  Wrap(
                    spacing: AppEspacio.base,
                    runSpacing: AppEspacio.s,
                    children: [
                      _Cifra(perfil.publicaciones, 'publicaciones'),
                      _Cifra(perfil.meGusta, 'me gusta'),
                      _Cifra(
                        perfil.seguidores,
                        'seguidores',
                        alPulsar: alPulsarSeguidores,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (perfil.descripcion.isNotEmpty) ...[
          const SizedBox(height: AppEspacio.m),
          Text(perfil.descripcion, style: tema.textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _Cifra extends StatelessWidget {
  const _Cifra(this.valor, this.texto, {this.alPulsar});

  final int valor;
  final String texto;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cifra = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$valor', style: tema.textTheme.titleLarge),
        Text(texto, style: tema.textTheme.bodySmall),
      ],
    );
    if (alPulsar == null) return cifra;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(AppRadio.base),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppMedida.toque),
          child: cifra,
        ),
      ),
    );
  }
}
