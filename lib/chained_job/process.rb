# frozen_string_literal: true

require 'chained_job/helpers'

module ChainedJob
  class Process
    def self.run(args, job_instance, job_arguments_key, worker_id, job_tag)
      new(args, job_instance, job_arguments_key, worker_id, job_tag).run
    end

    attr_reader :args, :job_instance, :job_arguments_key, :worker_id, :job_tag

    def initialize(args, job_instance, job_arguments_key, worker_id, job_tag)
      @args = args
      @job_instance = job_instance
      @job_arguments_key = job_arguments_key
      @worker_id = worker_id
      @job_tag = job_tag
    end

    def run
      return run_with_retry if handle_retry?

      with_hooks do
        return finished_worker unless argument

        job_instance.process(argument)
        job_instance.class.perform_later(args, worker_id, job_tag)
      end
    end

    private

    def run_with_retry
      with_hooks do
        return finished_worker unless argument

        begin
          job_instance.process(argument)
        rescue StandardError, Sidekiq::Shutdown => e
          push_job_arguments_back
          raise e
        end
        job_instance.class.perform_later(args, worker_id, job_tag)
      end
    end

    def handle_retry?
      job_instance.try(:handle_retry?)
    end

    def with_hooks
      ChainedJob.config.around_chain_process.call(options) { yield }
    end

    def options
      @options ||= { job_class: job_instance.class, worker_id: worker_id, args: args }
    end

    def finished_worker
      log_finished_worker

      ChainedJob.config.after_worker_finished&.call(options)
    end

    def log_finished_worker
      ChainedJob.logger.info(
        "#{job_instance.class}:#{job_tag} worker #{worker_id} finished"
      )
    end

    def argument
      @argument ||= deserialized_argument
    end

    def deserialized_argument
      return unless serialized_argument

      Marshal.load(serialized_argument)
    end

    def serialized_argument
      return @serialized_argument if defined?(@serialized_argument)

      @serialized_argument = ChainedJob.redis.lpop(redis_key)
    end

    def redis_key
      Helpers.redis_key(job_key, job_tag)
    end

    def job_key
      Helpers.job_key(job_arguments_key)
    end

    def push_job_arguments_back
      ChainedJob.redis.rpush(redis_key, Helpers.serialize([argument]))
    end
  end
end
