# frozen_string_literal: true

require 'chained_job/config'
require 'chained_job/perform_method'
require 'chained_job/version'

module ChainedJob
  class Error < StandardError; end
  class ConfigurationError < Error; end

  module_function

  def self.included(target_class)
    ChainedJob::PerformMethod.run(target_class)
  end

  def redis
    config.redis || raise(ConfigurationError, 'Redis is not configured')
  end

  def config
    @config ||= ChainedJob::Config.new
  end

  def configure
    yield(config)
  end
end
