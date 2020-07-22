# frozen_string_literal: true

require 'chained_job/helpers'
require 'minitest/autorun'

class ChainedJob::HelpersTest < Minitest::Test
  def test_redis_key_fetching
    job_key = 'chained_job:DummyJob'
    job_tag = '1595252432.198516'

    assert_equal "#{job_key}:#{job_tag}", ChainedJob::Helpers.redis_key(job_key, job_tag)
  end

  def test_job_key_fetching
    job_class = 'DummyJob'

    assert_equal "chained_job:#{job_class}", ChainedJob::Helpers.job_key(job_class)
  end

  def test_tag_list_fetching
    prefix = 'DummyJob'

    assert_equal "#{prefix}:tags", ChainedJob::Helpers.tag_list(prefix)
  end
end
