# frozen_string_literal: true

require 'chained_job/helpers'
require 'minitest/autorun'

class ChainedJob::HelpersTest < Minitest::Test
  def test_redis_key_fetching
    job_class = 'DummyJob'

    assert_equal "chained_job:#{job_class}", ChainedJob::Helpers.redis_key(job_class)
  end
end
