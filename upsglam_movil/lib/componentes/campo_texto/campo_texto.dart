import 'package:flutter/material.dart';

import '../../tema/app_theme.dart';
import '../app_icono/app_icono.dart';

/// Campo con etiqueta arriba. Se valida al salir y la línea del error está
/// siempre reservada, para que nada se mueva cuando aparece.
class CampoTexto extends StatefulWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.pista,
    this.validador,
    this.teclado,
    this.accion = TextInputAction.next,
    this.autocompletar,
    this.esClave = false,
    this.alEnviar,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final String? pista;
  final FormFieldValidator<String>? validador;
  final TextInputType? teclado;
  final TextInputAction accion;
  final Iterable<String>? autocompletar;
  final bool esClave;
  final VoidCallback? alEnviar;

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  late bool _oculta = widget.esClave;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    // El teclado se dibuja sobre la página: se deja ese margen para que el
    // campo activo siempre quede visible.
    final teclado = MediaQuery.viewInsetsOf(context).bottom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Text(widget.etiqueta, style: tema.textTheme.bodySmall),
        ),
        const SizedBox(height: AppEspacio.xs),
        Semantics(
          label: widget.etiqueta,
          child: TextFormField(
            controller: widget.controlador,
            validator: widget.validador,
            autovalidateMode: AutovalidateMode.onUnfocus,
            keyboardType: widget.teclado,
            textInputAction: widget.accion,
            autofillHints: widget.autocompletar,
            obscureText: _oculta,
            autocorrect: false,
            enableSuggestions: !widget.esClave,
            style: tema.textTheme.bodyLarge,
            scrollPadding: EdgeInsets.all(
              AppEspacio.l,
            ).copyWith(bottom: teclado + AppEspacio.xl),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onFieldSubmitted: (_) => widget.alEnviar?.call(),
            decoration: InputDecoration(
              hintText: widget.pista,
              helperText: ' ',
              suffixIcon: widget.esClave
                  ? IconButton(
                      tooltip: _oculta
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: () => setState(() => _oculta = !_oculta),
                      icon: AppIcono(
                        _oculta ? Iconos.verClave : Iconos.ocultarClave,
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
