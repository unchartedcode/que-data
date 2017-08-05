ALTER TABLE que_jobs
  ADD COLUMN data jsonb not null default '{}'::jsonb
