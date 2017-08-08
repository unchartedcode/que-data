# frozen_string_literal: true

class AddQueData < ActiveRecord::Migration[4.2]
  def self.up
    # The current version as of this migration's creation.
    Que::Data.migrate! :version => 1
  end

  def self.down
    # Completely removes Que's job queue.
    Que::Data.migrate! :version => 0
  end
end
