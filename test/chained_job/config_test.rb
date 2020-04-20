# frozen_string_literal: true

require 'chained_job/config'
require 'minitest/autorun'

class ChainedJob::ConfigTest < Minitest::Test
  def test_default_debug_value
    assert_equal true, default_config.debug
  end

  def test_default_arguments_batch_size
    assert_equal 1_000, default_config.arguments_batch_size
  end

  def test_configure
    ChainedJob.configure do |config|
      config.debug = false
      config.arguments_batch_size = 2_000
    end

    assert_equal false, ChainedJob.config.debug
    assert_equal 2_000, ChainedJob.config.arguments_batch_size
  end

  private

  def default_config
    @default_config ||= tested_class.new
  end

  def tested_class
    ChainedJob::Config
  end
end
