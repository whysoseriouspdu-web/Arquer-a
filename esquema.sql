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
-- Función auxiliar: en qué club estoy.
-- Va como security definer para que la política de profiles no se
-- consulte a sí misma (eso da "infinite recursion detected in policy").
-- ---------------------------------------------------------------------
create or replace function mi_club() returns uuid
  language sql stable security definer set search_path = public as
$$ select club_id from profiles where id = auth.uid() $$;

alter table clubs            enable row level security;
alter table profiles         enable row level security;
alter table sessions         enable row level security;
alter table session_archers  enable row level security;

-- borra las políticas del script viejo, si existen
drop policy if exists "veo mi perfil y el de mi club" on profiles;
drop policy if exists "edito mi perfil" on profiles;
drop policy if exists "creo mi perfil" on profiles;
drop policy if exists "veo mis sesiones y las compartidas del club" on sessions;
drop policy if exists "creo mis sesiones" on sessions;
drop policy if exists "edito mis sesiones" on sessions;
drop policy if exists "borro mis sesiones" on sessions;
drop policy if exists "veo planillas de sesiones que puedo ver" on session_archers;
drop policy if exists "cargo planillas en mis sesiones" on session_archers;
drop policy if exists "veo mi club" on clubs;

-- perfiles
create policy "veo mi perfil" on profiles for select using (id = auth.uid());
create policy "veo perfiles de mi club" on profiles for select
  using (club_id is not null and club_id = mi_club());
create policy "creo mi perfil" on profiles for insert with check (id = auth.uid());
create policy "edito mi perfil" on profiles for update using (id = auth.uid());

-- sesiones
create policy "veo mis sesiones" on sessions for select using (owner = auth.uid());
create policy "veo las compartidas del club" on sessions for select
  using (compartida and club_id is not null and club_id = mi_club());
create policy "veo sesiones donde tiré" on sessions for select
  using (exists (select 1 from session_archers sa
                 where sa.session_id = sessions.id and sa.profile_id = auth.uid()));
create policy "creo mis sesiones" on sessions for insert with check (owner = auth.uid());
create policy "edito mis sesiones" on sessions for update using (owner = auth.uid());
create policy "borro mis sesiones" on sessions for delete using (owner = auth.uid());

-- planillas de cada arquero
create policy "veo planillas que puedo ver" on session_archers for select
  using (exists (select 1 from sessions s where s.id = session_id));
create policy "manejo planillas de mis sesiones" on session_archers for all
  using      (exists (select 1 from sessions s where s.id = session_id and s.owner = auth.uid()))
  with check (exists (select 1 from sessions s where s.id = session_id and s.owner = auth.uid()));

-- clubes
create policy "veo mi club" on clubs for select using (id = mi_club());
