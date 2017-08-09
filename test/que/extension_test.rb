require "test_helper"
require "byebug"

describe Que::Data::Extension do
  before do
    DB[:que_jobs].delete
  end

  class FakeDestroyJob < Que::Job
    def destroy
      # Fake destroy so the entry stays
      @destroyed = true
    end
  end

  class TestUpdateJob < FakeDestroyJob
    def run(*args)
      update_data({ test: '1' })
    end
  end

  it "it can update data" do
    job = TestUpdateJob.enqueue
    job.attrs[:job_id].wont_be_nil
    result = Que::Job.work
    result[:event].must_equal :job_worked, result[:error]
    DB[:que_jobs].count.must_equal 1
    DB[:que_jobs].first[:data].must_equal(%({"test": "1"}))
  end

  class TestUpdateJobSection < FakeDestroyJob
    def run(*args)
      update_data({ test: '1' }, section: 'section')
    end
  end

  it "it can update a data section" do
    job = TestUpdateJobSection.enqueue
    job.attrs[:job_id].wont_be_nil
    result = Que::Job.work
    result[:event].must_equal :job_worked, result[:error]
    DB[:que_jobs].count.must_equal 1
    DB[:que_jobs].first[:data].must_equal(%({"section": {"test": "1"}}))
  end

  class TestUpdateJobSectionProperty < FakeDestroyJob
    def run(*args)
      update_data('1', section: 'section', property: 'test')
    end
  end

  it "it can update a property in a section" do
    job = TestUpdateJobSectionProperty.enqueue
    job.attrs[:job_id].wont_be_nil
    result = Que::Job.work
    result[:event].must_equal :job_worked, result[:error]
    DB[:que_jobs].count.must_equal 1
    DB[:que_jobs].first[:data].must_equal(%({"section": {"test": "1"}}))
  end

  class TestRetrieveData < FakeDestroyJob
    class << self
      @retrieved_data = nil
      attr_accessor :retrieved_data
    end

    def run(*args)
      self.class.retrieved_data = retrieve_data
    end
  end

  it "it can retrieve data" do
    job = TestRetrieveData.enqueue
    Que.execute(Que::Data::SQL[:update], [job.attrs[:job_id], { "test" => "1" }])
    result = Que::Job.work
    result[:event].must_equal :job_worked, result[:error]
    TestRetrieveData.retrieved_data.must_equal({ "test" => "1" })
  end
end
