create table if not exists public.user_premium (
  id uuid primary key references auth.users(id) on delete cascade,
  is_premium boolean not null default false,
  purchase_date timestamptz,
  store_transaction_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_premium enable row level security;

drop policy if exists "Users can view own premium" on public.user_premium;
create policy "Users can view own premium"
  on public.user_premium
  for select
  using (auth.uid() = id);

drop policy if exists "Users can insert own premium" on public.user_premium;
create policy "Users can insert own premium"
  on public.user_premium
  for insert
  with check (auth.uid() = id);

drop policy if exists "Users can update own premium" on public.user_premium;
create policy "Users can update own premium"
  on public.user_premium
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop trigger if exists user_premium_set_updated_at on public.user_premium;
create trigger user_premium_set_updated_at
before update on public.user_premium
for each row execute function public.set_updated_at();
