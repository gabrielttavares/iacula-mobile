alter table public.plan_of_life_entries enable row level security;
alter table public.examination_entries enable row level security;
alter table public.prayer_intention_entries enable row level security;

drop policy if exists plan_of_life_entries_select_own on public.plan_of_life_entries;
drop policy if exists plan_of_life_entries_insert_own on public.plan_of_life_entries;
drop policy if exists plan_of_life_entries_update_own on public.plan_of_life_entries;
drop policy if exists plan_of_life_entries_delete_own on public.plan_of_life_entries;

create policy plan_of_life_entries_select_own
  on public.plan_of_life_entries
  for select
  using (auth.uid() = user_id);

create policy plan_of_life_entries_insert_own
  on public.plan_of_life_entries
  for insert
  with check (auth.uid() = user_id);

create policy plan_of_life_entries_update_own
  on public.plan_of_life_entries
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy plan_of_life_entries_delete_own
  on public.plan_of_life_entries
  for delete
  using (auth.uid() = user_id);

drop policy if exists examination_entries_select_own on public.examination_entries;
drop policy if exists examination_entries_insert_own on public.examination_entries;
drop policy if exists examination_entries_update_own on public.examination_entries;
drop policy if exists examination_entries_delete_own on public.examination_entries;

create policy examination_entries_select_own
  on public.examination_entries
  for select
  using (auth.uid() = user_id);

create policy examination_entries_insert_own
  on public.examination_entries
  for insert
  with check (auth.uid() = user_id);

create policy examination_entries_update_own
  on public.examination_entries
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy examination_entries_delete_own
  on public.examination_entries
  for delete
  using (auth.uid() = user_id);

drop policy if exists prayer_intention_entries_select_own on public.prayer_intention_entries;
drop policy if exists prayer_intention_entries_insert_own on public.prayer_intention_entries;
drop policy if exists prayer_intention_entries_update_own on public.prayer_intention_entries;
drop policy if exists prayer_intention_entries_delete_own on public.prayer_intention_entries;

create policy prayer_intention_entries_select_own
  on public.prayer_intention_entries
  for select
  using (auth.uid() = user_id);

create policy prayer_intention_entries_insert_own
  on public.prayer_intention_entries
  for insert
  with check (auth.uid() = user_id);

create policy prayer_intention_entries_update_own
  on public.prayer_intention_entries
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy prayer_intention_entries_delete_own
  on public.prayer_intention_entries
  for delete
  using (auth.uid() = user_id);
