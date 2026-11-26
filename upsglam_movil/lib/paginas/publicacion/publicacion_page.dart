import 'package:flutter/material.dart';

import '../../componentes/pagina_vacia.dart';

class PublicacionPage extends StatelessWidget {
  const PublicacionPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => const PaginaVacia(titulo: 'Publicación');
}
