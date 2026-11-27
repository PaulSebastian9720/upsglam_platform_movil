import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:upsglam_movil/componentes/app_alerta.dart';
import 'package:upsglam_movil/componentes/boton_principal.dart';
import 'package:upsglam_movil/componentes/campo_texto.dart';
import 'package:upsglam_movil/componentes/encabezado_pagina.dart';
import 'package:upsglam_movil/componentes/estado_vacio.dart';
import 'package:upsglam_movil/componentes/imagen_app.dart';
import 'package:upsglam_movil/modelos/publicacion.dart';
import 'package:upsglam_movil/repositorios/publicaciones_repositorio.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/utilidades/validadores.dart';
import 'package:upsglam_movil/paginas/editar_publicacion/componentes/editor_carga.dart';
import 'package:upsglam_movil/paginas/editar_publicacion/componentes/interruptor_privada.dart';
import 'package:upsglam_movil/paginas/editar_publicacion/editar_publicacion_controller.dart';

class EditarPublicacionPage extends StatelessWidget {
  const EditarPublicacionPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => EditarPublicacionController(
      context.read<PublicacionesRepositorio>(),
      id,
    ),
    child: const _EditarPublicacionVista(),
  );
}

class _EditarPublicacionVista extends StatelessWidget {
  const _EditarPublicacionVista();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<EditarPublicacionController>();
    final publicacion = controlador.publicacion;
    final Widget contenido;
    if (publicacion != null) {
      contenido = _Formulario(publicacion: publicacion);
    } else if (controlador.fallo) {
      contenido = EstadoVacio(
        mensaje: 'No pudimos cargar esta publicación',
        accion: 'Reintentar',
        alPulsar: controlador.cargar,
      );
    } else {
      contenido = const SingleChildScrollView(
        padding: EdgeInsets.all(AppEspacio.base),
        child: EditorCarga(),
      );
    }
    return Scaffold(
      // El teclado tapa la parte de abajo y la página se desplaza.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppEspacio.base,
                AppEspacio.base,
                AppEspacio.base,
                0,
              ),
              child: EncabezadoPagina(titulo: 'Editar publicación'),
            ),
            Expanded(child: contenido),
          ],
        ),
      ),
    );
  }
}

class _Formulario extends StatefulWidget {
  const _Formulario({required this.publicacion});

  final Publicacion publicacion;

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _formulario = GlobalKey<FormState>();
  late final _texto = TextEditingController(text: widget.publicacion.texto);
  final _focoTexto = FocusNode();

  @override
  void dispose() {
    _texto.dispose();
    _focoTexto.dispose();
    super.dispose();
  }

  void _avisarFallo(String mensaje) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(mensaje)));

  Future<void> _guardar() async {
    final controlador = context.read<EditarPublicacionController>();
    if (controlador.ocupado) return;
    FocusScope.of(context).unfocus();
    if (!_formulario.currentState!.validate()) {
      _focoTexto.requestFocus();
      return;
    }
    final guardado = await controlador.guardar(_texto.text);
    if (!mounted) return;
    if (guardado) {
      context.pop();
    } else {
      _avisarFallo('No se pudieron guardar los cambios');
    }
  }

  Future<void> _eliminar() async {
    final controlador = context.read<EditarPublicacionController>();
    if (controlador.ocupado) return;
    FocusScope.of(context).unfocus();
    final confirma = await AppAlerta.mostrar(
      context,
      TipoAlerta.eliminarPublicacion,
    );
    if (!confirma || !mounted) return;
    final eliminada = await controlador.eliminar();
    if (!mounted) return;
    if (eliminada) {
      context.pop();
    } else {
      _avisarFallo('No se pudo eliminar la publicación');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final controlador = context.watch<EditarPublicacionController>();
    final publicacion = controlador.publicacion ?? widget.publicacion;
    return LayoutBuilder(
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: AppMedida.celdaAlto,
                            child: ImagenApp.recurso(
                              publicacion.imagen,
                              descripcion:
                                  'Foto con ${publicacion.filtro.nombre}',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppEspacio.m),
                        Expanded(
                          flex: 2,
                          child: CampoTexto(
                            etiqueta: 'Texto',
                            pista: 'Escribe algo sobre tu foto',
                            controlador: _texto,
                            foco: _focoTexto,
                            validador: Validadores.textoPublicacion,
                            lineas: 5,
                            accion: TextInputAction.newline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppEspacio.base),
                    InterruptorPrivada(
                      privada: controlador.privada,
                      alCambiar: controlador.ocupado
                          ? null
                          : controlador.cambiarPrivada,
                    ),
                    const Spacer(),
                    const SizedBox(height: AppEspacio.l),
                    BotonPrincipal(
                      texto: 'Guardar cambios',
                      cargando: controlador.guardando,
                      alPulsar: controlador.eliminando ? null : _guardar,
                    ),
                    const SizedBox(height: AppEspacio.m),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tema.colorScheme.error,
                      ),
                      onPressed: controlador.ocupado ? null : _eliminar,
                      child: controlador.eliminando
                          ? const SizedBox.square(
                              dimension: AppMedida.icono,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Eliminar publicación'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
