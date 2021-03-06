# frozen_string_literal: true

require 'chained_job'
require 'mock_redis'
require 'minitest/autorun'

class ChainedJob::ProcessTest < Minitest::Test
  DEFAULT_JOB_TAG = '1595253473.6297688'

  # rubocop:disable Metrics/AbcSize
  def test_process
    redis.rpush(redis_key, [Marshal.dump(1)])

    job_instance.expect(:class, job_class, [])
    job_instance.expect(:class, job_class, [])
    job_instance.expect(:class, job_class, [])
    job_instance.expect(:process, nil, [1])
    job_class.expect(:perform_later, nil, [{}, 1, DEFAULT_JOB_TAG])

    tested_class.run({}, job_instance, job_instance.class, 1, DEFAULT_JOB_TAG)

    job_instance.verify
  end

  def test_empty_arguments_queue
    job_instance.expect(:class, job_class, [])
    job_instance.expect(:class, job_class, [])
    job_instance.expect(:class, job_class, [])
    tested_class.run({}, job_instance, job_instance.class, 1, DEFAULT_JOB_TAG)

    job_instance.verify
  end
  # rubocop:enable Metrics/AbcSize

  private

  def setup
    ChainedJob.configure do |config|
      config.redis = redis
    end
  end

  def teardown
    ChainedJob.instance_variable_set(:@config, nil)
  end

  def job_instance
    @job_instance ||= MiniTest::Mock.new
  end

  def redis
    @redis ||= MockRedis.new
  end

  def redis_key
    "chained_job:#{job_class}:#{DEFAULT_JOB_TAG}"
  end

  def job_class
    @job_class ||= MiniTest::Mock.new
  end

  def tested_class
    ChainedJob::Process
  end
end
