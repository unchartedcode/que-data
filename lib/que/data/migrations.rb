# frozen_string_literal: true

module Que
  module Data
    module Migrations
      # In order to ship a schema change, add the relevant up and down sql files
      # to the migrations directory, and bump the version both here and in the
      # add_que generator template.
      CURRENT_VERSION = 2

      class << self
        def migrate!(options = {:version => CURRENT_VERSION})
          Que.transaction do
            version = options[:version]

            if (current = db_version) == version
              return
            elsif current < version
              direction = 'up'
              steps = ((current + 1)..version).to_a
            elsif current > version
              direction = 'down'
              steps = ((version + 1)..current).to_a.reverse
            end

            steps.each do |step|
              sql = File.read("#{File.dirname(__FILE__)}/migrations/#{step}/#{direction}.sql")
              Que.execute(sql)
            end
          end
        end

        def db_version
          result = Que.execute <<-SQL
            SELECT COALESCE(
              (
                SELECT MAX(CASE attname WHEN 'data' THEN 1 WHEN 'status' THEN 2 ELSE 0 END)
                  FROM pg_attribute
                 WHERE attrelid = 'que_jobs'::regclass
                   AND attname IN ('data','status')
                   AND NOT attisdropped
                   AND attnum > 0
              ),
              0
            ) as version
          SQL

          if result.none?
            # No table in the database at all.
            0
          elsif (d = result.first[:version]).nil?
            # There's a table, it was just created before the migration system existed.
            1
          else
            d.to_i
          end
        end
      end
    end
  end
end
