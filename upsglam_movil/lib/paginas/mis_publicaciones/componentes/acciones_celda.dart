import 'package:flutter/material.dart';

import 'package:upsglam_movil/componentes/app_icono.dart';
import 'package:upsglam_movil/modelos/publicacion.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/paginas/mis_publicaciones/componentes/boton_celda.dart';

/// Lo que va sobre cada foto: velo si es privada y el botón de privacidad.
/// Para editar se toca la foto.
class AccionesCelda extends StatelessWidget {
  const AccionesCelda({
    super.key,
    required this.publicacion,
    required this.alCambiarPrivacidad,
  });

  final Publicacion publicacion;
  final VoidCallback alCambiarPrivacidad;

  @override
  Widget build(BuildContext context) {
    final nombre = publicacion.texto.isEmpty
        ? 'Foto con ${publicacion.filtro.nombre}'
        : publicacion.texto;
    final privada = publicacion.privada;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (privada)
          IgnorePointer(
            child: ColoredBox(color: Theme.of(context).colorScheme.scrim),
          ),
        Positioned(
          right: AppEspacio.xs,
          bottom: AppEspacio.xs,
          child: BotonCelda(
            icono: privada ? Iconos.privada : Iconos.publica,
            descripcion: privada
                ? 'Privada, hacer pública: $nombre'
                : 'Pública, hacer privada: $nombre',
            activo: privada,
            alPulsar: alCambiarPrivacidad,
          ),
        ),
      ],
    );
  }
}
