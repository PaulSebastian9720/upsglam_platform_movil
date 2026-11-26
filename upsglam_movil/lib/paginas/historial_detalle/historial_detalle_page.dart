import 'package:flutter/material.dart';

import '../../componentes/pagina_vacia.dart';

class HistorialDetallePage extends StatelessWidget {
  const HistorialDetallePage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => const PaginaVacia(titulo: 'Resultado');
}
