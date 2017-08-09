require 'que/data/extension'

module Que
  module Data
    autoload :Migrations, 'que/data/migrations'
    autoload :SQL, 'que/data/sql'
    autoload :Version, 'que/data/version'

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
