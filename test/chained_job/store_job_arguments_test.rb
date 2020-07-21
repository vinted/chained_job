# frozen_string_literal: true

require 'minitest/autorun'

class ChainedJob::StoreJobArgumentsTest < Minitest::Test
  ARRAY_OF_JOB_ARGUMENTS = %w(1 2 3).freeze

  def test_redis_store
    tested_class.run(job_class, job_tag, ARRAY_OF_JOB_ARGUMENTS)

    assert_equal(redis.lrange(redis_key, 0, -1), ARRAY_OF_JOB_ARGUMENTS)
  end

  def test_set_tag_list
    tag_list = "chained_job:#{job_class}:tags"

    tested_class.run(job_class, job_tag, ARRAY_OF_JOB_ARGUMENTS)

    assert_equal(redis.spop(tag_list), job_tag)
  end

  def test_key_expiration
    tested_class.run(job_class, job_tag, ARRAY_OF_JOB_ARGUMENTS)

    assert_equal(redis.ttl(redis_key), ChainedJob.config.arguments_queue_expiration)
  end

  private

  def tested_class
    ChainedJob::StoreJobArguments
  end

  def job_class
    'DummyJob'
  end

  def job_tag
    current_time.to_f.to_s
  end

  def redis_key
    "chained_job:#{job_class}:#{job_tag}"
  end

  def current_time
    @current_time ||= Time.now
  end

  def setup
    ChainedJob.configure do |config|
      config.redis = redis
    end
  end

  def redis
    @redis ||= MockRedis.new
  end

  def teardown
    ChainedJob.instance_variable_set(:@config, nil)
  end
end
