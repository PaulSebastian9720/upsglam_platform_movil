import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:upsglam_movil/repositorios/comentarios_repositorio.dart';
import 'package:upsglam_movil/repositorios/fotos_repositorio.dart';
import 'package:upsglam_movil/repositorios/perfil_repositorio.dart';
import 'package:upsglam_movil/repositorios/procesamiento_repositorio.dart';
import 'package:upsglam_movil/repositorios/publicaciones_repositorio.dart';
import 'package:upsglam_movil/repositorios/seguidos_repositorio.dart';
import 'package:upsglam_movil/rutas/app_router.dart';
import 'package:upsglam_movil/servicios/camara_service.dart';
import 'package:upsglam_movil/servicios/datos_prueba_service.dart';
import 'package:upsglam_movil/servicios/galeria_service.dart';
import 'package:upsglam_movil/servicios/imagen_service.dart';
import 'package:upsglam_movil/repositorios/preferencias_repositorio.dart';
import 'package:upsglam_movil/servicios/preferencias_service.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/tema/tema_controller.dart';

class UpsGlamApp extends StatefulWidget {
  const UpsGlamApp({super.key, this.fotos, this.tema});

  /// Solo las pruebas pasan otro.
  final FotosRepositorio? fotos;

  /// Ya cargado en `main` con el tema guardado; si falta, empieza oscuro.
  final TemaController? tema;

  @override
  State<UpsGlamApp> createState() => _UpsGlamAppState();
}

class _UpsGlamAppState extends State<UpsGlamApp> {
  final _router = crearRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  // Una sola fuente de datos de prueba para todos los repositorios.
  final _datos = DatosPruebaService();

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<FotosRepositorio>(
        create: (_) =>
            widget.fotos ??
            FotosRepositorio(
              CamaraService(),
              GaleriaService(),
              ImagenService(),
            ),
      ),
      Provider(create: (_) => PerfilRepositorio(_datos)),
      Provider(create: (_) => PublicacionesRepositorio(_datos)),
      Provider(create: (_) => ProcesamientoRepositorio(_datos)),
      Provider(create: (_) => SeguidosRepositorio(_datos)),
      Provider(create: (_) => ComentariosRepositorio(_datos)),
      ChangeNotifierProvider(
        create: (_) =>
            widget.tema ??
            TemaController(PreferenciasRepositorio(PreferenciasService())),
      ),
    ],
    child: Consumer<TemaController>(
      builder: (_, tema, _) => MaterialApp.router(
        title: 'UPSGlam',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro,
        darkTheme: AppTheme.oscuro,
        themeMode: tema.modo,
        routerConfig: _router,
        // Iconos de la barra del teléfono según el fondo; las pantallas sobre
        // fotos (login, cámara) ponen los suyos.
        builder: (context, hijo) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: Theme.of(context).brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: hijo!,
        ),
      ),
    ),
  );
}
