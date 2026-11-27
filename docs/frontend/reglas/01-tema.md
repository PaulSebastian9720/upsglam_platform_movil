# Tema

Estándar de Flutter: un `ThemeData` en `MaterialApp.theme`; los widgets lo leen con `Theme.of(context)`
([fuente](https://docs.flutter.dev/cookbook/design/themes)). Lo que no cabe en `ColorScheme` (estados, me gusta) va en una `ThemeExtension`.

**Archivo único:** `lib/tema/app_theme.dart`. Solo tema oscuro. En cualquier otro archivo está prohibido escribir `Color(...)`, `Colors.*`, tamaños de letra o radios.

## Colores
| Nombre | Valor | Dónde va en el tema | Uso |
|---|---|---|---|
| fondo | `#101114` | scaffoldBackground, onPrimary | Fondo de toda la app |
| superficie | `#1B1C21` | surface | Hojas y alertas |
| campo | `#2A2C33` | fillColor | Campos, menú, botón apagado |
| linea | `#5A5D67` | outline | Borde del botón secundario |
| texto | `#F5F5F7` | onSurface | Texto principal |
| texto2 | `#B4B6BE` | onSurfaceVariant | Fechas, ayudas |
| amarillo | `#FFC72C` | primary | Acción principal y selección |
| azul | `#013871` | secondary | Marca: logo e icono de la app |
| rojo | `#C92A3A` | errorContainer | Botón destructivo |
| rojoTexto | `#FF9299` | error | Errores y alertas |
| meGusta | `#FF5A66` | extensión | Corazón activo |
| verde | `#6FE3B2` | extensión | Estado Lista |
| azulClaro | `#8FB4FF` | extensión | Estado Aplicando |
| velo | `#08090B` al 72 % | scrim | Fondo detrás de hojas y alertas |

- El azul `#013871` no va en botones sobre el fondo negro: contrasta poco (1,6:1).
- Un solo elemento amarillo de acción por pantalla, además del botón del menú.
- Los estados llevan texto o icono, nunca solo color.

## Tipografía
Bricolage Grotesque 800 para títulos; Figtree 400 y 600 para lo demás. Las fuentes van **dentro de la app** (`assets/fuentes`), para que la demo funcione sin internet.

| Familia en `pubspec.yaml` | Archivo | Peso |
|---|---|---|
| Bricolage Grotesque | BricolageGrotesque-ExtraBold.ttf | 800 |
| Figtree | Figtree-Regular.ttf | 400 |
| Figtree | Figtree-SemiBold.ttf | 600 |

Son pesos fijos, no variables: así `FontWeight` basta. Están recortadas a caracteres latinos; lo demás usa la fuente del sistema. Otro peso se genera y se agrega aquí antes de usarlo.

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

## Medidas
| Token | Valor | Uso |
|---|---|---|
| espacio.base | **16** | Padding fijo: pantallas, tarjetas, campos, botones |
| espacio xs, s, m, l, xl | 4, 8, 12, 24, 32 | Separaciones; no usar otros |
| radio.base | **10** | Botones, campos, etiquetas, miniaturas |
| radio.hoja | **20** | Hojas (arriba) y alertas |
| radio.imagen | **0** | Fotos: siempre rectas |
| círculo | completo | Avatares, ruedas de filtro, botones de cámara, menú |
| alto de botón | **46** (toque 48) | Todos |
| alto de campo | **52** | Todos |
| toque mínimo | **48** | Todo lo que se toca |

## Para revisar
- [ ] Buscar `Color(0x`, `Colors.` y `fontSize:` fuera de `lib/tema` no devuelve nada.
- [ ] Cambiar un color en el tema cambia toda la app.
