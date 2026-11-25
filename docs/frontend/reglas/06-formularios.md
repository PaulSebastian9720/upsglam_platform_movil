# Formularios

## Cuándo se valida
1. **Al salir del campo** (`AutovalidateMode.onUnfocus`, [fuente](https://docs.flutter.dev/cookbook/forms/validation)).
2. Al enviar, todos. El foco va al primero con error.
3. Nunca mientras la persona escribe por primera vez.

## El error no mueve nada
- Bajo cada campo hay **siempre** una línea reservada, con o sin error. Al aparecer, ningún componente cambia de sitio.
- Rojo (`rojoTexto`), una línea, `labelSmall`. El borde del campo también pasa a rojo.

## Reglas por campo
| Campo | Regla | Mensaje |
|---|---|---|
| Correo | Obligatorio, formato correcto, sin espacios, en minúsculas | Escribe un correo válido |
| Usuario | 3 a 20; letras, números, punto y guion bajo | Usa de 3 a 20 letras, números, punto o _ |
| Contraseña (crear) | Mínimo 8 | Mínimo 8 caracteres |
| | Una mayúscula | Falta una mayúscula |
| | Una minúscula | Falta una minúscula |
| | Un número | Falta un número |
| | Un carácter especial | Falta un carácter especial |
| Contraseña (entrar) | Solo obligatoria | Escribe tu contraseña |
| Descripción | Hasta 150 | Máximo 150 caracteres |
| Texto de publicación | Opcional, varias líneas, hasta 500 | Máximo 500 caracteres |
| Comentario | Obligatorio, hasta 300 | El botón queda apagado |

- Se muestra el **primer** error que falle, no todos.
- Especiales: los que acepta Supabase: `` !@#$%^&*()_+-=[]{};'\:"|<>?,./`~ ``
- Supabase recomienda mínimo 8 y exigir números, minúsculas, mayúsculas y símbolos ([fuente](https://supabase.com/docs/guides/auth/password-security)). Hay que **activar lo mismo en el panel**: la app sola no protege.
- Los largos de usuario, descripción, texto y comentario son propuesta del proyecto; deben coincidir con la base de datos.
- Las validaciones viven en `utilidades/`, no en las páginas.

## Errores del servidor
| Caso | Dónde | Mensaje |
|---|---|---|
| Correo ya registrado | Bajo correo | Ese correo ya tiene cuenta |
| Usuario ocupado | Bajo usuario | Ese usuario ya existe |
| Credenciales incorrectas | Bajo contraseña | Correo o contraseña incorrectos |

## Teclado
- El campo activo queda siempre visible: la página se desplaza, no se aplasta.
- En hojas (comentarios) el campo sube con el teclado; lo de atrás no se mueve.
- Teclado según el dato, "siguiente" entre campos y "listo" en el último, autocompletado de correo y contraseña.
- Tocar fuera cierra el teclado. Si falla el envío, no se pierde lo escrito.
- Contraseña oculta, con `ver_clave` / `ocultar_clave`.

## Para revisar
- [ ] Salir de un correo mal escrito muestra el error y nada se mueve.
- [ ] `abc` pide 8; `abcdefgh` pide mayúscula; `Abcdefg1` pide carácter especial; `Abcdefg1!` pasa.
- [ ] Doble toque en Iniciar sesión envía una sola vez.
