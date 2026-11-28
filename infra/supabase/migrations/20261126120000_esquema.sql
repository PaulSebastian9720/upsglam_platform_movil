-- Esquema de UPSGlam: tablas, restricciones e índices.
-- Los largos coinciden con docs/frontend/reglas/06-formularios.md y los nombres de filtros
-- y kernels con docs/backend/servicio-gpu.md.
-- Las listas se paginan por cursor: fecha y luego id, por eso los índices compuestos
-- terminan en (fecha, id).

create type public.estado_procesamiento as enum ('aplicando', 'lista', 'fallo');

-- Mantiene la columna de última modificación al día en cada UPDATE.
create or replace function public.marcar_actualizado()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_table_name = 'publicaciones' then
    new.actualizada := now();
  else
    new.actualizado := now();
  end if;
  return new;
end;
$$;

-- Perfiles ------------------------------------------------------------------
-- Uno por cuenta de auth.users. El correo vive en auth.users y no se repite aquí.
create table public.perfiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  usuario     text not null
              check (usuario ~ '^[A-Za-z0-9._]{3,20}$'),
  nombre      text not null
              check (char_length(btrim(nombre)) between 3 and 60),
  descripcion text not null default ''
              check (char_length(descripcion) <= 150),
  -- URL pública del bucket avatares; cambia con cada avatar nuevo.
  avatar_url  text,
  creado      timestamptz not null default now(),
  actualizado timestamptz not null default now()
);

-- "Paul" y "paul" son el mismo usuario.
create unique index perfiles_usuario_unico on public.perfiles (lower(usuario));

create trigger perfiles_actualizado
  before update on public.perfiles
  for each row execute function public.marcar_actualizado();

-- El usuario no se cambia después de crear la cuenta, lo intente quien lo intente.
create or replace function public.impedir_cambio_usuario()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.usuario is distinct from old.usuario then
    raise exception 'El usuario no se puede cambiar'
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

create trigger perfiles_usuario_inmutable
  before update of usuario on public.perfiles
  for each row execute function public.impedir_cambio_usuario();

-- Procesamientos (historial) -------------------------------------------------
-- Una fila por solicitud al servicio de GPU, se publique o no.
create table public.procesamientos (
  id               uuid primary key default gen_random_uuid(),
  usuario_id       uuid not null references public.perfiles (id) on delete cascade,
  -- id que devuelve el servicio (cabecera X-Request-Id); cruza con sus registros.
  gpu_solicitud_id text unique,
  filtro           text not null
                   check (filtro in ('media', 'nitidez', 'laplaciano', 'sobel', 'relieve', 'ups')),
  -- Parámetros aplicados, como los devuelve el servicio.
  parametros       jsonb not null default '{}'::jsonb,
  estado           public.estado_procesamiento not null default 'aplicando',
  original_clave   text not null,
  resultado_clave  text,
  ancho            integer check (ancho > 0),
  alto             integer check (alto > 0),
  -- Código del servicio (cola_llena, pixeles_excedidos...) y su mensaje.
  error_codigo     text,
  error_detalle    text,
  creado           timestamptz not null default now(),
  terminado        timestamptz,
  constraint procesamientos_aplicando_sin_fin
    check (estado <> 'aplicando' or terminado is null),
  constraint procesamientos_lista_con_resultado
    check (estado <> 'lista' or (resultado_clave is not null and terminado is not null)),
  constraint procesamientos_fallo_con_error
    check (estado <> 'fallo' or (error_codigo is not null and terminado is not null))
);

create index procesamientos_usuario_cursor
  on public.procesamientos (usuario_id, creado desc, id desc);

-- Métricas de GPU -------------------------------------------------------------
-- Solo existe si la solicitud llegó a lanzar kernels; si falló antes, no hay fila
-- (métrica no disponible, sin inventar valores).
create table public.metricas_gpu (
  procesamiento_id  uuid primary key references public.procesamientos (id) on delete cascade,
  hilos_lanzados    bigint not null check (hilos_lanzados > 0),
  ms_kernel         double precision not null check (ms_kernel >= 0),
  ms_cpu_gpu        double precision not null check (ms_cpu_gpu >= 0),
  ms_gpu_cpu        double precision not null check (ms_gpu_cpu >= 0),
  -- Tiempo total dentro del servicio de GPU.
  ms_total_servicio double precision not null check (ms_total_servicio >= 0),
  -- Tiempo de punta a punta en el backend; se completa al terminar la solicitud.
  ms_total_api      double precision check (ms_total_api >= 0),
  -- Desglose del servicio (decodificación, cola, gpu, codificación), sin columnas propias.
  tiempos_servicio  jsonb not null default '{}'::jsonb
);

-- Kernels lanzados --------------------------------------------------------------
-- Uno por lanzamiento, en el orden real: Laplaciano lanza 2, UPS lanza sobel y luego
-- colorear_ups. Los kernels se lanzan en 2D: cada hilo procesa un píxel.
create table public.kernels_lanzados (
  procesamiento_id uuid not null references public.procesamientos (id) on delete cascade,
  orden            smallint not null check (orden >= 1),
  kernel           text not null
                   check (kernel in ('convolucion_rgb', 'convolucion_gris', 'sobel', 'colorear_ups')),
  bloque_x         integer not null check (bloque_x > 0),
  bloque_y         integer not null check (bloque_y > 0),
  grid_x           integer not null check (grid_x > 0),
  grid_y           integer not null check (grid_y > 0),
  hilos            bigint not null,
  ms               double precision not null check (ms >= 0),
  primary key (procesamiento_id, orden),
  constraint kernels_hilos_de_todas_las_dimensiones
    check (hilos = bloque_x::bigint * bloque_y * grid_x * grid_y)
);

-- Publicaciones ---------------------------------------------------------------
-- imagen_clave es la ruta en Storage; la URL firmada la genera el backend al consultar.
-- Si se borra el procesamiento del historial, la publicación sigue con su imagen.
create table public.publicaciones (
  id               uuid primary key default gen_random_uuid(),
  autor_id         uuid not null references public.perfiles (id) on delete cascade,
  procesamiento_id uuid unique references public.procesamientos (id) on delete set null,
  imagen_clave     text not null,
  filtro           text not null
                   check (filtro in ('media', 'nitidez', 'laplaciano', 'sobel', 'relieve', 'ups')),
  texto            text not null default ''
                   check (char_length(texto) <= 500),
  privada          boolean not null default false,
  creada           timestamptz not null default now(),
  actualizada      timestamptz not null default now()
);

-- Inicio: solo públicas, de la más nueva a la más vieja.
create index publicaciones_inicio_cursor
  on public.publicaciones (creada desc, id desc)
  where not privada;

-- Publicaciones de un usuario (cuadrícula del perfil).
create index publicaciones_autor_cursor
  on public.publicaciones (autor_id, creada desc, id desc);

create trigger publicaciones_actualizada
  before update on public.publicaciones
  for each row execute function public.marcar_actualizado();

-- Comentarios -----------------------------------------------------------------
create table public.comentarios (
  id             uuid primary key default gen_random_uuid(),
  publicacion_id uuid not null references public.publicaciones (id) on delete cascade,
  autor_id       uuid not null references public.perfiles (id) on delete cascade,
  texto          text not null
                 check (char_length(btrim(texto)) between 1 and 300),
  creado         timestamptz not null default now()
);

-- Sirve para recorrer en ambos sentidos (más antiguos arriba).
create index comentarios_publicacion_cursor
  on public.comentarios (publicacion_id, creado, id);

create index comentarios_autor on public.comentarios (autor_id);

-- Me gusta --------------------------------------------------------------------
create table public.me_gusta (
  publicacion_id uuid not null references public.publicaciones (id) on delete cascade,
  usuario_id     uuid not null references public.perfiles (id) on delete cascade,
  creado         timestamptz not null default now(),
  primary key (publicacion_id, usuario_id)
);

create index me_gusta_usuario on public.me_gusta (usuario_id);

-- Seguidores ------------------------------------------------------------------
-- seguidor_id sigue a seguido_id. La lista solo la ve su dueño (fase de seguridad).
create table public.seguidores (
  seguidor_id uuid not null references public.perfiles (id) on delete cascade,
  seguido_id  uuid not null references public.perfiles (id) on delete cascade,
  creado      timestamptz not null default now(),
  primary key (seguidor_id, seguido_id),
  constraint seguidores_no_a_si_mismo check (seguidor_id <> seguido_id)
);

-- Lista de seguidores de una persona, por cursor.
create index seguidores_seguido_cursor
  on public.seguidores (seguido_id, creado desc, seguidor_id desc);
