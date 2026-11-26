import 'package:flutter/material.dart';

import '../../componentes/pagina_vacia.dart';

class EditarPublicacionPage extends StatelessWidget {
  const EditarPublicacionPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => const PaginaVacia(titulo: 'Editar publicación');
}
