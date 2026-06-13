-- Display name editable from Settings > User Info.
alter table public.user_details
  add column if not exists name text;
