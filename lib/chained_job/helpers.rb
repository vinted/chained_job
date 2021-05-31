# frozen_string_literal: true

module ChainedJob
  module Helpers
    module_function

    def job_key(job_arguments_key)
      "chained_job:#{job_arguments_key}"
    end

    def redis_key(job_key, tag)
      "#{job_key}:#{tag}"
    end

    def tag_list(prefix)
      "#{prefix}:tags"
    end
  end
end
