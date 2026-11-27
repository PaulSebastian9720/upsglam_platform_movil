import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:upsglam_movil/componentes/boton_principal.dart';
import 'package:upsglam_movil/componentes/campo_texto.dart';
import 'package:upsglam_movil/componentes/encabezado_pagina.dart';
import 'package:upsglam_movil/componentes/estado_vacio.dart';
import 'package:upsglam_movil/modelos/perfil.dart';
import 'package:upsglam_movil/repositorios/perfil_repositorio.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/utilidades/validadores.dart';
import 'package:upsglam_movil/paginas/editar_perfil/componentes/cambiar_foto.dart';
import 'package:upsglam_movil/paginas/editar_perfil/componentes/formulario_carga.dart';
import 'package:upsglam_movil/paginas/editar_perfil/editar_perfil_controller.dart';

class EditarPerfilPage extends StatelessWidget {
  const EditarPerfilPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        EditarPerfilController(context.read<PerfilRepositorio>()),
    child: const _EditarPerfilVista(),
  );
}

class _EditarPerfilVista extends StatelessWidget {
  const _EditarPerfilVista();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<EditarPerfilController>();
    final perfil = controlador.perfil;
    final Widget contenido;
    if (perfil != null) {
      contenido = _Formulario(perfil: perfil);
    } else if (controlador.fallo) {
      contenido = EstadoVacio(
        mensaje: 'No pudimos cargar tu perfil',
        accion: 'Reintentar',
        alPulsar: controlador.cargar,
      );
    } else {
      contenido = const SingleChildScrollView(
        padding: EdgeInsets.all(AppEspacio.base),
        child: FormularioCarga(),
      );
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
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
                child: EncabezadoPagina(titulo: 'Editar perfil'),
              ),
              Expanded(child: contenido),
            ],
          ),
        ),
      ),
    );
  }
}

class _Formulario extends StatefulWidget {
  const _Formulario({required this.perfil});

  final Perfil perfil;

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _formulario = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.perfil.nombre);
  // Usuario y correo solo se muestran: no se pueden cambiar.
  late final _usuario = TextEditingController(text: widget.perfil.usuario);
  late final _correo = TextEditingController(text: widget.perfil.correo ?? '');
  late final _descripcion = TextEditingController(
    text: widget.perfil.descripcion,
  );
  final _focoNombre = FocusNode();
  final _focoDescripcion = FocusNode();

  @override
  void dispose() {
    _nombre.dispose();
    _usuario.dispose();
    _correo.dispose();
    _descripcion.dispose();
    _focoNombre.dispose();
    _focoDescripcion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final controlador = context.read<EditarPerfilController>();
    if (controlador.guardando) return;
    FocusScope.of(context).unfocus();
    if (!_formulario.currentState!.validate()) {
      final primero = Validadores.nombre(_nombre.text) != null
          ? _focoNombre
          : _focoDescripcion;
      primero.requestFocus();
      return;
    }
    final guardado = await controlador.guardar(
      nombre: _nombre.text,
      descripcion: _descripcion.text,
    );
    if (!mounted) return;
    if (guardado) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron guardar los cambios')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<EditarPerfilController>();
    final perfil = controlador.perfil ?? widget.perfil;
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
                    CambiarFoto(
                      imagen: perfil.avatar,
                      usuario: perfil.usuario,
                      alPulsar: controlador.guardando
                          ? null
                          : controlador.cambiarFoto,
                    ),
                    const SizedBox(height: AppEspacio.l),
                    CampoTexto(
                      etiqueta: 'Nombre completo',
                      pista: 'Cómo te llamas',
                      controlador: _nombre,
                      foco: _focoNombre,
                      validador: Validadores.nombre,
                      autocompletar: const [AutofillHints.name],
                    ),
                    const SizedBox(height: AppEspacio.s),
                    CampoTexto(
                      etiqueta: 'Usuario',
                      controlador: _usuario,
                      soloLectura: true,
                    ),
                    const SizedBox(height: AppEspacio.s),
                    CampoTexto(
                      etiqueta: 'Correo',
                      controlador: _correo,
                      soloLectura: true,
                    ),
                    const SizedBox(height: AppEspacio.s),
                    CampoTexto(
                      etiqueta: 'Descripción',
                      pista: 'Cuéntale a la gente quién eres',
                      controlador: _descripcion,
                      foco: _focoDescripcion,
                      validador: Validadores.descripcion,
                      lineas: 4,
                      accion: TextInputAction.newline,
                    ),
                    const Spacer(),
                    const SizedBox(height: AppEspacio.base),
                    BotonPrincipal(
                      texto: 'Guardar cambios',
                      cargando: controlador.guardando,
                      alPulsar: _guardar,
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
