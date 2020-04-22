# frozen_string_literal: true

require 'chained_job/config'
require 'mock_redis'
require 'minitest/autorun'

class ChainedJob::ConfigTest < Minitest::Test
  def test_default_debug_value
    assert_equal true, default_config.debug
  end

  def test_default_arguments_batch_size
    assert_equal 1_000, default_config.arguments_batch_size
  end

  def test_default_redis_configuration
    assert_raises(ChainedJob::ConfigurationError, 'Redis is not configured') do
      ChainedJob.redis
    end
  end

  def test_default_logger
    assert_kind_of ::Logger, default_config.logger
  end

  def test_configure
    ChainedJob.configure do |config|
      config.debug = false
      config.arguments_batch_size = 2_000
      config.redis = redis_config
    end

    assert_equal false, ChainedJob.config.debug
    assert_equal 2_000, ChainedJob.config.arguments_batch_size
    assert_equal redis_config, ChainedJob.redis
  end

  private

  def setup
    ChainedJob.instance_variable_set(:@config, nil)
  end

  def default_config
    @default_config ||= ChainedJob::Config.new
  end

  def redis_config
    @redis_config ||= MockRedis.new
  end
end
