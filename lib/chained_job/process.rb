# frozen_string_literal: true

module ChainedJob
  class Process
    def self.run(job_instance, worker_id)
      new(job_instance, worker_id).run
    end

    attr_reader :job_instance, :worker_id

    def initialize(job_instance, worker_id)
      @job_instance = job_instance
      @worker_id = worker_id
    end

    def run
      return log_finished_worker unless argument

      job_instance.process(argument)
      job_instance.class.perform_later(worker_id)
    end

    private

    def log_finished_worker
      ChainedJob.logger.info(
        "#{job_instance.class} worker #{worker_id} finished"
      )
    end

    def argument
      @argument ||= ChainedJob.redis.lpop(redis_key)
    end

    def redis_key
      "chained_job:#{job_instance.class}"
    end
  end
end
