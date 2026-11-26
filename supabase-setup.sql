-- Kočky doma: shared storage for the household.
-- Run once in Supabase → SQL Editor. Safe to run again.
-- Everyone who can sign in shares all data, so switch OFF public sign-ups
-- (Authentication → Sign In / Providers → "Allow new users to sign up")
-- and add household members by hand (Authentication → Users → Add user).

create table if not exists public.items (
  kind       text        not null,              -- 'cats' | 'log' | 'meta'
  id         text        not null,
  data       jsonb,
  deleted    boolean     not null default false,
  modified   bigint      not null default 0,    -- client edit time (ms); newer edit wins
  updated_at timestamptz not null default now(), -- server time, used to fetch changes
  primary key (kind, id)
);
create index if not exists items_updated_at on public.items (updated_at);

alter table public.items enable row level security;
drop policy if exists "household members" on public.items;
create policy "household members" on public.items
  for all to authenticated using (true) with check (true);

create or replace function public.items_touch() returns trigger
language plpgsql as $$
begin
  new.updated_at := clock_timestamp();
  return new;
end $$;

drop trigger if exists items_touch on public.items;
create trigger items_touch before insert or update on public.items
  for each row execute function public.items_touch();

-- Upsert a batch; an older edit never overwrites a newer one.
create or replace function public.put_items(p jsonb) returns void
language plpgsql security invoker as $$
declare r jsonb;
begin
  for r in select * from jsonb_array_elements(p) loop
    insert into public.items (kind, id, data, deleted, modified)
    values (r->>'kind', r->>'id', r->'data',
            coalesce((r->>'deleted')::boolean, false),
            coalesce((r->>'modified')::bigint, 0))
    on conflict (kind, id) do update
      set data = excluded.data, deleted = excluded.deleted, modified = excluded.modified
      where public.items.modified < excluded.modified;
  end loop;
end $$;

grant execute on function public.put_items(jsonb) to authenticated;

-- Cat photos (private bucket, signed-in members only)
insert into storage.buckets (id, name, public)
values ('photos', 'photos', false)
on conflict (id) do nothing;

drop policy if exists "members read photos"   on storage.objects;
drop policy if exists "members add photos"    on storage.objects;
drop policy if exists "members update photos" on storage.objects;
drop policy if exists "members delete photos" on storage.objects;
create policy "members read photos"   on storage.objects for select to authenticated using (bucket_id = 'photos');
create policy "members add photos"    on storage.objects for insert to authenticated with check (bucket_id = 'photos');
create policy "members update photos" on storage.objects for update to authenticated using (bucket_id = 'photos');
create policy "members delete photos" on storage.objects for delete to authenticated using (bucket_id = 'photos');
