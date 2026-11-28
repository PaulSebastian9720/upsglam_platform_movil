# Sesión y token

**Estado:** no implementado. La aplicación funciona con datos de prueba en memoria; este documento define cómo se integrará con Supabase Auth.

Supabase crea y renueva el token. El token se guarda cifrado en el teléfono, solo `SesionService` lo lee y solo `ApiService` lo envía.

| Necesidad | Responsable |
|---|---|
| Consultar si hay sesión o quién es el usuario | `SesionService` (`lib/servicios/sesion/`) |
| Iniciar sesión, crear cuenta y cerrar sesión | `SesionService` |
| Llamar al backend | Un repositorio, que usa `ApiService` (`lib/servicios/api/`) |
| Acceder al token directamente | No está permitido fuera de los dos servicios |
| Reaccionar al inicio o cierre de sesión | Las rutas redirigen automáticamente |

## Almacenamiento
- `supabase_flutter` guarda la sesión por defecto en Shared Preferences y permite reemplazarlo con una implementación propia de `LocalStorage` ([fuente](https://pub.dev/packages/supabase_flutter)).
- La guía de Flutter desaconseja guardar tokens en Shared Preferences porque no cifra los datos ([fuente](https://docs.flutter.dev/app-architecture/design-patterns/key-value-data)).
- Por eso la sesión se guarda con `flutter_secure_storage`, en `lib/servicios/sesion/`, mediante esa implementación de `LocalStorage`.

## Flujo
1. **Arranque:** Supabase se inicializa con el token guardado. Como la sesión puede haber caducado, se comprueba y se espera la renovación antes de mostrar Inicio.
2. **Rutas:** sin sesión, se redirige a `/login`; con sesión, se sale de login y registro. Los cambios se detectan con `onAuthStateChange`.
3. **Petición:** `ApiService` agrega la cabecera `Authorization: Bearer`.
4. **Respuesta 401:** se renueva el token una vez y se repite la petición una vez. Si vuelve a fallar, se cierra la sesión.
5. **Cierre de sesión:** se borran el token, todo el caché y el estado de los repositorios, y se navega a login.

## Restricciones
- No se guarda la contraseña. El token no se guarda en Shared Preferences, en el caché, en modelos ni en registros.
- La aplicación no incluye la clave `service_role` ni ningún otro secreto. La clave pública (anon) sí puede incluirse.
- Ninguna página ni controlador importa Supabase.

## Direcciones del entorno
La dirección de la API, la URL de Supabase y la clave pública se definen al compilar la aplicación con `--dart-define` ([fuente](https://dart.dev/guides/environment-declarations)) y se leen únicamente en `lib/config/`.

**Pendiente de definición:** el enunciado pide "Configuración de la URL de la API para facilitar la ejecución en distintos entornos". El equipo optó por definirla al compilar; falta confirmarlo con el docente.
