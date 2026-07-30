-- Cloud storage for note recordings.
--
-- Until now audio only ever existed on the device that recorded it (the app
-- kept a local file path in SharedPreferences), so a note recorded on a phone
-- had no playable audio anywhere else. Moving recordings into Storage is what
-- makes the same note usable on web and on a second device.
--
-- Objects are keyed by owner: `<user_id>/<timestamp>-<random>.<ext>`. The RLS
-- policies below read that first path segment, so a user can only ever touch
-- their own prefix.

-- transcribe.audio_path --------------------------------------------------------
-- Null for manual notes and for recordings made before this migration.
alter table public.transcribe
  add column if not exists audio_path text;

-- Storage bucket ---------------------------------------------------------------
-- Private: playback goes through short-lived signed URLs rather than public
-- object URLs, so a leaked link expires on its own.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'note-audio',
  'note-audio',
  false,
  524288000, -- 500 MB, enough for multi-hour recordings
  array[
    'audio/webm',
    'audio/ogg',
    'audio/mp4',
    'audio/mpeg',
    'audio/aac',
    'audio/x-m4a',
    'audio/wav'
  ]
)
on conflict (id) do update
  set file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Storage policies -------------------------------------------------------------
-- storage.foldername(name) splits the object path; element 1 is the owner id.

drop policy if exists "note_audio_select_own" on storage.objects;
create policy "note_audio_select_own"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'note-audio'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "note_audio_insert_own" on storage.objects;
create policy "note_audio_insert_own"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'note-audio'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "note_audio_update_own" on storage.objects;
create policy "note_audio_update_own"
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'note-audio'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'note-audio'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "note_audio_delete_own" on storage.objects;
create policy "note_audio_delete_own"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'note-audio'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Clean up orphaned audio ------------------------------------------------------
-- Both clients delete the object through the Storage API before deleting the
-- note, which is the only path that reclaims the underlying file. This trigger
-- is a backstop for rows removed some other way (direct SQL, a cascade from
-- auth.users): dropping the storage.objects row makes the recording
-- inaccessible and unlistable, though the bytes themselves are only reclaimed
-- by the Storage API or a bucket sweep.
create or replace function public.delete_note_audio_object()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.audio_path is not null then
    delete from storage.objects
    where bucket_id = 'note-audio'
      and name = old.audio_path;
  end if;
  return old;
end;
$$;

drop trigger if exists transcribe_delete_audio_object on public.transcribe;

create trigger transcribe_delete_audio_object
  after delete on public.transcribe
  for each row
  execute function public.delete_note_audio_object();
