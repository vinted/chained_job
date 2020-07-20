# frozen_string_literal: true

require 'chained_job/helpers'

module ChainedJob
  class CleanUpQueue
    def self.run(job_class)
      new(job_class).run
    end

    TRIM_STEP_SIZE = 1_000

    attr_reader :job_class

    def initialize(job_class)
      @job_class = job_class
    end

    def run
      loop do
        tag = redis.spop(tag_list)

        break unless tag

        size = redis.llen(redis_key(tag))
        (size / TRIM_STEP_SIZE).times { redis.ltrim(redis_key(tag), 0, -TRIM_STEP_SIZE) }
        redis.del(redis_key(tag))
      end
    end

    private

    def tag_list
      @tag_list ||= Helpers.tag_list(job_key)
    end

    def redis_key(tag)
      @redis_key ||= Helpers.redis_key(job_key, tag)
    end

    def job_key
      @job_key ||= Helpers.job_key(job_class)
    end

    def redis
      ChainedJob.redis
    end
  end
end
