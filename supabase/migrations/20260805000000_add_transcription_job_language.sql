-- Records what language was asked for and which STT vendor answered.
--
-- Transcription now routes between two providers (Sarvam for Indian languages,
-- OpenAI for the rest), with a fallback when one fails. Without these columns,
-- a report of "my transcript came back wrong" gives no way to tell which vendor
-- produced it or whether a fallback fired.

alter table public.transcription_jobs
  add column if not exists requested_language text,
  add column if not exists provider text;

comment on column public.transcription_jobs.requested_language is
  'Language the client asked for. Null means auto-detect.';

comment on column public.transcription_jobs.provider is
  'STT vendor that produced the transcript: sarvam or openai.';
