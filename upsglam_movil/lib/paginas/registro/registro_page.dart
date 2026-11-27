import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:upsglam_movil/componentes/boton_principal.dart';
import 'package:upsglam_movil/componentes/campo_texto.dart';
import 'package:upsglam_movil/rutas/rutas.dart';
import 'package:upsglam_movil/tema/app_theme.dart';
import 'package:upsglam_movil/utilidades/validadores.dart';
import 'package:upsglam_movil/componentes/portada_acceso.dart';
import 'package:upsglam_movil/paginas/registro/registro_controller.dart';

class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => RegistroController(context.read()),
    child: const _RegistroVista(),
  );
}

class _RegistroVista extends StatefulWidget {
  const _RegistroVista();

  @override
  State<_RegistroVista> createState() => _RegistroVistaState();
}

class _RegistroVistaState extends State<_RegistroVista> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _usuario = TextEditingController();

  /// El último usuario que el servidor dijo que ya existe.
  String? _ocupado;
  final _clave = TextEditingController();
  final _confirmacion = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _usuario.dispose();
    _clave.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  String? _validarUsuario(String? valor) =>
      Validadores.usuario(valor) ??
      (_ocupado != null && (valor ?? '').trim().toLowerCase() == _ocupado
          ? Validadores.usuarioOcupado
          : null);

  Future<void> _crear() async {
    FocusScope.of(context).unfocus();
    if (!_formulario.currentState!.validate()) return;
    final resultado = await context.read<RegistroController>().crear(
      usuario: _usuario.text,
    );
    if (!mounted) return;
    switch (resultado) {
      case ResultadoRegistro.creada:
        context.go(Rutas.inicio);
      case ResultadoRegistro.usuarioOcupado:
        // El error aparece bajo el campo Usuario, sin mover nada.
        _ocupado = _usuario.text.trim().toLowerCase();
        _formulario.currentState!.validate();
      case ResultadoRegistro.fallo:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo crear la cuenta')),
        );
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cargando = context.watch<RegistroController>().cargando;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // El teclado tapa la parte de abajo en vez de empujar los botones.
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, limites) => SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: limites.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PortadaAcceso(alVolver: () => context.pop()),
                    Expanded(
                      child: SafeArea(
                        top: false,
                        minimum: const EdgeInsets.all(AppEspacio.base),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Crea tu cuenta',
                              style: tema.textTheme.headlineLarge,
                            ),
                            const SizedBox(height: AppEspacio.l),
                            AutofillGroup(
                              child: Form(
                                key: _formulario,
                                child: Column(
                                  children: [
                                    CampoTexto(
                                      etiqueta: 'Nombre completo',
                                      pista: 'Cómo te llamas',
                                      controlador: _nombre,
                                      validador: Validadores.nombre,
                                      autocompletar: const [AutofillHints.name],
                                    ),
                                    const SizedBox(height: AppEspacio.s),
                                    CampoTexto(
                                      etiqueta: 'Correo',
                                      pista: 'nombre@correo.com',
                                      controlador: _correo,
                                      validador: Validadores.correo,
                                      teclado: TextInputType.emailAddress,
                                      autocompletar: const [
                                        AutofillHints.email,
                                      ],
                                    ),
                                    const SizedBox(height: AppEspacio.s),
                                    CampoTexto(
                                      etiqueta: 'Usuario',
                                      pista: 'Así te verán los demás',
                                      controlador: _usuario,
                                      validador: _validarUsuario,
                                      autocompletar: const [
                                        AutofillHints.newUsername,
                                      ],
                                    ),
                                    const SizedBox(height: AppEspacio.s),
                                    CampoTexto(
                                      etiqueta: 'Contraseña',
                                      pista:
                                          'Mínimo ${Validadores.minimoClave} caracteres',
                                      controlador: _clave,
                                      validador: Validadores.claveNueva,
                                      esClave: true,
                                      accion: TextInputAction.next,
                                      autocompletar: const [
                                        AutofillHints.newPassword,
                                      ],
                                    ),
                                    const SizedBox(height: AppEspacio.s),
                                    CampoTexto(
                                      etiqueta: 'Confirmar contraseña',
                                      pista: 'Vuelve a escribirla',
                                      controlador: _confirmacion,
                                      validador: Validadores.confirmacion(
                                        () => _clave.text,
                                      ),
                                      esClave: true,
                                      accion: TextInputAction.done,
                                      autocompletar: const [
                                        AutofillHints.newPassword,
                                      ],
                                      alEnviar: _crear,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppEspacio.s),
                            BotonPrincipal(
                              texto: 'Crear cuenta',
                              cargando: cargando,
                              alPulsar: _crear,
                            ),
                            const Spacer(),
                            const SizedBox(height: AppEspacio.l),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '¿Ya tienes cuenta?',
                                  style: tema.textTheme.bodyLarge?.copyWith(
                                    color: tema.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: const Text('Iniciar sesión'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
