# frozen_string_literal: true

require 'chained_job/helpers'

module ChainedJob
  class CleanUpQueue
    def self.run(job_arguments_key)
      new(job_arguments_key).run
    end

    TRIM_STEP_SIZE = 1_000

    attr_reader :job_arguments_key

    def initialize(job_arguments_key)
      @job_arguments_key = job_arguments_key
    end

    # rubocop:disable Metrics/AbcSize
    def run
      loop do
        tag = ChainedJob.redis.spop(tag_list)

        break unless tag

        redis_key = Helpers.redis_key(job_key, tag)
        size = ChainedJob.redis.llen(redis_key)
        (size / TRIM_STEP_SIZE).times { ChainedJob.redis.ltrim(redis_key, 0, -TRIM_STEP_SIZE) }

        ChainedJob.redis.del(redis_key)
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def tag_list
      @tag_list ||= Helpers.tag_list(job_key)
    end

    def job_key
      @job_key ||= Helpers.job_key(job_arguments_key)
    end
  end
end
