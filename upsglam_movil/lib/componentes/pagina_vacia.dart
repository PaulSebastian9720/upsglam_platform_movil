import 'package:flutter/material.dart';

import '../tema/app_theme.dart';
import 'encabezado_pagina.dart';

/// Pantalla aún sin construir: solo permite saber dónde estás y volver.
/// Se borra cuando todas las páginas tengan su contenido.
class PaginaVacia extends StatelessWidget {
  const PaginaVacia({super.key, required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacio.base),
        child: Align(
          alignment: Alignment.topCenter,
          child: EncabezadoPagina(titulo: titulo),
        ),
      ),
    ),
  );
}
