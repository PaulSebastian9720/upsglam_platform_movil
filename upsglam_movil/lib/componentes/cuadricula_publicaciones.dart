import 'package:flutter/material.dart';

import 'package:upsglam_movil/modelos/publicacion.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/componentes/imagen_app.dart';

/// Cuadrícula de 3 columnas para un `CustomScrollView`: perfil, perfil de
/// otra persona y mis publicaciones.
class CuadriculaPublicaciones extends StatelessWidget {
  const CuadriculaPublicaciones({
    super.key,
    required this.publicaciones,
    this.alPulsar,
    this.encima,
  });

  final List<Publicacion> publicaciones;
  final ValueChanged<Publicacion>? alPulsar;

  /// Lo que se dibuja sobre cada foto, como la marca de privada.
  final Widget Function(Publicacion)? encima;

  @override
  Widget build(BuildContext context) => SliverGrid.builder(
    itemCount: publicaciones.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: AppMedida.separacionCelda,
      crossAxisSpacing: AppMedida.separacionCelda,
      mainAxisExtent: AppMedida.celdaAlto,
    ),
    itemBuilder: (context, i) {
      final publicacion = publicaciones[i];
      return Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: alPulsar == null ? null : () => alPulsar!(publicacion),
            child: ImagenApp.recurso(
              publicacion.imagen,
              descripcion: publicacion.texto.isEmpty
                  ? 'Foto con ${publicacion.filtro.nombre}'
                  : publicacion.texto,
            ),
          ),
          if (encima != null) encima!(publicacion),
        ],
      );
    },
  );
}
