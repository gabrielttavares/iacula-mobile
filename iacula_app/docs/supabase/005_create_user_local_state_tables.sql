create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  interval_minutes integer not null,
  duration_seconds integer not null,
  autostart boolean not null,
  language text not null,
  liturgy_sound_enabled boolean not null,
  liturgy_sound_volume double precision not null,
  laudes_enabled boolean not null,
  vespers_enabled boolean not null,
  compline_enabled boolean not null,
  ora_media_enabled boolean not null,
  laudes_time text not null,
  vespers_time text not null,
  compline_time text not null,
  ora_media_time text not null,
  onboarding_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_last_delivered_card (
  user_id uuid primary key references auth.users(id) on delete cascade,
  quote_text text not null,
  theme text not null,
  season text not null,
  image_path text,
  feast text,
  feast_name text,
  delivered_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_quote_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  last_day integer not null,
  quote_indices_json jsonb not null default '{}'::jsonb,
  image_indices_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
