-- Enable Row Level Security and add owner-only policies.
--
-- Access model: a row belongs to the authenticated user identified by
-- user_id = auth.uid(). The Flutter app uses the public anon key, so RLS is
-- the only database-level boundary protecting per-user data.
--
-- RLS is enabled and policies are added together so access is never left
-- fully open and is never fully blocked.

-- transcribe -----------------------------------------------------------------

alter table public.transcribe enable row level security;

create policy "transcribe_select_own"
  on public.transcribe
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "transcribe_insert_own"
  on public.transcribe
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- UPDATE needs both USING (to find/select the row) and WITH CHECK (to validate
-- the new row), otherwise updates silently affect 0 rows or allow reassignment.
create policy "transcribe_update_own"
  on public.transcribe
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "transcribe_delete_own"
  on public.transcribe
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- user_details ---------------------------------------------------------------

alter table public.user_details enable row level security;

create policy "user_details_select_own"
  on public.user_details
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "user_details_insert_own"
  on public.user_details
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "user_details_update_own"
  on public.user_details
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
