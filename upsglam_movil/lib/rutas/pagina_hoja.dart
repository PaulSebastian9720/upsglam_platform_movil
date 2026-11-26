import 'package:flutter/material.dart';

/// Ruta que se abre como hoja desde abajo, sobre la pantalla actual.
class PaginaHoja<T> extends Page<T> {
  const PaginaHoja({super.key, required this.child});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => ModalBottomSheetRoute<T>(
    settings: this,
    isScrollControlled: true, // puede subir hasta llenar la pantalla
    useSafeArea: true,
    builder: (_) => child,
  );
}
