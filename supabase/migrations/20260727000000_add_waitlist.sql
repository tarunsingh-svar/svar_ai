-- Early-access waitlist for the marketing website (svar_website).
-- RLS is enabled with NO policies: the anon key can neither insert nor
-- read. All writes go through the website's server route using the
-- service role key, which bypasses RLS.

create extension if not exists citext with schema extensions;

create table if not exists public.waitlist (
  id uuid primary key default gen_random_uuid(),
  email extensions.citext not null unique,
  source text,
  user_agent text,
  created_at timestamptz not null default now()
);

alter table public.waitlist enable row level security;
