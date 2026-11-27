import 'package:flutter/material.dart';

import 'package:upsglam_movil/tema/app_theme.dart';

/// Hoja que sube desde abajo con Oscuro, Claro y Sistema. Devuelve el
/// elegido, o nulo si se cerró sin elegir.
class HojaTema extends StatelessWidget {
  const HojaTema._(this.actual);

  final ThemeMode actual;

  static const nombres = {
    ThemeMode.dark: 'Oscuro',
    ThemeMode.light: 'Claro',
    ThemeMode.system: 'Sistema',
  };

  static Future<ThemeMode?> mostrar(BuildContext context, ThemeMode actual) =>
      showModalBottomSheet<ThemeMode>(
        context: context,
        useSafeArea: true,
        builder: (_) => HojaTema._(actual),
      );

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppEspacio.base),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppEspacio.m),
          Container(
            width: AppMedida.agarraderaAncho,
            height: AppMedida.agarraderaAlto,
            decoration: BoxDecoration(
              color: tema.colorScheme.outline,
              borderRadius: BorderRadius.circular(AppMedida.agarraderaAlto),
            ),
          ),
          const SizedBox(height: AppEspacio.m),
          Text('Tema', style: tema.textTheme.titleMedium),
          const SizedBox(height: AppEspacio.s),
          RadioGroup<ThemeMode>(
            groupValue: actual,
            onChanged: (elegido) => Navigator.pop(context, elegido),
            child: Column(
              children: [
                for (final MapEntry(key: modo, value: nombre)
                    in nombres.entries)
                  RadioListTile<ThemeMode>(
                    value: modo,
                    title: Text(nombre, style: tema.textTheme.titleMedium),
                    activeColor: tema.colorScheme.primary,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppEspacio.base,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
