# frozen_string_literal: true

module ChainedJob
  module Helpers
    module_function

    def redis_key(job_class)
      "chained_job:#{job_class}"
    end
  end
end
