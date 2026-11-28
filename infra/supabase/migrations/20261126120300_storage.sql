-- Buckets de Storage y sus políticas.
--
-- Rutas (la primera carpeta es siempre el id del dueño):
--   originales/{usuario_id}/{procesamiento_id}.{jpg|png|webp}   foto tal como se subió
--   resultados/{usuario_id}/{procesamiento_id}.jpg              foto con filtro (y la publicada)
--   avatares/{usuario_id}/{id_nuevo}.{jpg|png|webp}             foto de perfil
-- El mismo procesamiento_id empareja original, resultado y fila del historial.
-- El avatar cambia de nombre en cada foto nueva para que su URL pública también cambie.
--
-- Solo el backend sube y borra archivos (clave secreta, sin sobrescribir). La app nunca
-- escribe en Storage. Por eso no hay políticas de INSERT, UPDATE ni DELETE: nadie con la
-- clave pública puede pisar ni borrar imágenes, propias o ajenas.
--
-- Lectura:
--   originales y resultados son privados: el backend entrega URLs firmadas.
--   avatares es público: su URL no caduca y es la que se guarda en perfiles.avatar_url.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  -- 25 MB, el mismo límite que el servicio de GPU (MAX_MB).
  ('originales', 'originales', false, 26214400, array['image/jpeg', 'image/png', 'image/webp']),
  -- 50 MB, el máximo por archivo del plan gratuito. El servicio entrega JPEG.
  ('resultados', 'resultados', false, 52428800, array['image/jpeg']),
  ('avatares',   'avatares',   true,   2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- Con la clave pública, cada quien puede leer solo los archivos de su carpeta.
create policy "originales: ver los míos"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'originales'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "resultados: ver los míos"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'resultados'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
