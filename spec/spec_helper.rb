# frozen_string_literal: true

require 'chained_job'
require 'mock_redis'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.allow_message_expectations_on_nil = true
  end

  config.before do |_example|
    ChainedJob.configure do |chained_job_config|
      chained_job_config.redis = MockRedis.new
    end
  end
end
