drop trigger if exists trg_user_settings_updated_at on public.user_settings;
create trigger trg_user_settings_updated_at
before update on public.user_settings
for each row execute procedure public.set_updated_at_now();

drop trigger if exists trg_user_last_delivered_card_updated_at on public.user_last_delivered_card;
create trigger trg_user_last_delivered_card_updated_at
before update on public.user_last_delivered_card
for each row execute procedure public.set_updated_at_now();

drop trigger if exists trg_user_quote_state_updated_at on public.user_quote_state;
create trigger trg_user_quote_state_updated_at
before update on public.user_quote_state
for each row execute procedure public.set_updated_at_now();
