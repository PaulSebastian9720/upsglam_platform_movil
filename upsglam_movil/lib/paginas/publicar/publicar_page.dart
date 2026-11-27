import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:upsglam_movil/componentes/boton_principal.dart';
import 'package:upsglam_movil/componentes/campo_texto.dart';
import 'package:upsglam_movil/componentes/encabezado_pagina.dart';
import 'package:upsglam_movil/componentes/imagen_app.dart';
import 'package:upsglam_movil/modelos/filtro.dart';
import 'package:upsglam_movil/modelos/foto.dart';
import 'package:upsglam_movil/paginas/publicar/publicar_controller.dart';
import 'package:upsglam_movil/rutas/rutas.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/utilidades/validadores.dart';

/// Nueva publicación: la foto con su filtro y un texto.
class PublicarPage extends StatelessWidget {
  const PublicarPage({super.key, required this.foto});

  final Foto foto;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => PublicarController(context.read(), foto),
    child: const _PublicarVista(),
  );
}

class _PublicarVista extends StatefulWidget {
  const _PublicarVista();

  @override
  State<_PublicarVista> createState() => _PublicarVistaState();
}

class _PublicarVistaState extends State<_PublicarVista> {
  final _formulario = GlobalKey<FormState>();
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    FocusScope.of(context).unfocus();
    if (!_formulario.currentState!.validate()) return;
    final publicado = await context.read<PublicarController>().publicar(
      _texto.text,
    );
    if (!mounted) return;
    if (publicado) {
      // Cierra cámara, edición y esta pantalla: la publicación ya está en
      // Inicio y en tu perfil.
      context.go(Rutas.inicio);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo publicar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final control = context.watch<PublicarController>();
    final foto = control.foto;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, limites) => SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: limites.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(AppEspacio.base),
                  child: Form(
                    key: _formulario,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const EncabezadoPagina(titulo: 'Nueva publicación'),
                        const SizedBox(height: AppEspacio.l),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: AppMedida.miniaturaPublicarAncho,
                              height: AppMedida.miniaturaPublicarAlto,
                              child: ImagenApp.recurso(
                                foto.ruta,
                                descripcion: foto.filtro == Filtro.original
                                    ? 'Tu foto'
                                    : 'Tu foto con ${foto.filtro.nombre}',
                              ),
                            ),
                            const SizedBox(width: AppEspacio.m),
                            Expanded(
                              child: CampoTexto(
                                etiqueta: 'Escribe algo sobre tu foto',
                                controlador: _texto,
                                validador: Validadores.textoPublicacion,
                                lineas: 7,
                                accion: TextInputAction.newline,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: AppEspacio.base),
                        BotonPrincipal(
                          texto: 'Publicar',
                          cargando: control.publicando,
                          alPulsar: _publicar,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
