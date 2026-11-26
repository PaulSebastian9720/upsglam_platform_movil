# Sesión y token

**En un minuto:** el token lo crea y renueva Supabase. Se guarda cifrado en el teléfono. Solo `SesionService` lo lee. Solo `ApiService` lo envía. Nadie más lo toca.

| Necesito… | Uso |
|---|---|
| Saber si hay sesión o quién es | `SesionService` (`lib/servicios/sesion/`) |
| Iniciar sesión, crear cuenta, salir | `SesionService` |
| Llamar al backend | Un repositorio; él usa `ApiService` (`lib/servicios/api/`) |
| El token a mano | No lo necesitas |
| Reaccionar a entrar o salir | Las rutas ya redirigen solas |

## Dónde está
- `supabase_flutter` guarda la sesión por defecto en Shared Preferences y permite cambiarlo con una clase propia de `LocalStorage` ([fuente](https://pub.dev/packages/supabase_flutter)).
- La guía de Flutter advierte no guardar tokens en Shared Preferences, porque no cifra ([fuente](https://docs.flutter.dev/app-architecture/design-patterns/key-value-data)).
- **Regla:** se guarda con `flutter_secure_storage`, en `lib/servicios/sesion/`, usando ese `LocalStorage`.

## Flujo
1. **Arranque:** se inicializa Supabase con el token guardado. La sesión puede venir caducada: se comprueba y se espera la renovación antes de mostrar Inicio.
2. **Rutas:** sin sesión, a `/login`; con sesión, fuera de login y registro. Se escucha `onAuthStateChange`.
3. **Petición:** `ApiService` agrega `Authorization: Bearer`.
4. **401:** renovar una vez y repetir una vez. Si vuelve a fallar, cerrar sesión.
5. **Salir:** se borra el token, **todo el caché** y el estado de los repositorios, y se va a login.

## Prohibido
- Guardar la contraseña, o el token en Shared Preferences, en el caché, en modelos o en registros.
- Poner en la APK la clave `service_role` u otro secreto. La clave pública (anon) sí puede ir.
- Que una página o un controlador importe Supabase.

## Direcciones del entorno
Se definen al construir la APK con `--dart-define` ([fuente](https://dart.dev/guides/environment-declarations)) y se leen solo en `lib/config/`: API, URL de Supabase y clave pública.

> **Por confirmar con el docente:** el PDF pide en la app "Configuración de la URL de la API para facilitar la ejecución en distintos entornos". El equipo decidió hacerlo al construir la APK.
