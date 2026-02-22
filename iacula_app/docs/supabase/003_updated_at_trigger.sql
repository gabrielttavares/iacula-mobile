create or replace function public.set_updated_at_now()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_plan_of_life_entries_updated_at on public.plan_of_life_entries;
create trigger trg_plan_of_life_entries_updated_at
before update on public.plan_of_life_entries
for each row execute procedure public.set_updated_at_now();

drop trigger if exists trg_examination_entries_updated_at on public.examination_entries;
create trigger trg_examination_entries_updated_at
before update on public.examination_entries
for each row execute procedure public.set_updated_at_now();

drop trigger if exists trg_prayer_intention_entries_updated_at on public.prayer_intention_entries;
create trigger trg_prayer_intention_entries_updated_at
before update on public.prayer_intention_entries
for each row execute procedure public.set_updated_at_now();
