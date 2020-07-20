# frozen_string_literal: true

module ChainedJob
  module Helpers
    module_function

    def job_key(job_class)
      "chained_job:#{job_class}"
    end

    def redis_key(key, tag)
      "chained_job:#{key}:#{tag}"
    end

    def tag_list(job_class)
      "#{job_class}:tags"
    end
  end
end
