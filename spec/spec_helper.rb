# frozen_string_literal: true

require 'chained_job'
require 'testcontainers/redis'
require 'redis-client'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.allow_message_expectations_on_nil = true
  end

  container = Testcontainers::RedisContainer.new('redis:7.2.4-alpine3.19')
  container.start

  redis_client = RedisClient.new(url: container.redis_url)

  config.before do |_example|
    ChainedJob.configure do |chained_job_config|
      chained_job_config.redis = redis_client
    end

    redis_client.call(:flushdb)
  end

  config.after(:suite) do
    container.stop.delete
  end
end
