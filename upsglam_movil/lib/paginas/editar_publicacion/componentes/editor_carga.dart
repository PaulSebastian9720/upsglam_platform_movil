import 'package:flutter/material.dart';

import 'package:upsglam_movil/tema/app_theme.dart';

/// Bloques grises con la forma de la miniatura y el texto mientras carga.
class EditorCarga extends StatelessWidget {
  const EditorCarga({super.key});

  @override
  Widget build(BuildContext context) {
    final campo = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: AppMedida.celdaAlto,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: ColoredBox(color: campo)),
                const SizedBox(width: AppEspacio.m),
                Expanded(
                  flex: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: campo,
                      borderRadius: BorderRadius.circular(AppRadio.base),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppEspacio.l),
          Container(
            height: AppMedida.campo,
            decoration: BoxDecoration(
              color: campo,
              borderRadius: BorderRadius.circular(AppRadio.base),
            ),
          ),
        ],
      ),
    );
  }
}
