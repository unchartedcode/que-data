require 'test_helper'

describe Que::Data::Migrations do
  before do
    DB.drop_table? :que_jobs
    Que.migrate!
  end

  after do
    DB.drop_table? :que_jobs
    Que.migrate!
    Que::Data.migrate!
  end

  it "it starts out at 0" do
    Que::Data::Migrations.db_version.must_equal 0
  end

  describe 'version 1' do
    it "can migrate up" do
      Que::Data.migrate! version: 1
      Que::Data::Migrations.db_version.must_equal 1
    end

    it "can migrate down" do
      Que::Data.migrate! version: 1
      Que::Data::Migrations.db_version.must_equal 1
      Que::Data.migrate! version: 0
      Que::Data::Migrations.db_version.must_equal 0
    end
  end

  describe 'version 2' do
    it "can migrate up" do
      Que::Data.migrate! version: 2
      Que::Data::Migrations.db_version.must_equal 2
    end

    it "can migrate back down to 0" do
      Que::Data.migrate! version: 2
      Que::Data.migrate! version: 1
      Que::Data::Migrations.db_version.must_equal 1
    end
  end
end
