# Tema

El tema sigue el estándar de Flutter: un `ThemeData` en `MaterialApp`, que los widgets leen con `Theme.of(context)` ([fuente](https://docs.flutter.dev/cookbook/design/themes)). Los valores que no forman parte de `ColorScheme`, como los estados o el color de me gusta, se definen en una `ThemeExtension`.

Todo el tema se define en `lib/tema/app_theme.dart`. Fuera de ese archivo no se escriben `Color(...)`, `Colors.*`, tamaños de letra ni radios.

## Colores
Valores de la paleta oscura:

| Nombre | Valor | Dónde va en el tema | Uso |
|---|---|---|---|
| fondo | `#101114` | scaffoldBackground, onPrimary | Fondo de toda la aplicación |
| superficie | `#1B1C21` | surface | Hojas y alertas |
| campo | `#2A2C33` | fillColor | Campos, menú, botón apagado |
| linea | `#5A5D67` | outline | Borde del botón secundario |
| texto | `#F5F5F7` | onSurface | Texto principal |
| texto2 | `#B4B6BE` | onSurfaceVariant | Fechas, ayudas |
| amarillo | `#FFC72C` | primary | Acción principal y selección |
| azul | `#013871` | secondary | Marca: logo e icono de la aplicación |
| rojo | `#C92A3A` | errorContainer | Botón destructivo |
| rojoTexto | `#FF9299` | error | Errores y alertas |
| meGusta | `#FF5A66` | extensión | Corazón activo |
| verde | `#6FE3B2` | extensión | Estado Lista |
| azulClaro | `#8FB4FF` | extensión | Estado Aplicando |
| velo | `#08090B` al 72 % | scrim | Fondo detrás de hojas y alertas |

- El azul `#013871` no se usa en botones sobre el fondo oscuro, porque su contraste es de 1,6:1.
- Cada pantalla tiene un solo elemento amarillo de acción, además del botón del menú.
- Los estados se indican con texto o icono, no solo con color.

## Tipografía
Los títulos usan Bricolage Grotesque 800 y el resto del texto, Figtree 400 y 600. Las fuentes se incluyen en la aplicación (`assets/fuentes`) para que funcionen sin conexión.

| Familia en `pubspec.yaml` | Archivo | Peso |
|---|---|---|
| Bricolage Grotesque | BricolageGrotesque-ExtraBold.ttf | 800 |
| Figtree | Figtree-Regular.ttf | 400 |
| Figtree | Figtree-SemiBold.ttf | 600 |

Son archivos de peso fijo, por lo que basta con `FontWeight`. Contienen solo caracteres latinos; el resto se muestra con la fuente del sistema. Para usar otro peso, primero se genera el archivo y se registra en esta tabla.

| Estilo del tema | Letra | Tamaño / línea | Uso |
|---|---|---|---|
| headlineLarge | Bricolage 800 | 26 / 30 | Login, Crear cuenta |
| headlineMedium | Bricolage 800 | 22 / 28 | Inicio, Perfil |
| headlineSmall | Bricolage 800 | 20 / 26 | Pantallas con flecha |
| titleLarge | Bricolage 800 | 20 / 26 | Hojas, alertas, cifras |
| titleMedium | Figtree 600 | 15 / 21 | Nombres y opciones |
| bodyLarge | Figtree 400 | 15 / 21 | Campos, texto de publicación |
| bodyMedium | Figtree 400 | 14 / 20 | Texto general |
| bodySmall | Figtree 400 | 13 / 18 | Fechas |
| labelLarge | Figtree 600 | 16 / 22 | Botones |
| labelMedium | Figtree 600 | 14 / 18 | Etiquetas y estados |
| labelSmall | Figtree 600 | 13 / 16 | Ruedas de filtro, error de campo |

## Tema claro y oscuro
`app_theme.dart` define dos paletas, `AppPaleta.oscura` y `AppPaleta.clara`, y un único constructor de tema que las usa a ambas.

En el tema claro:
- El amarillo se mantiene en botones y menú.
- El texto destacado (enlaces y campo activo) pasa a azul, porque el amarillo no es legible sobre blanco.
- La bola del menú, el cuadro del login y la etiqueta del filtro sobre las fotos usan azul con blanco.
- Inicio muestra el logo azul.

El tema se elige en Configuración, en la fila Tema, que abre una hoja inferior con las opciones Oscuro, Claro y Sistema. La elección se guarda en el teléfono y se aplica antes de mostrar la primera pantalla.

## Medidas
| Token | Valor | Uso |
|---|---|---|
| espacio.base | **16** | Margen de pantallas, tarjetas, campos y botones |
| espacio xs, s, m, l, xl | 4, 8, 12, 24, 32 | Separaciones; no se usan otros valores |
| radio.base | **10** | Botones, campos, etiquetas, miniaturas |
| radio.hoja | **20** | Hojas (arriba) y alertas |
| radio.imagen | **0** | Fotos: siempre rectas |
| círculo | completo | Avatares, ruedas de filtro, botones de cámara, menú |
| alto de botón | **46** (toque 48) | Todos |
| alto de campo | **52** | Todos |
| toque mínimo | **48** | Todo lo que se toca |

