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
import 'registro_controller.dart';

class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => RegistroController(),
    child: const _RegistroVista(),
  );
}

class _RegistroVista extends StatefulWidget {
  const _RegistroVista();

  @override
  State<_RegistroVista> createState() => _RegistroVistaState();
}

class _RegistroVistaState extends State<_RegistroVista> {
  final _correo = TextEditingController();
  final _usuario = TextEditingController();
  final _clave = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _usuario.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final pasa = await context.read<RegistroController>().crear();
    if (pasa && mounted) context.go(Rutas.inicio);
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
                                    etiqueta: 'Usuario',
                                    pista: 'Así te verán los demás',
                                    controlador: _usuario,
                                    validador: Validadores.usuario,
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
                                    accion: TextInputAction.done,
                                    autocompletar: const [
                                      AutofillHints.newPassword,
                                    ],
                                    alEnviar: _crear,
                                  ),
                                ],
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
