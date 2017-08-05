require 'test_helper'

describe Que::Data::Migrations do
  before do
    DB.drop_table? :que_jobs
    Que::Migrations.migrate!
  end

  it "it starts out at 0" do
    Que::Data::Migrations.db_version.must_equal 0
  end

  it "can migrate to 1" do
    Que::Data.migrate!
    Que::Data::Migrations.db_version.must_equal 1
  end

  it "can migrate back down to 0" do
    Que::Data.migrate!
    Que::Data::Migrations.db_version.must_equal 1
    Que::Data.migrate! version: 0
    Que::Data::Migrations.db_version.must_equal 0
  end
end
