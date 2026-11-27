import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:upsglam_movil/componentes/app_icono.dart';
import 'package:upsglam_movil/componentes/encabezado_pagina.dart';
import 'package:upsglam_movil/rutas/rutas.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/paginas/configuracion/componentes/fila_opcion.dart';
import 'package:upsglam_movil/paginas/configuracion/componentes/hoja_tema.dart';
import 'package:upsglam_movil/tema/tema_controller.dart';

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final modo = context.watch<TemaController>();
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(AppEspacio.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const EncabezadoPagina(titulo: 'Configuración y actividad'),
            const SizedBox(height: AppEspacio.l),
            Expanded(
              child: ListView(
                children: [
                  FilaOpcion(
                    icono: Iconos.perfil,
                    texto: 'Editar perfil',
                    alPulsar: () => context.push(Rutas.editarPerfil),
                  ),
                  FilaOpcion(
                    icono: Iconos.publicaciones,
                    texto: 'Mis publicaciones',
                    alPulsar: () => context.push(Rutas.misPublicaciones),
                  ),
                  FilaOpcion(
                    icono: Iconos.tema,
                    texto: 'Tema',
                    valor: HojaTema.nombres[modo.modo],
                    alPulsar: () async {
                      final elegido = await HojaTema.mostrar(
                        context,
                        modo.modo,
                      );
                      if (elegido != null) await modo.elegir(elegido);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppEspacio.base),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: tema.colorScheme.error,
                minimumSize: const Size.fromHeight(AppMedida.toque),
              ),
              // Aún no hay sesión que cerrar: solo vuelve a la entrada.
              onPressed: () => context.go(Rutas.login),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
