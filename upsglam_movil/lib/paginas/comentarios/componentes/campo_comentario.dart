import 'package:flutter/material.dart';

import '../../../componentes/app_icono.dart';
import '../../../tema/app_theme.dart';

/// Campo para escribir: crece hacia abajo con el texto hasta unas líneas y
/// después se desplaza por dentro. El botón solo se activa con texto.
class CampoComentario extends StatefulWidget {
  const CampoComentario({
    super.key,
    required this.enviando,
    required this.alEnviar,
  });

  final bool enviando;

  /// Devuelve si se publicó, para limpiar el campo.
  final Future<bool> Function(String texto) alEnviar;

  @override
  State<CampoComentario> createState() => _CampoComentarioState();
}

class _CampoComentarioState extends State<CampoComentario> {
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (await widget.alEnviar(_texto.text) && mounted) _texto.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tema.colorScheme.surface,
        border: Border(top: BorderSide(color: tema.colorScheme.outline)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(AppEspacio.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _texto,
                minLines: 1,
                maxLines: AppMedida.lineasComentario,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: tema.textTheme.bodyLarge,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Escribe un comentario',
                ),
              ),
            ),
            const SizedBox(width: AppEspacio.s),
            IconButton.filled(
              tooltip: 'Enviar comentario',
              onPressed: widget.enviando || _texto.text.trim().isEmpty
                  ? null
                  : _enviar,
              style: IconButton.styleFrom(
                fixedSize: const Size.square(AppMedida.toque),
                backgroundColor: tema.colorScheme.primary,
                disabledBackgroundColor:
                    tema.colorScheme.surfaceContainerHighest,
              ),
              icon: AppIcono(
                Iconos.enviar,
                color: widget.enviando || _texto.text.trim().isEmpty
                    ? tema.colorScheme.onSurfaceVariant
                    : tema.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
