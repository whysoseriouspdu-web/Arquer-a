-- =====================================================================
-- Registro de arquería — esquema completo y corregido
-- Pegá TODO esto en Supabase → SQL Editor → Run.
-- Es seguro correrlo aunque ya hayas ejecutado la versión anterior.
-- =====================================================================

create table if not exists clubs (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  creado timestamptz default now()
);

create table if not exists profiles (
  id uuid primary key references auth.users on delete cascade,
  nombre text not null,
  club_id uuid references clubs,
  rol text not null default 'arquero',      -- arquero | anotador | entrenador
  modalidad text default 'recurvo',
  creado timestamptz default now()
);

create table if not exists sessions (
  id uuid primary key default gen_random_uuid(),
  owner uuid not null references profiles on delete cascade,
  club_id uuid references clubs,
  fecha timestamptz not null,
  distancia int not null,
  flechas_serie int not null,
  series_previstas int,
  lugar text,
  nota text,
  compartida boolean default false,
  actualizado timestamptz default now()
);

alter table clubs    add column if not exists codigo text unique;
alter table sessions add column if not exists tipo text not null default 'entrenamiento';
  -- tipo: entrenamiento | competencia
alter table sessions add column if not exists metodo text not null default 'teclado';
  -- metodo: teclado | diana
alter table sessions add column if not exists cara int;
  -- cara: diámetro en cm cuando se anota sobre la diana

create table if not exists session_archers (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references sessions on delete cascade,
  profile_id uuid references profiles,      -- null si es un invitado sin cuenta
  nombre text not null,
  ends jsonb not null default '[]'
);

-- la columna "total" del script anterior no servía para nada
alter table session_archers drop column if exists total;

create index if not exists ix_sessions_owner on sessions (owner, fecha desc);
create index if not exists ix_archers_session on session_archers (session_id);
create index if not exists ix_archers_profile on session_archers (profile_id);

-- ---------------------------------------------------------------------
-- Funciones auxiliares. Van como security definer para que se ejecuten
-- sin volver a disparar las políticas: si una política de sessions
-- consulta session_archers y la de session_archers consulta sessions,
-- Postgres corta con "infinite recursion detected in policy" (42P17).
-- ---------------------------------------------------------------------
create or replace function mi_club() returns uuid
  language sql stable security definer set search_path = public as
$$ select club_id from profiles where id = auth.uid() $$;

-- rol del usuario actual
create or replace function mi_rol() returns text
  language sql stable security definer set search_path = public as
$$ select coalesce((select rol from profiles where id = auth.uid()), 'arquero') $$;

create or replace function es_superadmin() returns boolean
  language sql stable security definer set search_path = public as
$$ select mi_rol() = 'superadmin' $$;

create or replace function soy_admin() returns boolean
  language sql stable security definer set search_path = public as
$$ select mi_rol() in ('admin','superadmin') $$;

create or replace function soy_entrenador() returns boolean
  language sql stable security definer set search_path = public as
$$ select mi_rol() in ('entrenador','admin','superadmin') $$;

-- ¿tiré yo en esta sesión?
create or replace function tire_en_sesion(sid uuid) returns boolean
  language sql stable security definer set search_path = public as
$$ select exists (select 1 from session_archers
                  where session_id = sid and profile_id = auth.uid()) $$;

-- ¿la sesión es mía?
create or replace function soy_dueno_sesion(sid uuid) returns boolean
  language sql stable security definer set search_path = public as
$$ select exists (select 1 from sessions where id = sid and owner = auth.uid()) $$;

-- ¿puedo ver esta sesión, por cualquiera de los tres motivos?
create or replace function puedo_ver_sesion(sid uuid) returns boolean
  language sql stable security definer set search_path = public as
$$ select exists (
     select 1 from sessions s
     where s.id = sid
       and ( es_superadmin()
             or s.owner = auth.uid()
             or tire_en_sesion(s.id)
             or (soy_entrenador() and s.club_id is not null and s.club_id = mi_club())
             or (s.compartida and s.club_id is not null and s.club_id = mi_club()) )) $$;

-- sumarse a un club con un código corto
create or replace function unirme_a_club(codigo text) returns uuid
  language plpgsql security definer set search_path = public as $$
declare c uuid;
begin
  select id into c from clubs where upper(clubs.codigo) = upper(unirme_a_club.codigo);
  if c is null then raise exception 'Código de club inválido'; end if;
  update profiles set club_id = c where id = auth.uid();
  return c;
end $$;

-- toda sesión hereda el club de quien la cargó
create or replace function set_session_club() returns trigger
  language plpgsql security definer set search_path = public as $$
begin
  if new.club_id is null then
    select club_id into new.club_id from profiles where id = new.owner;
  end if;
  return new;
end $$;

drop trigger if exists trg_session_club on sessions;
create trigger trg_session_club before insert or update on sessions
  for each row execute function set_session_club();

alter table clubs            enable row level security;
alter table profiles         enable row level security;
alter table sessions         enable row level security;
alter table session_archers  enable row level security;

-- Borra TODAS las políticas existentes de estas tablas, se llamen como se
-- llamen. Así el script se puede volver a correr las veces que haga falta.
do $$
declare p record;
begin
  for p in
    select policyname, tablename from pg_policies
    where schemaname = 'public'
      and tablename in ('profiles','sessions','session_archers','clubs')
  loop
    execute format('drop policy if exists %I on public.%I', p.policyname, p.tablename);
  end loop;
end $$;

-- perfiles
create policy "veo mi perfil" on profiles for select using (id = auth.uid());
create policy "veo perfiles de mi club" on profiles for select
  using (club_id is not null and club_id = mi_club());
create policy "el superadmin ve todos los perfiles" on profiles for select
  using (es_superadmin());
create policy "creo mi perfil" on profiles for insert with check (id = auth.uid());
create policy "edito mi perfil" on profiles for update using (id = auth.uid());

-- sesiones
create policy "veo mis sesiones" on sessions for select using (owner = auth.uid());
create policy "veo las compartidas del club" on sessions for select
  using (compartida and club_id is not null and club_id = mi_club());
create policy "veo sesiones donde tiré" on sessions for select
  using (tire_en_sesion(id));
create policy "el entrenador ve todo su club" on sessions for select
  using (soy_entrenador() and club_id is not null and club_id = mi_club());
create policy "el superadmin ve todo" on sessions for select using (es_superadmin());
create policy "creo mis sesiones" on sessions for insert with check (owner = auth.uid());
create policy "edito mis sesiones" on sessions for update using (owner = auth.uid());
create policy "borro mis sesiones" on sessions for delete using (owner = auth.uid());

-- planillas de cada arquero
create policy "veo planillas que puedo ver" on session_archers for select
  using (puedo_ver_sesion(session_id));
create policy "manejo planillas de mis sesiones" on session_archers for all
  using      (soy_dueno_sesion(session_id))
  with check (soy_dueno_sesion(session_id));

-- clubes
create policy "veo mi club" on clubs for select using (id = mi_club() or es_superadmin());
create policy "cualquiera crea un club" on clubs for insert
  with check (auth.uid() is not null);
create policy "el entrenador edita su club" on clubs for update
  using (soy_entrenador() and id = mi_club());


-- =====================================================================
-- Gestión de club y socios desde la app
-- =====================================================================

-- Crear un club. Quien lo crea queda como admin del club.
create or replace function crear_club(p_nombre text, p_codigo text)
  returns uuid language plpgsql security definer set search_path = public as $$
declare c uuid;
begin
  if auth.uid() is null then raise exception 'Hay que iniciar sesión'; end if;
  if coalesce(trim(p_nombre),'') = '' or coalesce(trim(p_codigo),'') = '' then
    raise exception 'Falta el nombre o el código';
  end if;
  if exists (select 1 from clubs where upper(codigo) = upper(trim(p_codigo))) then
    raise exception 'Ese código ya está en uso';
  end if;
  insert into clubs (nombre, codigo) values (trim(p_nombre), upper(trim(p_codigo)))
    returning id into c;
  update profiles
     set club_id = c,
         rol = case when rol = 'superadmin' then rol else 'admin' end
   where id = auth.uid();
  return c;
end $$;

-- Listado de socios del club, con su mail y su rol.
create or replace function socios_del_club()
  returns table (id uuid, nombre text, mail text, rol text, sesiones bigint)
  language sql stable security definer set search_path = public as $$
  select p.id, p.nombre, u.email::text, p.rol,
         (select count(*) from sessions s where s.owner = p.id)
    from profiles p
    join auth.users u on u.id = p.id
   where es_superadmin() or (p.club_id is not null and p.club_id = mi_club())
   order by p.nombre;
$$;

-- Cambiar el rol de un socio. Solo admin o superadmin.
create or replace function set_rol(p_id uuid, p_rol text)
  returns void language plpgsql security definer set search_path = public as $$
begin
  if not soy_admin() then raise exception 'No tenés permiso para cambiar roles'; end if;
  if p_rol not in ('arquero','anotador','entrenador','admin','superadmin') then
    raise exception 'Rol inválido';
  end if;
  if p_rol = 'superadmin' and not es_superadmin() then
    raise exception 'Solo un superadministrador puede nombrar otro';
  end if;
  if p_id = auth.uid() and not es_superadmin() then
    raise exception 'No podés cambiarte el rol a vos mismo';
  end if;
  if not es_superadmin() and not exists (
       select 1 from profiles where id = p_id and club_id = mi_club()) then
    raise exception 'Ese arquero no es de tu club';
  end if;
  update profiles set rol = p_rol where id = p_id;
end $$;

-- Sacar a alguien del club. No borra sus datos, solo lo desvincula.
create or replace function sacar_del_club(p_id uuid)
  returns void language plpgsql security definer set search_path = public as $$
begin
  if not soy_admin() then raise exception 'No tenés permiso'; end if;
  if p_id = auth.uid() then raise exception 'No podés sacarte a vos mismo'; end if;
  if not es_superadmin() and not exists (
       select 1 from profiles where id = p_id and club_id = mi_club()) then
    raise exception 'Ese arquero no es de tu club';
  end if;
  update profiles set club_id = null, rol = 'arquero' where id = p_id;
end $$;

-- Datos de mi club, para la pantalla de la app.
create or replace function mi_club_info()
  returns table (id uuid, nombre text, codigo text, socios bigint)
  language sql stable security definer set search_path = public as $$
  select c.id, c.nombre, c.codigo,
         (select count(*) from profiles p where p.club_id = c.id)
    from clubs c where c.id = mi_club();
$$;
