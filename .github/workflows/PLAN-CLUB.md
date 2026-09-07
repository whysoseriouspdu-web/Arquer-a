# Versión de club con cuentas — plan de trabajo

## Cómo queda

La misma app que ya tenés, más un servidor de datos (Supabase). Cada socio entra
con su mail, tira desde su propio celular y los datos suben solos. Se sigue
instalando desde el navegador, funciona igual en iPhone y Android, y sigue
andando sin señal: guarda local y sincroniza cuando vuelve la conexión.

Roles pensados:

- **Arquero** — carga sus sesiones, ve su historial y su progreso.
- **Anotador** — además puede cargar una sesión grupal con varios arqueros del
  club; a cada uno le llega su planilla al historial propio.
- **Entrenador** — ve el historial de los arqueros que tiene a cargo.

## Lo que tenés que hacer vos (una vez, 20 minutos)

1. Crear cuenta gratis en supabase.com → *New project*.
   Región: elegí `South America (São Paulo)`, es la más cerca.
2. Anotá la contraseña de la base que te pide al crear el proyecto.
3. En el panel, andá a *SQL Editor*, pegá el bloque de más abajo y ejecutalo.
4. En *Project Settings → API* copiá dos datos y pasámelos:
   - **Project URL** (algo como `https://xxxx.supabase.co`)
   - **anon public key** (una clave larga)

Esa clave `anon` va dentro de la app y es pública a propósito: la seguridad real
la dan las políticas RLS del script, que impiden que alguien vea datos de otro.
La que **nunca** se comparte ni se pone en la app es la `service_role`.

## El esquema

```sql
-- Clubes
create table clubs (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  creado timestamptz default now()
);

-- Perfil de cada socio, colgado del usuario de login
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  nombre text not null,
  club_id uuid references clubs,
  rol text not null default 'arquero',   -- arquero | anotador | entrenador
  modalidad text default 'recurvo',
  creado timestamptz default now()
);

-- Una sesión de entrenamiento
create table sessions (
  id uuid primary key default gen_random_uuid(),
  owner uuid not null references profiles on delete cascade,
  club_id uuid references clubs,
  fecha timestamptz not null,
  distancia int not null,
  flechas_serie int not null,
  series_previstas int,
  lugar text,
  nota text,
  compartida boolean default false,      -- visible para el club
  actualizado timestamptz default now()
);

-- Cada arquero dentro de la sesión, con sus flechas
create table session_archers (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references sessions on delete cascade,
  profile_id uuid references profiles,   -- null si es un invitado sin cuenta
  nombre text not null,
  ends jsonb not null default '[]',      -- [["X","10","9"],["8","7","M"]]
  total int generated always as (0) stored -- se calcula en la app
);

create index on sessions (owner, fecha desc);
create index on session_archers (session_id);
create index on session_archers (profile_id);

-- Seguridad
alter table profiles enable row level security;
alter table sessions enable row level security;
alter table session_archers enable row level security;
alter table clubs enable row level security;

create policy "veo mi perfil y el de mi club" on profiles for select
  using (id = auth.uid() or club_id = (select club_id from profiles where id = auth.uid()));
create policy "edito mi perfil" on profiles for update using (id = auth.uid());
create policy "creo mi perfil" on profiles for insert with check (id = auth.uid());

create policy "veo mis sesiones y las compartidas del club" on sessions for select
  using (
    owner = auth.uid()
    or (compartida and club_id = (select club_id from profiles where id = auth.uid()))
    or exists (select 1 from session_archers sa
               where sa.session_id = sessions.id and sa.profile_id = auth.uid())
  );
create policy "creo mis sesiones" on sessions for insert with check (owner = auth.uid());
create policy "edito mis sesiones" on sessions for update using (owner = auth.uid());
create policy "borro mis sesiones" on sessions for delete using (owner = auth.uid());

create policy "veo planillas de sesiones que puedo ver" on session_archers for select
  using (exists (select 1 from sessions s where s.id = session_id));
create policy "cargo planillas en mis sesiones" on session_archers for all
  using (exists (select 1 from sessions s where s.id = session_id and s.owner = auth.uid()));

create policy "veo mi club" on clubs for select
  using (id = (select club_id from profiles where id = auth.uid()));
```

## Lo que hago yo después

1. Login por mail con enlace mágico (sin contraseñas que recordar).
2. Alta de perfil y elección de club en el primer ingreso.
3. Cola de sincronización: todo se guarda primero en el teléfono y se sube
   cuando hay red. Si tirás sin señal, no perdés nada.
4. Pantalla de club: quién entrenó esta semana, promedios, ranking por distancia.
5. Migración de lo que ya tenés cargado local, para que no arranques de cero.

## Costos

Plan gratuito de Supabase: 500 MB de base y 50.000 usuarios activos por mes.
Un club de 60 socios tirando tres veces por semana usa una fracción mínima de eso.
El hosting de la app sigue siendo gratis en GitHub Pages. Total: cero.

Si algún día quieren estar en las tiendas: Google Play 25 dólares por única vez,
Apple 99 dólares por año. No hace falta para que funcione.

## Antes de arrancar, definí con la comisión

- Quién es dueño de los datos: cada arquero o el club.
- Si el entrenador ve todo o solo los suyos.
- Si hay menores, autorización de los padres para guardar sus puntajes.
- Qué pasa cuando alguien se va del club.

Son cinco minutos de charla y evitan tener que rehacer permisos después.
