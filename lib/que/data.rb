module Que
  module Data
    autoload :Migrations, 'que/data/migrations'
    autoload :SQL, 'que/data/sql'
    autoload :Version, 'que/data/version'
    autoload :Extension, 'que/data/extension'

    class << self
      def migrate!(version = {:version => Migrations::CURRENT_VERSION})
        Migrations.migrate!(version)
      end

      def init!
        Que::Job.prepend Que::Data::Extension
      end
    end
  end
end
