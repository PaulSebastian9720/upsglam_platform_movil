import 'package:flutter/material.dart';
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
import 'package:upsglam_movil/tema/app_theme.dart';

class UpsGlamApp extends StatefulWidget {
  const UpsGlamApp({super.key, this.fotos});

  /// Solo las pruebas pasan otro.
  final FotosRepositorio? fotos;

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
            widget.fotos ?? FotosRepositorio(CamaraService(), GaleriaService()),
      ),
      Provider(create: (_) => PerfilRepositorio(_datos)),
      Provider(create: (_) => PublicacionesRepositorio(_datos)),
      Provider(create: (_) => ProcesamientoRepositorio(_datos)),
      Provider(create: (_) => SeguidosRepositorio(_datos)),
      Provider(create: (_) => ComentariosRepositorio(_datos)),
    ],
    child: MaterialApp.router(
      title: 'UPSGlam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.oscuro,
      routerConfig: _router,
    ),
  );
}
