create extension if not exists pgcrypto;

create table if not exists public.plan_of_life_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text null,
  body text not null,
  schedule_json jsonb null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz null,
  device_id text null
);

create table if not exists public.examination_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text null,
  body text not null,
  schedule_json jsonb null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz null,
  device_id text null
);

create table if not exists public.prayer_intention_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text null,
  body text not null,
  schedule_json jsonb null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz null,
  device_id text null
);

create index if not exists idx_plan_of_life_entries_user_id on public.plan_of_life_entries(user_id);
create index if not exists idx_plan_of_life_entries_updated_at on public.plan_of_life_entries(updated_at);
create index if not exists idx_plan_of_life_entries_deleted_at on public.plan_of_life_entries(deleted_at);

create index if not exists idx_examination_entries_user_id on public.examination_entries(user_id);
create index if not exists idx_examination_entries_updated_at on public.examination_entries(updated_at);
create index if not exists idx_examination_entries_deleted_at on public.examination_entries(deleted_at);

create index if not exists idx_prayer_intention_entries_user_id on public.prayer_intention_entries(user_id);
create index if not exists idx_prayer_intention_entries_updated_at on public.prayer_intention_entries(updated_at);
create index if not exists idx_prayer_intention_entries_deleted_at on public.prayer_intention_entries(deleted_at);
