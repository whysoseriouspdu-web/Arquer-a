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

-- Configuraciones de material del arquero
create table if not exists equipos (
  id uuid primary key default gen_random_uuid(),
  owner uuid not null references profiles on delete cascade,
  nombre text not null,
  tipo text default 'recurvo',
  pot_nominal numeric, pot_real numeric,
  longitud_arco numeric, brace numeric,
  fl_marca text, fl_modelo text, spine text,
  fl_longitud numeric, fl_peso numeric, plumas text,
  visor text, estabilizadores text, cuerda text,
  notas text,
  actualizado timestamptz default now()
);
create index if not exists ix_equipos_owner on equipos (owner);

alter table sessions add column if not exists equipo_id uuid references equipos on delete set null;
alter table sessions add column if not exists condiciones jsonb;
alter table sessions add column if not exists codigo text;            -- para unirse en vivo
alter table sessions add column if not exists estado text not null default 'cerrada';  -- abierta | cerrada
create unique index if not exists ix_sessions_codigo on sessions (codigo) where codigo is not null;
alter table session_archers add column if not exists actualizado timestamptz default now();
alter table profiles add column if not exists lateralidad text;
alter table profiles add column if not exists ojo_dominante text;
alter table profiles add column if not exists longitud_tiro numeric;

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

alter table equipos          enable row level security;
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
      and tablename in ('profiles','sessions','session_archers','clubs','equipos')
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

-- equipos: cada uno el suyo; el entrenador los ve para entender los números
create policy "veo mis equipos" on equipos for select using (owner = auth.uid());
create policy "el entrenador ve los equipos del club" on equipos for select
  using (soy_entrenador() and exists (
    select 1 from profiles p where p.id = equipos.owner and p.club_id = mi_club()));
create policy "el superadmin ve los equipos" on equipos for select using (es_superadmin());
create policy "manejo mis equipos" on equipos for all
  using (owner = auth.uid()) with check (owner = auth.uid());

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


-- =====================================================================
-- Sesiones grupales en vivo
-- Cada arquero anota lo suyo desde su celular; el marcador se puede
-- mostrar en una pantalla sin iniciar sesión, solo con el código.
-- =====================================================================

-- Datos de la sesión abierta, para quien va a unirse
create or replace function sesion_por_codigo(p_codigo text)
  returns table (id uuid, fecha timestamptz, distancia int, flechas_serie int,
                 series_previstas int, metodo text, cara int, tipo text,
                 anotador text, estado text)
  language sql stable security definer set search_path = public as $$
  select s.id, s.fecha, s.distancia, s.flechas_serie, s.series_previstas,
         s.metodo, s.cara, s.tipo, p.nombre, s.estado
    from sessions s join profiles p on p.id = s.owner
   where s.codigo is not null and upper(s.codigo) = upper(trim(p_codigo));
$$;

-- Puestos de esa sesión: quién está libre y quién ya lo tomó
create or replace function puestos(p_sesion uuid)
  returns table (id uuid, nombre text, tomado boolean, mio boolean)
  language sql stable security definer set search_path = public as $$
  select sa.id, sa.nombre, sa.profile_id is not null, sa.profile_id = auth.uid()
    from session_archers sa
   where sa.session_id = p_sesion
   order by sa.nombre;
$$;

-- Tomar un puesto libre
create or replace function tomar_puesto(p_archer uuid)
  returns uuid language plpgsql security definer set search_path = public as $$
declare ses uuid; dueno uuid; est text;
begin
  if auth.uid() is null then raise exception 'Hay que iniciar sesión'; end if;
  select sa.session_id, sa.profile_id into ses, dueno from session_archers sa where sa.id = p_archer;
  if ses is null then raise exception 'Ese puesto no existe'; end if;
  select s.estado into est from sessions s where s.id = ses;
  if est <> 'abierta' then raise exception 'La sesión ya está cerrada'; end if;
  if dueno is not null and dueno <> auth.uid() then raise exception 'Ese puesto ya lo tomó otro arquero'; end if;
  if exists (select 1 from session_archers where session_id = ses
             and profile_id = auth.uid() and id <> p_archer)
    then raise exception 'Ya tenés un puesto en esta sesión'; end if;
  update session_archers
     set profile_id = auth.uid(),
         nombre = coalesce((select nombre from profiles where id = auth.uid()), nombre),
         actualizado = now()
   where id = p_archer;
  return ses;
end $$;

-- Guardar mis flechas. Solo toca mi propia planilla.
create or replace function guardar_puesto(p_archer uuid, p_ends jsonb)
  returns void language plpgsql security definer set search_path = public as $$
declare ses uuid;
begin
  select sa.session_id into ses from session_archers sa
   where sa.id = p_archer and sa.profile_id = auth.uid();
  if ses is null then raise exception 'Ese puesto no es tuyo'; end if;
  if (select estado from sessions where id = ses) <> 'abierta'
    then raise exception 'La sesión ya está cerrada'; end if;
  update session_archers set ends = p_ends, actualizado = now() where id = p_archer;
  update sessions set actualizado = now() where id = ses;
end $$;

-- Marcador público por código: no pide cuenta, para mostrarlo en una pantalla
create or replace function marcador(p_codigo text)
  returns table (sesion uuid, distancia int, flechas_serie int, series_previstas int,
                 estado text, anotador text, nombre text, ends jsonb, actualizado timestamptz)
  language sql stable security definer set search_path = public as $$
  select s.id, s.distancia, s.flechas_serie, s.series_previstas, s.estado,
         p.nombre, sa.nombre, sa.ends, sa.actualizado
    from sessions s
    join profiles p on p.id = s.owner
    join session_archers sa on sa.session_id = s.id
   where s.codigo is not null and upper(s.codigo) = upper(trim(p_codigo))
   order by sa.nombre;
$$;

-- Cerrar la sesión: deja de aceptar cargas y de aparecer por código
create or replace function cerrar_sesion(p_sesion uuid)
  returns void language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from sessions where id = p_sesion and owner = auth.uid())
    then raise exception 'No sos el anotador de esa sesión'; end if;
  update sessions set estado = 'cerrada', actualizado = now() where id = p_sesion;
end $$;

-- el marcador se consulta sin cuenta, el resto no
grant execute on function marcador(text) to anon;
grant execute on function sesion_por_codigo(text) to anon;
