# frozen_string_literal: true

require 'mock_redis'
require 'minitest/autorun'

class ChainedJob::StartChainsTest < Minitest::Test
  ARRAY_OF_JOB_ARGUMENTS = %w(1 2 3).freeze

  def test_start_chains
    job_tag = current_time.to_f.to_s

    with_frozen_time(current_time) do
      job_class.expect(:perform_later, nil, [0, job_tag])
      job_class.expect(:perform_later, nil, [1, job_tag])

      tested_class.run(job_class, job_class, ARRAY_OF_JOB_ARGUMENTS, 2)

      job_class.verify
    end
  end

  def test_empty_array_of_job_arguments
    with_frozen_time(current_time) do
      tested_class.run(job_class, job_class, [], 1)
    end
  end

  private

  def with_frozen_time(time)
    Time.stub(:now, time) { yield }
  end

  def current_time
    @current_time ||= Time.now
  end

  def setup
    ChainedJob.configure do |config|
      config.redis = MockRedis.new
    end
  end

  def teardown
    ChainedJob.instance_variable_set(:@config, nil)
  end

  def job_class
    @job_class ||= MiniTest::Mock.new
  end

  def tested_class
    ChainedJob::StartChains
  end
end
