require "test_helper"
require "byebug"

describe Que::Data::Extension do
  before do
    DB[:que_jobs].delete
    DB[:que_history].delete
  end

  class TestUpdateJobSection < HistoryJob
    def run(*args)
      update_data({ test: '1' }, section: 'section')
    end
  end

  it "it can update a data section" do
    job = TestUpdateJobSection.enqueue
    job.attrs[:job_id].wont_be_nil
    result = Que::Job.work
    result[:event].must_equal :job_worked, result[:error]
    DB[:que_jobs].count.must_equal 0
    DB[:que_history].count.must_equal 1
    data = JSON.parse(DB[:que_history].first[:data])
    data['section'].must_equal({"test" => "1"})
  end

  class TestUpdateJobSectionProperty < HistoryJob
    def run(*args)
      update_data('1', section: 'section', property: 'test')
    end
  end

  it "it can update a property in a section" do
    job = TestUpdateJobSectionProperty.enqueue
    job.attrs[:job_id].wont_be_nil
    result = Que::Job.work
    result[:event].must_equal :job_worked, result[:error]
    DB[:que_jobs].count.must_equal 0
    DB[:que_history].count.must_equal 1
    data = JSON.parse(DB[:que_history].first[:data])
    data.dig('section', 'test').must_equal '1'
  end

  class TestUpdateJobSectionMultipleProperties < HistoryJob
    def run(*args)
      update_data('1', section: 'section', property: 'test1')
      update_data('1', section: 'section', property: 'test2')
    end
  end

  it "it can update a property in a section" do
    job = TestUpdateJobSectionMultipleProperties.enqueue
    job.attrs[:job_id].wont_be_nil
    result = Que::Job.work
    result[:event].must_equal :job_worked, result[:error]
    DB[:que_jobs].count.must_equal 0
    DB[:que_history].count.must_equal 1
    data = JSON.parse(DB[:que_history].first[:data])
    data.dig('section', 'test1').must_equal '1'
    data.dig('section', 'test2').must_equal '1'
  end

  class TestRetrieveData < HistoryJob
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
    Que.execute(Que::Data::SQL[:update_section], [job.attrs[:job_id], '{section}', { test: '1' }])
    result = Que::Job.work
    result[:event].must_equal :job_worked, result[:error]
    TestRetrieveData.retrieved_data.dig('section', 'test').must_equal '1'
  end
end
