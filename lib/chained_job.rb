# frozen_string_literal: true

require 'chained_job/config'
require 'chained_job/version'

module ChainedJob
  module_function

  def config
    @config ||= ChainedJob::Config.new
  end

  def configure
    yield(config)
  end
end
