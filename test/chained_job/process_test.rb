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

  def test_handle_retry_with_single_args
    array_of_arguments = [10]

    redis.rpush(redis_key, ChainedJob::Helpers.serialize(array_of_arguments))

    job_instance.expect(:class, job_class.to_s, [])
    job_instance.expect(:class, job_class.to_s, [])

    job_instance.expect(:process, 100) do
      raise(RuntimeError, 'Service temporary timeout error')
    end

    job_instance.expect(:methods, ['handle_retry?'])
    job_instance.expect(:handle_retry?, true)

    assert_raises RuntimeError do
      tested_class.run({}, job_instance, job_instance.class, 1, DEFAULT_JOB_TAG)
    end

    job_instance.verify

    # arguments were set back to redis
    args_redis = redis.lrange(redis_key, 0, -1).map { |e| Marshal.load(e) }
    assert_equal(args_redis, array_of_arguments.reverse)
  end

  def test_handle_retry_with_multiple_args
    array_of_arguments = [101, 102]

    redis.rpush(redis_key, ChainedJob::Helpers.serialize(array_of_arguments))

    job_instance.expect(:class, job_class.to_s, [])
    job_instance.expect(:class, job_class.to_s, [])

    job_instance.expect(:process, 100) do
      raise(RuntimeError, 'Service temporary timeout error')
    end

    job_instance.expect(:methods, ['handle_retry?'])
    job_instance.expect(:handle_retry?, true)

    assert_raises RuntimeError do
      tested_class.run({}, job_instance, job_instance.class, 1, DEFAULT_JOB_TAG)
    end

    job_instance.verify

    # arguments were set back to redis
    args_redis = redis.lrange(redis_key, 0, -1).map { |e| Marshal.load(e) }
    assert_equal(args_redis, array_of_arguments.reverse)
  end

  def test_handle_retry_with_args_of_array
    array_of_arguments = [[1, 2], [3, 4]]

    redis.rpush(redis_key, ChainedJob::Helpers.serialize(array_of_arguments))

    job_instance.expect(:class, job_class.to_s, [])
    job_instance.expect(:class, job_class.to_s, [])

    job_instance.expect(:process, [1, 2]) do
      raise(RuntimeError, 'Service temporary timeout error')
    end

    job_instance.expect(:methods, ['handle_retry?'])
    job_instance.expect(:handle_retry?, true)

    assert_raises RuntimeError do
      tested_class.run({}, job_instance, job_instance.class, 1, DEFAULT_JOB_TAG)
    end

    job_instance.verify

    # arguments were set back to redis
    args_redis = redis.lrange(redis_key, 0, -1).map { |e| Marshal.load(e) }
    assert_equal(args_redis, array_of_arguments.reverse)
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
