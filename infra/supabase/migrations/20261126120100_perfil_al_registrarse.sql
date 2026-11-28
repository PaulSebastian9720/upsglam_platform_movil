-- Crea el perfil cuando alguien se registra en Supabase Auth.
-- La app envía nombre y usuario en los metadatos del registro:
--   signUp(email, password, data: {'nombre': 'Paul Sebastián', 'usuario': 'paul_s'})
-- Si falta alguno, no cumple su regla o el usuario ya está ocupado, el registro entero
-- falla y no queda una cuenta sin perfil. Supabase responde con un error genérico, por
-- eso el backend ofrece antes la comprobación de usuario disponible.

create or replace function public.crear_perfil_al_registrarse()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.perfiles (id, usuario, nombre)
  values (
    new.id,
    new.raw_user_meta_data ->> 'usuario',
    btrim(new.raw_user_meta_data ->> 'nombre')
  );
  return new;
end;
$$;

-- Solo la ejecuta el trigger, nadie desde la API.
revoke execute on function public.crear_perfil_al_registrarse() from public, anon, authenticated;

create trigger al_registrarse_crear_perfil
  after insert on auth.users
  for each row execute function public.crear_perfil_al_registrarse();
