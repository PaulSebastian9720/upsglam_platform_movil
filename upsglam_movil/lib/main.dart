import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:upsglam_movil/app.dart';
import 'package:upsglam_movil/repositorios/preferencias_repositorio.dart';
import 'package:upsglam_movil/servicios/preferencias_service.dart';
import 'package:upsglam_movil/tema/tema_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Todas las pantallas están diseñadas en vertical.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // El tema guardado se lee antes, para no mostrar uno y cambiar al otro.
  final tema = TemaController(PreferenciasRepositorio(PreferenciasService()));
  await tema.cargar();
  runApp(UpsGlamApp(tema: tema));
}
