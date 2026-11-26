import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../componentes/zoom_en_sitio.dart';
import '../../componentes/app_icono.dart';
import '../../componentes/boton_principal.dart';
import '../../componentes/boton_redondo.dart';
import '../../componentes/imagen_app.dart';
import '../../componentes/selector_filtro.dart';
import '../../modelos/foto/foto.dart';
import '../../rutas/rutas.dart';
import '../../tema/app_theme.dart';
import 'editar_controller.dart';

class EditarPage extends StatelessWidget {
  const EditarPage({super.key, required this.foto});

  final Foto foto;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => EditarController(foto),
    child: const _EditarVista(),
  );
}

class _EditarVista extends StatelessWidget {
  const _EditarVista();

  @override
  Widget build(BuildContext context) {
    final editar = context.watch<EditarController>();
    final fondo = Theme.of(context).scaffoldBackgroundColor;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ZoomEnSitio(
                    child: ImagenApp.archivo(
                      editar.foto.ruta,
                      descripcion: 'Tu foto',
                    ),
                  ),
                  SafeArea(
                    minimum: const EdgeInsets.all(AppEspacio.base),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: BotonRedondo(
                        icono: Iconos.atras,
                        descripcion: 'Volver a la cámara',
                        alPulsar: () => context.pop(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ColoredBox(
              color: fondo,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: AppEspacio.base),
                child: Column(
                  children: [
                    const SizedBox(height: AppEspacio.base),
                    SelectorFiltro(
                      elegido: editar.foto.filtro,
                      alElegir: editar.elegirFiltro,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppEspacio.base,
                        AppEspacio.l,
                        AppEspacio.base,
                        0,
                      ),
                      child: BotonPrincipal(
                        texto: 'Publicar',
                        alPulsar: () => context.push(Rutas.publicar),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
