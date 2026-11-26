import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:upsglam_movil/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Todas las pantallas están diseñadas en vertical.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const UpsGlamApp());
}
