-- Durable transcription job state.
--
-- The Flask service previously kept jobs in a module-level dict, but it runs
-- under `gunicorn --workers 2`: a POST /transcribe handled by worker 1 and the
-- follow-up GET /transcribe/status/<id> handled by worker 2 would 404. Job
-- state has to live somewhere both workers can see.
--
-- Only the service role touches this table (RLS is on with no policies), and
-- the API scopes every read to the requesting user.

create table if not exists public.transcription_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'processing', 'complete', 'failed')),
  transcript text,
  error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists transcription_jobs_user_created_idx
  on public.transcription_jobs (user_id, created_at desc);

alter table public.transcription_jobs enable row level security;

-- Housekeeping: finished jobs are only needed until the client has polled for
-- the result. Call from a pg_cron schedule or a periodic task.
create or replace function public.purge_old_transcription_jobs()
returns void
language sql
security definer
set search_path = public
as $$
  delete from public.transcription_jobs
  where created_at < now() - interval '24 hours';
$$;
