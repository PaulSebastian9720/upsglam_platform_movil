# Formularios

## Cuándo se valida
1. Al salir del campo (`AutovalidateMode.onUnfocus`, [fuente](https://docs.flutter.dev/cookbook/forms/validation)).
2. Al enviar el formulario se validan todos los campos y el foco pasa al primero con error.
3. No se valida mientras se escribe por primera vez en un campo.

## Presentación del error
- Bajo cada campo hay siempre una línea reservada, con o sin error, de modo que al aparecer el mensaje ningún elemento cambia de posición.
- El mensaje ocupa una línea, en rojo (`rojoTexto`) y con estilo `labelSmall`. El borde del campo también cambia a rojo.

## Reglas por campo
| Campo | Regla | Mensaje |
|---|---|---|
| Correo | Obligatorio, formato correcto, sin espacios, en minúsculas | Escribe un correo válido |
| Nombre completo | Obligatorio, 3 a 60 caracteres sin contar espacios al inicio ni al final; se puede editar | Escribe tu nombre completo |
| Usuario | 3 a 20; letras, números, punto y guion bajo | Usa de 3 a 20 letras, números, punto o _ |
| | Único, sin distinguir mayúsculas; lo confirma el servidor al crear la cuenta | Ese usuario ya existe |
| | No se puede cambiar después de crear la cuenta | En Editar perfil se muestra como solo lectura |
| Correo (perfil) | No se puede cambiar | En Editar perfil se muestra como solo lectura |
| Contraseña (crear) | Mínimo 8 | Mínimo 8 caracteres |
| | Una mayúscula | Falta una mayúscula |
| | Una minúscula | Falta una minúscula |
| | Un número | Falta un número |
| | Un carácter especial | Falta un carácter especial |
| Confirmar contraseña (crear) | Igual a la contraseña | Las contraseñas no coinciden |
| Contraseña (entrar) | Solo obligatoria | Escribe tu contraseña |
| Descripción | Hasta 150 | Máximo 150 caracteres |
| Texto de publicación | Opcional, varias líneas, hasta 500 | Máximo 500 caracteres |
| Comentario | Obligatorio, hasta 300 | El botón de enviar queda deshabilitado |

- Se muestra solo el primer error encontrado.
- Los caracteres especiales válidos son los que acepta Supabase: `` !@#$%^&*()_+-=[]{};'\:"|<>?,./`~ ``
- Supabase recomienda un mínimo de 8 caracteres con números, minúsculas, mayúsculas y símbolos ([fuente](https://supabase.com/docs/guides/auth/password-security)). La misma política debe activarse en el panel de Supabase, porque la validación de la aplicación no basta por sí sola.
- Las longitudes de usuario, descripción, texto y comentario deben coincidir con las de la base de datos.
- Las validaciones se definen en `utilidades/`, no en las páginas.

## Errores del servidor
No implementado: la aplicación aún no se conecta con Supabase ni con el backend.

| Caso | Dónde | Mensaje |
|---|---|---|
| Correo ya registrado | Bajo correo | Ese correo ya tiene cuenta |
| Usuario ocupado | Bajo usuario | Ese usuario ya existe |
| Credenciales incorrectas | Bajo contraseña | Correo o contraseña incorrectos |

## Teclado
- El campo activo permanece visible: la página se desplaza en lugar de comprimirse.
- En las hojas, como la de comentarios, el campo sube con el teclado y el contenido de fondo no se mueve.
- El tipo de teclado corresponde al dato. La tecla de acción es "siguiente" entre campos y "listo" en el último. Correo y contraseña admiten autocompletado.
- Tocar fuera de un campo cierra el teclado. Si el envío falla, se conserva lo escrito.
- La contraseña se muestra oculta, con los iconos `ver_clave` y `ocultar_clave` para alternar.
- Un botón de envío no envía dos veces la misma solicitud.

