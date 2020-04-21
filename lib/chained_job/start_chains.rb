# frozen_string_literal: true

module ChainedJob
  class StartChains
    def self.run(target_class, array_of_job_arguments, parallelism)
      new(target_class, array_of_job_arguments, parallelism).run
    end

    attr_reader :target_class, :array_of_job_arguments, :parallelism

    def initialize(target_class, array_of_job_arguments, parallelism)
      @target_class = target_class
      @array_of_job_arguments = array_of_job_arguments
      @parallelism = parallelism
    end

    def run
      redis.del(redis_key)

      return unless array_of_job_arguments.count.positive?

      store_job_arguments

      parallelism.times { |worked_id| target_class.perform_later(worked_id) }
    end

    private

    def store_job_arguments
      array_of_job_arguments.each_slice(config.arguments_batch_size) do |sublist|
        redis.rpush(redis_key, sublist)
      end

      redis.expire(redis_key, config.arguments_queue_expiration)
    end

    def redis
      ChainedJob.redis
    end

    def redis_key
      "chained_job:#{target_class}"
    end

    def config
      ChainedJob.config
    end
  end
end
