module Que
  module Data
    module Extension
      def retrieve_data
        if attrs[:job_id].nil?
          raise "Unable to retrieve data without a job_id"
        end

        results = Que.execute(Que::Data::SQL[:get], [attrs[:job_id]])
        if results.size != 1
          raise "Unable to find a data result"
        else
          
        end
        JSON.parse(results.first[:data])
      end

      def update_data(value, section: nil, property: nil)
        if attrs[:job_id].nil?
          raise "Unable to update data without a job_id"
        end

        if section.nil?
          Que.execute(Que::Data::SQL[:update], [attrs[:job_id], value])
          return
        end

        if property.nil?
          Que.execute(Que::Data::SQL[:update_section], [attrs[:job_id], "{#{section}}", value])
          return
        end

        Que.execute(Que::Data::SQL[:update_section_property], [attrs[:job_id], section, property, value])
      end
    end
  end
end

Que::Job.prepend Que::Data::Extension