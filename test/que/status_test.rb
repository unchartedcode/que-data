require "test_helper"

describe 'status' do
  before do
    DB[:que_jobs].delete
    DB[:que_history].delete
  end

  it "it starts out as queued" do
    job = HistoryJob.enqueue
    job.attrs[:job_id].wont_be_nil
    DB[:que_jobs].count.must_equal 1
    DB[:que_jobs].first[:status].must_equal 'queued'
  end

  class WorkingJob < HistoryJob
    def run(*args)
      DB[:que_jobs].first[:status].must_equal 'working'
    end
  end

  it "moves to working" do
    job = WorkingJob.enqueue
    job.attrs[:job_id].wont_be_nil
    DB[:que_jobs].count.must_equal 1
    result = Que::Job.work
    result[:event].must_equal :job_worked, result[:error]
    DB[:que_jobs].count.must_equal 0
    DB[:que_history].count.must_equal 1
    data = JSON.parse(DB[:que_history].first[:data])
    data.dig('status','started_at').wont_be_nil
    data.dig('status','errored_at').must_be_nil
    data.dig('status','completed_at').wont_be_nil
  end

  class CompleteJob < HistoryJob
    def run(*args)
    end
  end

  it "moves to complete" do
    job = CompleteJob.enqueue
    job.attrs[:job_id].wont_be_nil
    DB[:que_jobs].count.must_equal 1
    result = Que::Job.work
    result[:event].must_equal :job_worked, result[:error]
    DB[:que_jobs].count.must_equal 0
    DB[:que_history].count.must_equal 1
    DB[:que_history].first[:status].must_equal 'complete'
    data = JSON.parse(DB[:que_history].first[:data])
    data.dig('status','started_at').wont_be_nil
    data.dig('status','errored_at').must_be_nil
    data.dig('status','completed_at').wont_be_nil
  end

  class ErrorJob < HistoryJob
    def run(*args)
      fail 'nope'
    end
  end

  it "moves to error" do
    job = ErrorJob.enqueue
    job.attrs[:job_id].wont_be_nil
    DB[:que_jobs].count.must_equal 1
    result = Que::Job.work
    result[:event].must_equal :job_errored, result[:error]
    DB[:que_jobs].count.must_equal 1
    DB[:que_history].count.must_equal 0
    DB[:que_jobs].first[:status].must_equal 'error'
    data = JSON.parse(DB[:que_jobs].first[:data])
    data.dig('status','started_at').wont_be_nil
    data.dig('status','errored_at').wont_be_nil
    data.dig('status','completed_at').must_be_nil
  end
end
