-- Seguridad por fila (RLS).
-- Aplica a quien entra directo a Supabase con la clave pública y un token de usuario.
-- El backend entra con el usuario postgres, dueño de las tablas, y no pasa por estas
-- políticas: él aplica las mismas reglas en su código (toda modificación o borrado
-- lleva "y el dueño es el usuario del token").
--
-- Criterio:
--   * Lo público lo lee cualquier persona con sesión; sin sesión (anon) no se ve nada.
--   * Cada quien escribe solo lo suyo.
--   * Lo privado (historial, métricas, publicaciones privadas, lista de seguidores)
--     solo lo ve su dueño.
-- Una tabla con RLS y sin política para una acción la niega.
-- Se usa (select auth.uid()) para que Postgres lo calcule una vez por consulta.

alter table public.perfiles         enable row level security;
alter table public.procesamientos   enable row level security;
alter table public.metricas_gpu     enable row level security;
alter table public.kernels_lanzados enable row level security;
alter table public.publicaciones    enable row level security;
alter table public.comentarios      enable row level security;
alter table public.me_gusta         enable row level security;
alter table public.seguidores       enable row level security;

-- ¿Quien pregunta puede ver esta publicación? (pública, o privada y suya)
create or replace function public.publicacion_visible(p_publicacion_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.publicaciones p
    where p.id = p_publicacion_id
      and (not p.privada or p.autor_id = (select auth.uid()))
  );
$$;

-- ¿Este procesamiento es de quien pregunta?
create or replace function public.procesamiento_propio(p_procesamiento_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.procesamientos pr
    where pr.id = p_procesamiento_id
      and pr.usuario_id = (select auth.uid())
  );
$$;

revoke execute on function public.publicacion_visible(uuid) from public, anon;
revoke execute on function public.procesamiento_propio(uuid) from public, anon;
grant execute on function public.publicacion_visible(uuid) to authenticated;
grant execute on function public.procesamiento_propio(uuid) to authenticated;

-- Perfiles ------------------------------------------------------------------
-- Lo crea el trigger de registro y se borra con la cuenta. El usuario no cambia
-- (trigger perfiles_usuario_inmutable).
create policy "perfiles: leer con sesión"
  on public.perfiles for select to authenticated
  using (true);

create policy "perfiles: editar el propio"
  on public.perfiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- Historial y métricas ------------------------------------------------------
-- Solo lectura para el dueño. Crear, actualizar y borrar lo hace el backend, que es
-- quien habla con el servicio de GPU.
create policy "procesamientos: leer los propios"
  on public.procesamientos for select to authenticated
  using (usuario_id = (select auth.uid()));

create policy "metricas_gpu: leer las propias"
  on public.metricas_gpu for select to authenticated
  using (public.procesamiento_propio(procesamiento_id));

create policy "kernels_lanzados: leer los propios"
  on public.kernels_lanzados for select to authenticated
  using (public.procesamiento_propio(procesamiento_id));

-- Publicaciones -------------------------------------------------------------
create policy "publicaciones: leer públicas y propias"
  on public.publicaciones for select to authenticated
  using (not privada or autor_id = (select auth.uid()));

create policy "publicaciones: crear como autor"
  on public.publicaciones for insert to authenticated
  with check (autor_id = (select auth.uid()));

create policy "publicaciones: editar las propias"
  on public.publicaciones for update to authenticated
  using (autor_id = (select auth.uid()))
  with check (autor_id = (select auth.uid()));

create policy "publicaciones: borrar las propias"
  on public.publicaciones for delete to authenticated
  using (autor_id = (select auth.uid()));

-- Comentarios ---------------------------------------------------------------
create policy "comentarios: leer en publicaciones visibles"
  on public.comentarios for select to authenticated
  using (public.publicacion_visible(publicacion_id));

create policy "comentarios: comentar en publicaciones visibles"
  on public.comentarios for insert to authenticated
  with check (
    autor_id = (select auth.uid())
    and public.publicacion_visible(publicacion_id)
  );

-- Borra su autor o el dueño de la publicación. Nadie los edita.
create policy "comentarios: borrar propios o de mi publicación"
  on public.comentarios for delete to authenticated
  using (
    autor_id = (select auth.uid())
    or exists (
      select 1 from public.publicaciones p
      where p.id = publicacion_id and p.autor_id = (select auth.uid())
    )
  );

-- Me gusta ------------------------------------------------------------------
create policy "me_gusta: leer en publicaciones visibles"
  on public.me_gusta for select to authenticated
  using (public.publicacion_visible(publicacion_id));

create policy "me_gusta: dar el propio"
  on public.me_gusta for insert to authenticated
  with check (
    usuario_id = (select auth.uid())
    and public.publicacion_visible(publicacion_id)
  );

create policy "me_gusta: quitar el propio"
  on public.me_gusta for delete to authenticated
  using (usuario_id = (select auth.uid()));

-- Seguidores ----------------------------------------------------------------
-- Cada quien ve solo las filas donde aparece: sus seguidores y a quién sigue. El número
-- de seguidores y "loSigo" de otros perfiles los calcula el backend.
create policy "seguidores: ver los que me involucran"
  on public.seguidores for select to authenticated
  using (
    seguidor_id = (select auth.uid())
    or seguido_id = (select auth.uid())
  );

create policy "seguidores: seguir"
  on public.seguidores for insert to authenticated
  with check (seguidor_id = (select auth.uid()));

create policy "seguidores: dejar de seguir"
  on public.seguidores for delete to authenticated
  using (seguidor_id = (select auth.uid()));
