import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../componentes/boton_principal.dart';
import '../../componentes/campo_texto.dart';
import '../../componentes/encabezado_pagina.dart';
import '../../componentes/estado_vacio.dart';
import '../../modelos/perfil.dart';
import '../../repositorios/perfil_repositorio.dart';
import '../../tema/app_theme.dart';
import '../../utilidades/validadores.dart';
import 'componentes/cambiar_foto.dart';
import 'componentes/formulario_carga.dart';
import 'editar_perfil_controller.dart';

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
  late final _usuario = TextEditingController(text: widget.perfil.usuario);
  late final _descripcion = TextEditingController(
    text: widget.perfil.descripcion,
  );
  final _focoUsuario = FocusNode();
  final _focoDescripcion = FocusNode();

  @override
  void dispose() {
    _usuario.dispose();
    _descripcion.dispose();
    _focoUsuario.dispose();
    _focoDescripcion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final controlador = context.read<EditarPerfilController>();
    if (controlador.guardando) return;
    FocusScope.of(context).unfocus();
    if (!_formulario.currentState!.validate()) {
      final primero = Validadores.usuario(_usuario.text) != null
          ? _focoUsuario
          : _focoDescripcion;
      primero.requestFocus();
      return;
    }
    final guardado = await controlador.guardar(
      usuario: _usuario.text,
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
                      etiqueta: 'Usuario',
                      controlador: _usuario,
                      foco: _focoUsuario,
                      validador: Validadores.usuario,
                      autocompletar: const [AutofillHints.username],
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
