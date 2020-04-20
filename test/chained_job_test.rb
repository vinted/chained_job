# frozen_string_literal: true

require 'chained_job'
require 'minitest/autorun'

class ChainedJobTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ChainedJob::VERSION
  end
end
