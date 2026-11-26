import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../rutas/rutas.dart';
import 'barra_principal.dart';

/// Contenedor global de las pestañas: dibuja el menú por encima de ellas.
class ArmazonPrincipal extends StatefulWidget {
  const ArmazonPrincipal({super.key, required this.pestanas});

  final StatefulNavigationShell pestanas;

  @override
  State<ArmazonPrincipal> createState() => _ArmazonPrincipalState();
}

class _ArmazonPrincipalState extends State<ArmazonPrincipal> {
  bool _abriendoCamara = false;

  void _elegir(int indice) => widget.pestanas.goBranch(
    indice,
    // Tocar la pestaña activa vuelve a su inicio.
    initialLocation: indice == widget.pestanas.currentIndex,
  );

  Future<void> _abrirCamara() async {
    if (_abriendoCamara) return; // un doble toque no la abre dos veces
    _abriendoCamara = true;
    await context.push(Rutas.camara);
    _abriendoCamara = false;
  }

  @override
  Widget build(BuildContext context) {
    final actual = widget.pestanas.currentIndex;
    final hayTeclado = MediaQuery.viewInsetsOf(context).bottom > 0;
    return PopScope(
      canPop: actual == 0, // atrás en Perfil vuelve a Inicio
      onPopInvokedWithResult: (salio, _) {
        if (!salio) _elegir(0);
      },
      child: Scaffold(
        extendBody: true, // el menú flota sobre el contenido
        body: widget.pestanas,
        bottomNavigationBar: hayTeclado
            ? null
            : BarraPrincipal(
                actual: actual,
                alElegir: _elegir,
                alAbrirCamara: _abrirCamara,
              ),
      ),
    );
  }
}
