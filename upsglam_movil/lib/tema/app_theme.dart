import 'package:flutter/material.dart';

/// Único lugar de la app donde se escriben colores, medidas y letras.
abstract final class AppColors {
  static const fondo = Color(0xFF101114);
  static const superficie = Color(0xFF1B1C21);
  static const campo = Color(0xFF2A2C33);
  static const linea = Color(0xFF5A5D67);
  static const texto = Color(0xFFF5F5F7);
  static const texto2 = Color(0xFFB4B6BE);
  static const amarillo = Color(0xFFFFC72C);
  static const azul = Color(0xFF013871);
  static const azulClaro = Color(0xFF8FB4FF);
  static const rojo = Color(0xFFC92A3A);
  static const rojoTexto = Color(0xFFFF9299);
  static const meGusta = Color(0xFFFF5A66);
  static const verde = Color(0xFF6FE3B2);
  static const velo = Color(0xB808090B);
}

abstract final class AppEspacio {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const base = 16.0; // padding fijo de pantallas, tarjetas y campos
  static const l = 24.0;
  static const xl = 32.0;
}

abstract final class AppRadio {
  static const base = 10.0; // botones, campos, etiquetas, miniaturas
  static const hoja = 20.0; // hojas inferiores, alertas y logo
  static const imagen = 0.0; // fotos: siempre rectas
}

abstract final class AppMedida {
  static const boton = 46.0;
  static const campo = 52.0;
  static const toque = 48.0; // área mínima de toque
  static const icono = 24.0;
  static const portada = 192.0;
  static const logoPortada = 84.0;
  static const borde = 5.0; // anillo que separa del fondo
  static const barra = 72.0;
  static const barraAncho = 292.0;
  static const bola = 80.0; // cámara del menú
  static const logoBola = 55.0;
  static const disparo = 90.0; // tomar foto
  static const control = 60.0; // galería, filtros y girar
  static const rueda = 64.0;
  static const bordeRueda = 3.0;
  static const iconoAlerta = 40.0;
  static const avatarFeed = 36.0;
  static const avatarComentario = 38.0;
  static const avatarLista = 54.0;
  static const avatarPerfil = 88.0;
  static const avatarEditar = 132.0;
  static const miniatura = 64.0; // historial
  static const celdaAlto = 150.0; // cuadrícula de perfil, 3 columnas
  static const separacionCelda = 2.0;
  static const insignia = 26.0; // círculo sobre una foto de la cuadrícula
  static const proporcionPublicacion = 5 / 6; // ancho entre alto
  static const pestana = 48.0;
  static const lineaPestana = 3.0;
  static const bolaSube = 5.0; // cuánto se eleva sobre el centro de la barra
}

/// Colores propios que no existen en [ColorScheme].
@immutable
class AppEstados extends ThemeExtension<AppEstados> {
  const AppEstados({
    required this.lista,
    required this.aplicando,
    required this.fallo,
    required this.meGusta,
  });

  final Color lista;
  final Color aplicando;
  final Color fallo;
  final Color meGusta;

  static const oscuro = AppEstados(
    lista: AppColors.verde,
    aplicando: AppColors.azulClaro,
    fallo: AppColors.rojoTexto,
    meGusta: AppColors.meGusta,
  );

  @override
  AppEstados copyWith({
    Color? lista,
    Color? aplicando,
    Color? fallo,
    Color? meGusta,
  }) => AppEstados(
    lista: lista ?? this.lista,
    aplicando: aplicando ?? this.aplicando,
    fallo: fallo ?? this.fallo,
    meGusta: meGusta ?? this.meGusta,
  );

  @override
  AppEstados lerp(AppEstados? other, double t) => other == null
      ? this
      : AppEstados(
          lista: Color.lerp(lista, other.lista, t)!,
          aplicando: Color.lerp(aplicando, other.aplicando, t)!,
          fallo: Color.lerp(fallo, other.fallo, t)!,
          meGusta: Color.lerp(meGusta, other.meGusta, t)!,
        );
}

abstract final class AppTheme {
  static const _titulos = 'Bricolage Grotesque';
  static const _cuerpo = 'Figtree';

  static TextStyle _titulo(double tam, double alto) => TextStyle(
    fontFamily: _titulos,
    fontWeight: FontWeight.w800,
    fontSize: tam,
    height: alto / tam,
    letterSpacing: -0.6,
    color: AppColors.texto,
  );

  static TextStyle _texto(double tam, double alto, [FontWeight? peso]) =>
      TextStyle(
        fontFamily: _cuerpo,
        fontSize: tam,
        height: alto / tam,
        letterSpacing: 0,
        fontWeight: peso ?? FontWeight.w400,
        color: AppColors.texto,
      );

  static final _forma = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadio.base),
  );

  static OutlineInputBorder _campo(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadio.base),
    borderSide: BorderSide(color: color),
  );

  static final ThemeData oscuro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _cuerpo,
    scaffoldBackgroundColor: AppColors.fondo,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.amarillo,
      onPrimary: AppColors.fondo,
      secondary: AppColors.azul,
      onSecondary: AppColors.texto,
      surface: AppColors.superficie,
      onSurface: AppColors.texto,
      onSurfaceVariant: AppColors.texto2,
      surfaceContainerHighest: AppColors.campo,
      outline: AppColors.linea,
      error: AppColors.rojoTexto,
      onError: AppColors.fondo,
      errorContainer: AppColors.rojo,
      onErrorContainer: AppColors.texto,
      scrim: AppColors.velo,
    ),
    extensions: const [AppEstados.oscuro],
    textTheme: TextTheme(
      headlineLarge: _titulo(30, 34), // Login y Crear cuenta
      headlineMedium: _titulo(26, 30), // Inicio y Perfil
      headlineSmall: _titulo(24, 30), // pantallas con flecha
      titleLarge: _titulo(20, 26), // hojas, alertas y cifras
      titleMedium: _texto(15, 21, FontWeight.w600), // nombres y opciones
      bodyLarge: _texto(15, 21), // campos y texto de publicación
      bodyMedium: _texto(14, 20),
      bodySmall: _texto(13, 18).copyWith(color: AppColors.texto2),
      labelLarge: _texto(16, 22, FontWeight.w600), // botones
      labelMedium: _texto(14, 18, FontWeight.w600), // etiquetas y estados
      labelSmall: _texto(13, 16, FontWeight.w600), // ruedas y errores
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.campo,
      hintStyle: _texto(15, 21).copyWith(color: AppColors.texto2),
      helperStyle: _texto(13, 16, FontWeight.w600),
      errorStyle: _texto(
        13,
        16,
        FontWeight.w600,
      ).copyWith(color: AppColors.rojoTexto),
      helperMaxLines: 1,
      errorMaxLines: 1,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppEspacio.base,
        vertical: 15, // con la línea de 21 da 52 de alto
      ),
      enabledBorder: _campo(AppColors.campo),
      focusedBorder: _campo(AppColors.amarillo),
      errorBorder: _campo(AppColors.rojoTexto),
      focusedErrorBorder: _campo(AppColors.rojoTexto),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppMedida.boton),
        padding: const EdgeInsets.symmetric(horizontal: AppEspacio.base),
        disabledBackgroundColor: AppColors.campo,
        disabledForegroundColor: AppColors.texto2,
        textStyle: _texto(16, 22, FontWeight.w600),
        shape: _forma,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppMedida.boton),
        padding: const EdgeInsets.symmetric(horizontal: AppEspacio.base),
        foregroundColor: AppColors.texto,
        side: const BorderSide(color: AppColors.linea),
        textStyle: _texto(16, 22, FontWeight.w600),
        shape: _forma,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.superficie,
      barrierColor: AppColors.velo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadio.hoja),
      ),
    ),
    // Pestañas del perfil: línea amarilla que se desliza sobre una gris.
    tabBarTheme: TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          color: AppColors.amarillo,
          width: AppMedida.lineaPestana,
        ),
      ),
      dividerColor: AppColors.campo,
      dividerHeight: AppMedida.lineaPestana,
      labelColor: AppColors.texto,
      unselectedLabelColor: AppColors.texto2,
      labelStyle: _texto(16, 22, FontWeight.w600),
      unselectedLabelStyle: _texto(16, 22, FontWeight.w600),
      overlayColor: WidgetStateProperty.all(AppColors.campo),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(AppMedida.toque, AppMedida.toque),
        padding: const EdgeInsets.symmetric(horizontal: AppEspacio.s),
        textStyle: _texto(16, 22, FontWeight.w600),
        shape: _forma,
      ),
    ),
  );
}
