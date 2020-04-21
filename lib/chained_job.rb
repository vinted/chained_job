# frozen_string_literal: true

require 'chained_job/config'
require 'chained_job/version'

module ChainedJob
  class Error < StandardError; end
  class ConfigurationError < Error; end

  module_function

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
