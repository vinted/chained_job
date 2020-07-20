# frozen_string_literal: true

require 'chained_job/helpers'

module ChainedJob
  class Process
    def self.run(job_instance, worker_id, job_tag)
      new(job_instance, worker_id, job_tag).run
    end

    attr_reader :job_instance, :worker_id, :job_tag

    def initialize(job_instance, worker_id, job_tag)
      @job_instance = job_instance
      @worker_id = worker_id
    end

    def run
      with_hooks do
        return log_finished_worker unless argument

        job_instance.process(argument)
        job_instance.class.perform_later(worker_id, job_tag)
      end
    end

    private

    def with_hooks
      ChainedJob.config.around_chain_process.call(options) { yield }
    end

    def options
      { job_class: job_instance.class, worker_id: worker_id }
    end

    def log_finished_worker
      ChainedJob.logger.info(
        "#{job_instance.class} worker #{worker_id} finished"
      )
    end

    def argument
      @argument ||= ChainedJob.redis.lpop(redis_key)
    end

    def redis_key
      Helpers.redis_key(job_instance.class)
    end
  end
end
