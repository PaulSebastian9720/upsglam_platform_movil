import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositorios/fotos/fotos_repositorio.dart';
import 'rutas/app_router.dart';
import 'servicios/camara/camara_service.dart';
import 'servicios/galeria/galeria_service.dart';
import 'tema/app_theme.dart';

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

  @override
  Widget build(BuildContext context) => Provider<FotosRepositorio>(
    create: (_) =>
        widget.fotos ?? FotosRepositorio(CamaraService(), GaleriaService()),
    child: MaterialApp.router(
      title: 'UPSGlam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.oscuro,
      routerConfig: _router,
    ),
  );
}
