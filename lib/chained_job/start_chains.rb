# frozen_string_literal: true

module ChainedJob
  class StartChains
    def self.run(job_class, array_of_job_arguments, parallelism)
      new(job_class, array_of_job_arguments, parallelism).run
    end

    attr_reader :job_class, :array_of_job_arguments, :parallelism

    def initialize(job_class, array_of_job_arguments, parallelism)
      @job_class = job_class
      @array_of_job_arguments = array_of_job_arguments
      @parallelism = parallelism
    end

    def run
      redis.del(redis_key)

      return unless array_of_job_arguments.count.positive?

      store_job_arguments

      parallelism.times { |worked_id| job_class.perform_later(worked_id) }
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
      Helpers.redis_key(job_class)
    end

    def config
      ChainedJob.config
    end
  end
end
