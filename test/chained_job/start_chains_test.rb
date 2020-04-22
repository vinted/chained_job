# frozen_string_literal: true

require 'mock_redis'
require 'minitest/autorun'

class ChainedJob::StartChainsTest < Minitest::Test
  ARRAY_OF_JOB_ARGUMENTS = %w(1 2 3).freeze

  def test_start_chains
    job_class.expect(:perform_later, nil, [0])
    job_class.expect(:perform_later, nil, [1])

    tested_class.run(job_class, ARRAY_OF_JOB_ARGUMENTS, 2)

    job_class.verify
  end

  def test_redis_store
    job_class.expect(:perform_later, nil, [0])

    tested_class.run(job_class, ARRAY_OF_JOB_ARGUMENTS, 1)

    assert_equal redis.lrange("chained_job:#{job_class}", 0, -1), ARRAY_OF_JOB_ARGUMENTS
    job_class.verify
  end

  def test_empty_array_of_job_arguments
    tested_class.run(job_class, [], 1)
  end

  private

  def setup
    ChainedJob.configure do |config|
      config.redis = redis
    end
  end

  def teardown
    ChainedJob.instance_variable_set(:@config, nil)
  end

  def job_class
    @job_class ||= MiniTest::Mock.new
  end

  def redis
    @redis ||= MockRedis.new
  end

  def tested_class
    ChainedJob::StartChains
  end
end
