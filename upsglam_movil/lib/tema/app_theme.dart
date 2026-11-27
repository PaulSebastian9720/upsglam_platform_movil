import 'package:flutter/material.dart';

/// Único lugar de la app donde se escriben colores, medidas y letras.
/// Colores de marca y los que no cambian con el tema.
abstract final class AppColors {
  static const amarillo = Color(0xFFFFC72C);
  static const azul = Color(0xFF013871);
  static const visor = Color(0xFF000000); // fondo del zoom de fotos
}

/// Los colores de un tema. Hay dos: oscuro (el original) y claro.
@immutable
class AppPaleta {
  const AppPaleta({
    required this.brillo,
    required this.fondo,
    required this.superficie,
    required this.campo,
    required this.linea,
    required this.texto,
    required this.texto2,
    required this.destaque,
    required this.rojo,
    required this.rojoTexto,
    required this.meGusta,
    required this.verde,
    required this.azulEstado,
    required this.velo,
  });

  final Brightness brillo;
  final Color fondo;
  final Color superficie;
  final Color campo;
  final Color linea;
  final Color texto;
  final Color texto2;

  /// Texto y bordes que llaman la atención: enlaces, campo activo.
  final Color destaque;
  final Color rojo;
  final Color rojoTexto;
  final Color meGusta;
  final Color verde;
  final Color azulEstado;
  final Color velo;

  static const oscura = AppPaleta(
    brillo: Brightness.dark,
    fondo: Color(0xFF101114),
    superficie: Color(0xFF1B1C21),
    campo: Color(0xFF2A2C33),
    linea: Color(0xFF5A5D67),
    texto: Color(0xFFF5F5F7),
    texto2: Color(0xFFB4B6BE),
    destaque: AppColors.amarillo,
    rojo: Color(0xFFC92A3A),
    rojoTexto: Color(0xFFFF9299),
    meGusta: Color(0xFFFF5A66),
    verde: Color(0xFF6FE3B2),
    azulEstado: Color(0xFF8FB4FF),
    velo: Color(0xB808090B),
  );

  /// Fondo blanco. El amarillo sigue en botones y menú; el texto destacado
  /// pasa a azul, porque el amarillo no se lee sobre blanco.
  static const clara = AppPaleta(
    brillo: Brightness.light,
    fondo: Color(0xFFF7F7F9),
    superficie: Color(0xFFFFFFFF),
    campo: Color(0xFFECEDF1),
    linea: Color(0xFFC5C7CE),
    texto: Color(0xFF15161A),
    texto2: Color(0xFF5C5F69),
    destaque: AppColors.azul,
    rojo: Color(0xFFC92A3A),
    rojoTexto: Color(0xFFC62835),
    meGusta: Color(0xFFE5394A),
    verde: Color(0xFF1E8E5A),
    azulEstado: Color(0xFF2F5FB3),
    velo: Color(0x73101114),
  );
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
  static const logoEnPortada = 62.0;
  static const borde = 5.0; // anillo que separa del fondo
  static const barra = 54.0;
  static const barraAncho = 250.0;
  static const bola = 64.0; // cámara del menú
  static const logoBola = 42.0;
  static const iconoMenu = 24.0;
  static const logoInicio = 34.0;
  static const agarraderaAncho = 40.0; // barra para arrastrar una hoja
  static const agarraderaAlto = 4.0;
  static const zoomMaximo = 4.0;
  static const zoomDobleToque = 2.0;
  static const cerrarZoom = 120.0; // cuánto bajar la foto para cerrarla
  static const lineasComentario = 5;
  static const miniaturaPublicarAncho = 124.0;
  static const miniaturaPublicarAlto = 190.0; // el campo crece hasta aquí
  static const disparo = 72.0; // tomar foto
  static const control = 50.0; // galería, filtros y girar
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
  static const insignia = 26.0;
  static const botonCelda = 38.0; // editar y privacidad sobre cada foto
  static const iconoCelda = 20.0; // círculo sobre una foto de la cuadrícula
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

  factory AppEstados.de(AppPaleta p) => AppEstados(
    lista: p.verde,
    aplicando: p.azulEstado,
    fallo: p.rojoTexto,
    meGusta: p.meGusta,
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

/// Logo y fondo de la marca según el tema: en el oscuro, bola y cuadro
/// amarillos con la U negra; en el claro, azules con la U blanca.
@immutable
class AppMarca extends ThemeExtension<AppMarca> {
  const AppMarca({
    required this.fondoLogo,
    required this.logoSobreFondoLogo,
    required this.logoSobrePagina,
    required this.fondoEtiqueta,
    required this.textoEtiqueta,
  });

  /// Color de la bola del menú y del cuadro del login.
  final Color fondoLogo;

  /// El logo que va encima de ese color.
  final String logoSobreFondoLogo;

  /// El logo suelto sobre el fondo de la página, como en Inicio.
  final String logoSobrePagina;

  /// Etiqueta del filtro sobre las fotos (UPS, Nitidez…).
  final Color fondoEtiqueta;
  final Color textoEtiqueta;

  static const oscura = AppMarca(
    fondoLogo: AppColors.amarillo,
    logoSobreFondoLogo: 'assets/logo/logo_amarillo.svg',
    logoSobrePagina: 'assets/logo/logo_negro.svg',
    fondoEtiqueta: Color(0xFF101114),
    textoEtiqueta: Color(0xFFF5F5F7),
  );

  static const clara = AppMarca(
    fondoLogo: AppColors.azul,
    logoSobreFondoLogo: 'assets/logo/logo_blanco.svg',
    logoSobrePagina: 'assets/logo/logo_azul.svg',
    fondoEtiqueta: AppColors.azul,
    textoEtiqueta: Color(0xFFFFFFFF),
  );

  @override
  AppMarca copyWith({
    Color? fondoLogo,
    String? logoSobreFondoLogo,
    String? logoSobrePagina,
    Color? fondoEtiqueta,
    Color? textoEtiqueta,
  }) => AppMarca(
    fondoLogo: fondoLogo ?? this.fondoLogo,
    logoSobreFondoLogo: logoSobreFondoLogo ?? this.logoSobreFondoLogo,
    logoSobrePagina: logoSobrePagina ?? this.logoSobrePagina,
    fondoEtiqueta: fondoEtiqueta ?? this.fondoEtiqueta,
    textoEtiqueta: textoEtiqueta ?? this.textoEtiqueta,
  );

  @override
  AppMarca lerp(AppMarca? other, double t) =>
      other == null || t < 0.5 ? this : other;
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
  );

  static TextStyle _texto(double tam, double alto, [FontWeight? peso]) =>
      TextStyle(
        fontFamily: _cuerpo,
        fontSize: tam,
        height: alto / tam,
        letterSpacing: 0,
        fontWeight: peso ?? FontWeight.w400,
      );

  static final _forma = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadio.base),
  );

  static OutlineInputBorder _campo(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadio.base),
    borderSide: BorderSide(color: color),
  );

  static final ThemeData oscuro = _crear(AppPaleta.oscura);
  static final ThemeData claro = _crear(AppPaleta.clara);

  static ThemeData _crear(AppPaleta p) => ThemeData(
    useMaterial3: true,
    brightness: p.brillo,
    fontFamily: _cuerpo,
    scaffoldBackgroundColor: p.fondo,
    colorScheme: ColorScheme(
      brightness: p.brillo,
      primary: AppColors.amarillo,
      // Sobre el amarillo el texto siempre es oscuro.
      onPrimary: AppPaleta.oscura.fondo,
      secondary: AppColors.azul,
      onSecondary: AppPaleta.oscura.texto,
      surface: p.superficie,
      onSurface: p.texto,
      onSurfaceVariant: p.texto2,
      surfaceContainerHighest: p.campo,
      outline: p.linea,
      error: p.rojoTexto,
      onError: p.fondo,
      errorContainer: p.rojo,
      onErrorContainer: p.texto,
      scrim: p.velo,
    ),
    extensions: [
      AppEstados.de(p),
      p.brillo == Brightness.dark ? AppMarca.oscura : AppMarca.clara,
    ],
    textTheme:
        TextTheme(
              headlineLarge: _titulo(26, 30), // Login y Crear cuenta
              headlineMedium: _titulo(22, 28), // Inicio y Perfil
              headlineSmall: _titulo(20, 26), // pantallas con flecha
              titleLarge: _titulo(20, 26), // hojas, alertas y cifras
              titleMedium: _texto(
                15,
                21,
                FontWeight.w600,
              ), // nombres y opciones
              bodyLarge: _texto(15, 21), // campos y texto de publicación
              bodyMedium: _texto(14, 20),
              bodySmall: _texto(13, 18),
              labelLarge: _texto(16, 22, FontWeight.w600), // botones
              labelMedium: _texto(
                14,
                18,
                FontWeight.w600,
              ), // etiquetas y estados
              labelSmall: _texto(13, 16, FontWeight.w600), // ruedas y errores
            )
            .apply(bodyColor: p.texto, displayColor: p.texto)
            .copyWith(bodySmall: _texto(13, 18).copyWith(color: p.texto2)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.campo,
      hintStyle: _texto(15, 21).copyWith(color: p.texto2),
      // Etiqueta flotante: dentro de la caja y, al tocarla, arriba en el
      // borde, destacada mientras se escribe y roja si hay error.
      labelStyle: _texto(15, 21).copyWith(color: p.texto2),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      floatingLabelStyle: WidgetStateTextStyle.resolveWith((estado) {
        final base = _texto(14, 18, FontWeight.w600);
        if (estado.contains(WidgetState.error)) {
          return base.copyWith(color: p.rojoTexto);
        }
        if (estado.contains(WidgetState.focused)) {
          return base.copyWith(color: p.destaque);
        }
        return base.copyWith(color: p.texto2);
      }),
      helperStyle: _texto(13, 16, FontWeight.w600),
      errorStyle: _texto(13, 16, FontWeight.w600).copyWith(color: p.rojoTexto),
      helperMaxLines: 1,
      errorMaxLines: 1,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppEspacio.base,
        vertical: 15, // con la línea de 21 da 52 de alto
      ),
      enabledBorder: _campo(p.campo),
      focusedBorder: _campo(p.destaque),
      errorBorder: _campo(p.rojoTexto),
      focusedErrorBorder: _campo(p.rojoTexto),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppMedida.boton),
        padding: const EdgeInsets.symmetric(horizontal: AppEspacio.base),
        disabledBackgroundColor: p.campo,
        disabledForegroundColor: p.texto2,
        textStyle: _texto(16, 22, FontWeight.w600),
        shape: _forma,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppMedida.boton),
        padding: const EdgeInsets.symmetric(horizontal: AppEspacio.base),
        foregroundColor: p.texto,
        side: BorderSide(color: p.linea),
        textStyle: _texto(16, 22, FontWeight.w600),
        shape: _forma,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.superficie,
      modalBackgroundColor: p.superficie,
      modalBarrierColor: p.velo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadio.hoja),
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.superficie,
      barrierColor: p.velo,
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
      dividerColor: p.campo,
      dividerHeight: AppMedida.lineaPestana,
      labelColor: p.texto,
      unselectedLabelColor: p.texto2,
      labelStyle: _texto(16, 22, FontWeight.w600),
      unselectedLabelStyle: _texto(16, 22, FontWeight.w600),
      overlayColor: WidgetStateProperty.all(p.campo),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(AppMedida.toque, AppMedida.toque),
        padding: const EdgeInsets.symmetric(horizontal: AppEspacio.s),
        foregroundColor: p.destaque,
        textStyle: _texto(16, 22, FontWeight.w600),
        shape: _forma,
      ),
    ),
  );
}
