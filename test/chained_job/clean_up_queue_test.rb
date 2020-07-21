# frozen_string_literal: true

require 'minitest/autorun'

class ChainedJob::CleanUpQueueTest < Minitest::Test
  ARRAY_OF_JOB_ARGUMENTS = %w(1 2 3).freeze

  def test_queue_clean_up
    assert_equal(redis.lrange(redis_key(job_tag_1), 0, -1), ARRAY_OF_JOB_ARGUMENTS)
    assert_equal(redis.lrange(redis_key(job_tag_2), 0, -1), ARRAY_OF_JOB_ARGUMENTS)

    tested_class.run(job_class)

    assert_equal(redis.lrange(redis_key(job_tag_1), 0, -1), [])
    assert_equal(redis.lrange(redis_key(job_tag_2), 0, -1), [])
  end

  private

  def tested_class
    ChainedJob::CleanUpQueue
  end

  def job_class
    'DummyJob'
  end

  def redis_key(job_tag)
    "chained_job:#{job_class}:#{job_tag}"
  end

  def tag_list
    "#{job_key}:tags"
  end

  def job_key
    "chained_job:#{job_class}"
  end

  def job_tag_1
    'Tag_One'
  end

  def job_tag_2
    'Tag_Two'
  end

  def setup
    ChainedJob.configure do |config|
      config.redis = redis
    end

    redis.sadd(tag_list, job_tag_1)
    redis.sadd(tag_list, job_tag_2)
    redis.rpush(redis_key(job_tag_1), ARRAY_OF_JOB_ARGUMENTS)
    redis.rpush(redis_key(job_tag_2), ARRAY_OF_JOB_ARGUMENTS)
  end

  def redis
    @redis ||= MockRedis.new
  end

  def teardown
    ChainedJob.instance_variable_set(:@config, nil)
  end
end
