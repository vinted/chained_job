# frozen_string_literal: true

require 'mock_redis'
require 'minitest/autorun'

class ChainedJob::ProcessTest < Minitest::Test
  def test_process_chai
    mock_class.expect(:class, klass, [])
    mock_class.expect(:process, nil, ['1'])
    mock_class.expect(:class, klass, [])
    klass.expect(:perform_later, nil, [1])

    tested_class.run(mock_class, 1)

    mock_class.verify
  end

  def test_empty_arguments_queue
    redis.lpop(redis_key)

    mock_class.expect(:class, klass, [])
    tested_class.run(mock_class, 1)

    mock_class.verify
  end

  private

  def setup
    ChainedJob.configure do |config|
      config.redis = redis
    end

    redis.rpush(redis_key, %w(1))
  end

  def teardown
    ChainedJob.instance_variable_set(:@config, nil)
  end

  def mock_class
    @mock_class ||= MiniTest::Mock.new
  end

  def redis
    @redis ||= MockRedis.new
  end

  def redis_key
    "chained_job:#{klass}"
  end

  def klass
    @klass ||= MiniTest::Mock.new
  end

  def tested_class
    ChainedJob::Process
  end
end
