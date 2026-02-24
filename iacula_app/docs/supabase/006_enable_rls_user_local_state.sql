alter table public.user_settings enable row level security;
alter table public.user_last_delivered_card enable row level security;
alter table public.user_quote_state enable row level security;

drop policy if exists user_settings_select_own on public.user_settings;
drop policy if exists user_settings_insert_own on public.user_settings;
drop policy if exists user_settings_update_own on public.user_settings;

create policy user_settings_select_own
  on public.user_settings
  for select
  using (auth.uid() = user_id);

create policy user_settings_insert_own
  on public.user_settings
  for insert
  with check (auth.uid() = user_id);

create policy user_settings_update_own
  on public.user_settings
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists user_last_delivered_card_select_own on public.user_last_delivered_card;
drop policy if exists user_last_delivered_card_insert_own on public.user_last_delivered_card;
drop policy if exists user_last_delivered_card_update_own on public.user_last_delivered_card;

create policy user_last_delivered_card_select_own
  on public.user_last_delivered_card
  for select
  using (auth.uid() = user_id);

create policy user_last_delivered_card_insert_own
  on public.user_last_delivered_card
  for insert
  with check (auth.uid() = user_id);

create policy user_last_delivered_card_update_own
  on public.user_last_delivered_card
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists user_quote_state_select_own on public.user_quote_state;
drop policy if exists user_quote_state_insert_own on public.user_quote_state;
drop policy if exists user_quote_state_update_own on public.user_quote_state;

create policy user_quote_state_select_own
  on public.user_quote_state
  for select
  using (auth.uid() = user_id);

create policy user_quote_state_insert_own
  on public.user_quote_state
  for insert
  with check (auth.uid() = user_id);

create policy user_quote_state_update_own
  on public.user_quote_state
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
