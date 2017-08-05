module Que
  module Data
    SQL = {
      get: %(
        SELECT data
          FROM que_jobs
         WHERE job_id = $1::integer
      ).freeze,

      update: %(
        UPDATE que_jobs
           SET data = $2::jsonb
         WHERE job_id = $1::integer
      ).freeze,

      update_section: %(
        UPDATE que_jobs
           SET data = jsonb_set(data, $2::text[], $3::jsonb)
         WHERE job_id = $1::integer
      ).freeze,

      update_section_property: %(
        UPDATE que_jobs
           SET data = data || jsonb_build_object($2::text, jsonb_build_object($3::text, $4::text))
         WHERE job_id = $1::integer
      ).freeze
    }.freeze
  end
end
