ALTER TABLE que_jobs
  ADD COLUMN status text not null default 'queued';
