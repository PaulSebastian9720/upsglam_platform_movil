import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upsglam_movil/app.dart';
import 'package:upsglam_movil/componentes/app_alerta.dart';
import 'package:upsglam_movil/modelos/fallo_camara.dart';
import 'package:upsglam_movil/modelos/filtro.dart';
import 'package:upsglam_movil/modelos/archivo_no_valido.dart';
import 'package:upsglam_movil/modelos/foto.dart';
import 'package:upsglam_movil/paginas/editar/editar_page.dart';
import 'package:upsglam_movil/componentes/rueda_filtro.dart';

import 'fotos_falsas.dart';
import 'package:upsglam_movil/componentes/barra_principal.dart';
import 'package:upsglam_movil/componentes/campo_texto.dart';
import 'package:upsglam_movil/paginas/camara/camara_page.dart';
import 'package:upsglam_movil/paginas/inicio/inicio_page.dart';
import 'package:upsglam_movil/paginas/login/login_page.dart';
import 'package:upsglam_movil/paginas/perfil/perfil_page.dart';
import 'package:upsglam_movil/paginas/registro/registro_page.dart';
import 'package:upsglam_movil/tema/app_theme.dart';

void main() {
  late FotosFalsas fotos;
  setUp(() => fotos = FotosFalsas());

  Future<void> abrir(
    WidgetTester tester, {
    Size tam = const Size(390, 844),
  }) async {
    tester.view.physicalSize = tam;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(UpsGlamApp(fotos: fotos));
    await tester.pumpAndSettle();
  }

  Future<void> entrar(WidgetTester tester) async {
    await abrir(tester);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
  }

  testWidgets('el login deja pasar a Inicio, vacío y con menú', (tester) async {
    await entrar(tester);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(InicioPage), findsOneWidget);
    expect(find.byType(BarraPrincipal), findsOneWidget);
  });

  testWidgets('Crear cuenta abre el registro y se puede volver', (
    tester,
  ) async {
    await abrir(tester);
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.byType(RegistroPage), findsOneWidget);
    await tester.tap(find.byTooltip('Volver a iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('el correo se valida al salir y nada se mueve', (tester) async {
    await abrir(tester);
    final campos = find.byType(TextFormField);
    final antes = tester.getTopLeft(find.text('Iniciar sesión'));
    final alto = tester.getSize(find.byType(CampoTexto).first).height;
    await tester.enterText(campos.first, 'correo-malo');
    await tester.pump();
    expect(find.text('Escribe un correo válido'), findsNothing);
    await tester.tap(campos.last);
    await tester.pumpAndSettle();
    expect(find.text('Escribe un correo válido'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Iniciar sesión')), antes);
    expect(tester.getSize(find.byType(CampoTexto).first).height, alto);
  });

  testWidgets('el menú cambia de pestaña y atrás vuelve a Inicio', (
    tester,
  ) async {
    await entrar(tester);
    await tester.tap(find.bySemanticsLabel('Perfil'));
    await tester.pumpAndSettle();
    expect(find.byType(PerfilPage), findsOneWidget);
    expect(find.byType(BarraPrincipal), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(InicioPage), findsOneWidget);
  });

  testWidgets('la parte de la bola que sobresale abre la cámara', (
    tester,
  ) async {
    await entrar(tester);
    final bola = tester.getRect(find.bySemanticsLabel('Cámara'));
    await tester.tapAt(bola.topCenter + const Offset(0, 4));
    await tester.pumpAndSettle();
    expect(find.byType(CamaraPage), findsOneWidget);
    expect(find.byType(BarraPrincipal), findsNothing);
    await tester.tap(find.byTooltip('Cerrar cámara'));
    await tester.pumpAndSettle();
    expect(find.byType(BarraPrincipal), findsOneWidget);
  });

  testWidgets('la bola y su anillo caben enteros en el menú', (tester) async {
    await entrar(tester);
    final menu = tester.getRect(
      find.descendant(
        of: find.byType(BarraPrincipal),
        matching: find.byType(Stack),
      ),
    );
    final bola = tester.getRect(find.bySemanticsLabel('Cámara'));
    expect(bola.top - AppMedida.borde, greaterThanOrEqualTo(menu.top));
    expect(bola.bottom + AppMedida.borde, lessThanOrEqualTo(menu.bottom));
  });

  testWidgets('un doble toque en la bola abre una sola cámara', (tester) async {
    await entrar(tester);
    final centro = tester.getCenter(find.bySemanticsLabel('Cámara'));
    await tester.tapAt(centro);
    await tester.tapAt(centro);
    await tester.pumpAndSettle();
    expect(find.byType(CamaraPage, skipOffstage: false), findsOneWidget);
  });

  testWidgets('el menú se oculta con el teclado', (tester) async {
    await entrar(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(find.byType(BarraPrincipal), findsNothing);
  });

  testWidgets('el teclado no mueve los botones del login', (tester) async {
    await abrir(tester);
    final antes = tester.getTopLeft(find.text('Crear cuenta'));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Crear cuenta')), antes);
  });

  testWidgets('cabe en 360x640 con letra al 130 %', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await abrir(tester, tam: const Size(360, 640));
    expect(tester.takeException(), isNull);
  });

  Future<void> camara(WidgetTester tester) async {
    await entrar(tester);
    await tester.tap(find.bySemanticsLabel('Cámara'));
    await tester.pumpAndSettle();
  }

  RuedaFiltro rueda(WidgetTester tester, Filtro filtro) => tester.widget(
    find.byWidgetPredicate((w) => w is RuedaFiltro && w.filtro == filtro),
  );

  testWidgets('los filtros aparecen solo después de tomar la foto', (
    tester,
  ) async {
    await camara(tester);
    expect(find.byType(RuedaFiltro), findsNothing);
    await tester.tap(find.bySemanticsLabel('Tomar foto'));
    await tester.pumpAndSettle();
    expect(find.byType(EditarPage), findsOneWidget);
    expect(rueda(tester, Filtro.original).seleccionada, isTrue);
    expect(fotos.abierta, isFalse);
    await tester.tap(find.text('Nitidez'));
    await tester.pumpAndSettle();
    expect(rueda(tester, Filtro.nitidez).seleccionada, isTrue);
    await tester.tap(find.byTooltip('Volver a la cámara'));
    await tester.pumpAndSettle();
    expect(fotos.abierta, isTrue);
    expect(fotos.descartadas, 1);
  });

  testWidgets('un doble toque al disparar toma una sola foto', (tester) async {
    await camara(tester);
    final centro = tester.getCenter(find.bySemanticsLabel('Tomar foto'));
    await tester.tapAt(centro);
    await tester.tapAt(centro);
    await tester.pumpAndSettle();
    expect(fotos.tomadas, 1);
  });

  testWidgets('girar cambia de cámara y apaga el botón del flash', (
    tester,
  ) async {
    await camara(tester);
    await tester.tap(find.byTooltip('Flash apagado'));
    await tester.pumpAndSettle();
    expect(fotos.flash, isTrue);
    await tester.tap(find.text('Girar'));
    await tester.pumpAndSettle();
    expect(fotos.frontal, isTrue);
    await tester.tap(find.byTooltip('Flash encendido'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Flash encendido'), findsOneWidget);
  });

  testWidgets('sin permiso se explica y se puede reintentar', (tester) async {
    fotos.fallo = TipoFalloCamara.sinPermiso;
    await camara(tester);
    expect(find.text('Permitir'), findsOneWidget);
    fotos.fallo = null;
    await tester.tap(find.text('Permitir'));
    await tester.pumpAndSettle();
    expect(find.text('Permitir'), findsNothing);
    expect(fotos.abierta, isTrue);
  });

  testWidgets('permiso bloqueado lleva a los ajustes', (tester) async {
    fotos.fallo = TipoFalloCamara.permisoBloqueado;
    await camara(tester);
    await tester.tap(find.text('Abrir ajustes'));
    await tester.pumpAndSettle();
    expect(fotos.ajustes, 1);
  });

  testWidgets('la galería lleva a Editar', (tester) async {
    await camara(tester);
    fotos.alElegir = () => const Foto(ruta: 'x.jpg');
    await tester.tap(find.text('Galería'));
    await tester.pumpAndSettle();
    expect(find.byType(EditarPage), findsOneWidget);
  });

  testWidgets('cancelar la galería deja la cámara lista', (tester) async {
    await camara(tester);
    await tester.tap(find.text('Galería'));
    await tester.pumpAndSettle();
    expect(find.byType(CamaraPage), findsOneWidget);
    expect(fotos.abierta, isTrue);
  });

  testWidgets('un archivo que no es foto muestra la alerta', (tester) async {
    await camara(tester);
    fotos.alElegir = () => throw const ArchivoNoValido();
    await tester.tap(find.text('Galería'));
    await tester.pumpAndSettle();
    expect(find.byType(AppAlerta), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(AppAlerta), findsNothing);
    expect(fotos.abierta, isTrue);
  });

  testWidgets('suelta la cámara en segundo plano y la recupera', (
    tester,
  ) async {
    await camara(tester);
    for (final e in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(e);
    }
    await tester.pumpAndSettle();
    expect(fotos.abierta, isFalse);
    for (final e in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(e);
    }
    await tester.pumpAndSettle();
    expect(fotos.abierta, isTrue);
  });

  testWidgets('salir suelta la cámara', (tester) async {
    await camara(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(CamaraPage), findsNothing);
    expect(fotos.abierta, isFalse);
  });
}
