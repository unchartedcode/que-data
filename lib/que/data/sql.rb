module Que
  module Data
    SQL = {
      get: %(
        SELECT data
          FROM que_jobs
         WHERE job_id = $1::integer
      ).freeze,

      update_section: %(
        UPDATE que_jobs
           SET data = jsonb_set(data, $2::text[], $3::jsonb)
         WHERE job_id = $1::integer
      ).freeze,

      update_section_property: %(
        UPDATE que_jobs
           SET data = jsonb_set(data, $2::text[], coalesce(data->$3::text,'{}'::jsonb) || jsonb_build_object($4::text, $5::text))
         WHERE job_id = $1::integer
      ).freeze,

      update_status: %(
        UPDATE que_jobs
           SET status = $2::text
             , data = jsonb_set(data, '{status}', coalesce(data->'status','{}'::jsonb) || jsonb_build_object($3::text, extract(epoch from date_trunc('second', now()))))
         WHERE job_id = $1::integer
      ).freeze,
    }.freeze
  end
end
