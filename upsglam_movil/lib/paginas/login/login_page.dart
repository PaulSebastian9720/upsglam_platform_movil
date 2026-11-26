import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../componentes/boton_principal.dart';
import '../../componentes/campo_texto.dart';
import '../../rutas/rutas.dart';
import '../../tema/app_theme.dart';
import '../../utilidades/validadores.dart';
import '../../componentes/portada_acceso.dart';
import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => LoginController(),
    child: const _LoginVista(),
  );
}

class _LoginVista extends StatefulWidget {
  const _LoginVista();

  @override
  State<_LoginVista> createState() => _LoginVistaState();
}

class _LoginVistaState extends State<_LoginVista> {
  final _correo = TextEditingController();
  final _clave = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final pasa = await context.read<LoginController>().entrar();
    if (pasa && mounted) context.go(Rutas.inicio);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cargando = context.watch<LoginController>().cargando;
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
                    const PortadaAcceso(),
                    Expanded(
                      child: SafeArea(
                        top: false,
                        minimum: const EdgeInsets.all(AppEspacio.base),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Inicia sesión',
                              style: tema.textTheme.headlineLarge,
                            ),
                            const SizedBox(height: AppEspacio.l),
                            AutofillGroup(
                              child: Column(
                                children: [
                                  CampoTexto(
                                    etiqueta: 'Correo',
                                    pista: 'nombre@correo.com',
                                    controlador: _correo,
                                    validador: Validadores.correo,
                                    teclado: TextInputType.emailAddress,
                                    autocompletar: const [AutofillHints.email],
                                  ),
                                  const SizedBox(height: AppEspacio.s),
                                  CampoTexto(
                                    etiqueta: 'Contraseña',
                                    pista: 'Tu contraseña',
                                    controlador: _clave,
                                    validador: Validadores.claveObligatoria,
                                    esClave: true,
                                    accion: TextInputAction.done,
                                    autocompletar: const [
                                      AutofillHints.password,
                                    ],
                                    alEnviar: _entrar,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppEspacio.s),
                            BotonPrincipal(
                              texto: 'Iniciar sesión',
                              cargando: cargando,
                              alPulsar: _entrar,
                            ),
                            const Spacer(),
                            const SizedBox(height: AppEspacio.l),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '¿Aún no tienes cuenta?',
                                  style: tema.textTheme.bodyLarge?.copyWith(
                                    color: tema.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.push(Rutas.registro),
                                  child: const Text('Crear cuenta'),
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
