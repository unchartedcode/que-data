$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'que'
require 'logger'
require 'pg'
require 'que/data'
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

Dir['./test/support/**/*.rb'].sort.each(&method(:require))

# Set up a dummy logger.
Que.logger = $logger = Object.new
$logger_mutex = Mutex.new # Protect against rare errors on Rubinius/JRuby.

def $logger.messages
  @messages ||= []
end

def $logger.method_missing(m, message)
  $logger_mutex.synchronize { messages << message }
end

# Object includes Kernel#warn which is not what we expect, so remove:
def $logger.warn(message)
  method_missing(:warn, message)
end

QUE_URL = ENV['DATABASE_URL'] || "postgres://#{ENV['USER'] || 'postgres'}:@localhost/que-test"

NEW_PG_CONNECTION = proc do
  uri = URI.parse(QUE_URL)
  pg = PG::Connection.open :host     => uri.host,
                           :user     => uri.user,
                           :password => uri.password,
                           :port     => uri.port || 5432,
                           :dbname   => uri.path[1..-1]

  # Avoid annoying NOTICE messages in specs.
  pg.async_exec "SET client_min_messages TO 'warning'"
  pg
end

Que.connection = NEW_PG_CONNECTION.call
QUE_ADAPTERS = {:pg => Que.adapter}

# We use Sequel to examine the database in specs.
require 'sequel'
DB = Sequel.connect(QUE_URL)

# Reset the table to the most up-to-date version.
DB.drop_table? :que_jobs
DB.drop_table? :que_history
Que::Migrations.migrate!
Que::Data::Migrations.migrate!

Que.execute "CREATE TABLE que_history AS SELECT * FROM que_jobs LIMIT 0"

class HistoryJob < Que::Job
  def _destroy
    sql = <<-SQL
      WITH job AS (
        DELETE
        FROM   que_jobs
        WHERE  job_id   = $1::bigint
        RETURNING *
      )
      INSERT INTO que_history
      SELECT * FROM job;
    SQL

    Que.execute sql, @attrs.values_at(:job_id)
    @destroyed = true
  end
end
