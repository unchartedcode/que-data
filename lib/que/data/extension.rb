module Que
  module Data
    module Extension
      module ClassMethods
        def retrieve_data(job_id)
          if job_id.nil?
            raise "Unable to retrieve data without a job_id"
          end

          results = Que.execute(Que::Data::SQL[:get], [job_id])
          if results.size != 1
            raise "Unable to find a data result"
          else
            
          end
          JSON.parse(results.first[:data])
        end

        def update_data(job_id, value, section: nil, property: nil)
          if job_id.nil?
            raise "Unable to update data without a job_id"
          end

          if section.nil?
            Que.execute(Que::Data::SQL[:update], [job_id, value])
            return
          end

          if property.nil?
            Que.execute(Que::Data::SQL[:update_section], [job_id, "{#{section}}", value])
            return
          end

          Que.execute(Que::Data::SQL[:update_section_property], [job_id, section, property, value])
        end
      end

      def self.prepended(base)
        class << base
          prepend ClassMethods
        end  
      end

      def retrieve_data
        self.class.retrieve_data(attrs[:job_id])
      end

      def update_data(*args)
        self.class.update_data(attrs[:job_id], **args)
      end
    end
  end
end
