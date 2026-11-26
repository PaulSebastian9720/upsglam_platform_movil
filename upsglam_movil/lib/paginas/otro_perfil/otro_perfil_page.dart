import 'package:flutter/material.dart';

import '../../componentes/pagina_vacia.dart';

class OtroPerfilPage extends StatelessWidget {
  const OtroPerfilPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => const PaginaVacia(titulo: 'Usuario');
}
