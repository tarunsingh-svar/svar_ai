-- Subscription entitlement + lifetime note counter.
--
-- public.profiles is the server-side source of truth for a user's plan.
-- - Entitlement columns (entitlement/plan/is_lifetime/pro_expires_at) are
--   written ONLY by the RevenueCat webhook using the service role key.
-- - notes_created_count is a monotonic lifetime counter incremented by a
--   trigger on insert into public.transcribe; deleting a note does NOT
--   decrement it, enforcing the free-tier "10 notes total" cap.
--
-- RLS exposes read-only access to the owner. There are deliberately no client
-- write policies, so a free user cannot grant themselves Pro or reset the
-- counter from the app.

create table if not exists public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  entitlement text not null default 'free', -- 'free' | 'pro'
  plan text,                                -- 'monthly' | 'yearly' | 'lifetime'
  is_lifetime boolean not null default false,
  pro_expires_at timestamptz,
  rc_app_user_id text,
  notes_created_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Owner may read their own profile (plan + counter).
create policy "profiles_select_own"
  on public.profiles
  for select
  to authenticated
  using (auth.uid() = user_id);

-- Lifetime note counter -------------------------------------------------------
-- SECURITY DEFINER so the increment bypasses RLS (clients cannot write profiles
-- directly). Upserts a row on the user's first note.
create or replace function public.increment_notes_created_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id, notes_created_count)
  values (new.user_id, 1)
  on conflict (user_id)
  do update
    set notes_created_count = public.profiles.notes_created_count + 1,
        updated_at = now();
  return new;
end;
$$;

drop trigger if exists transcribe_increment_note_count on public.transcribe;

create trigger transcribe_increment_note_count
  after insert on public.transcribe
  for each row
  execute function public.increment_notes_created_count();
