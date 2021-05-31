# frozen_string_literal: true

require 'chained_job/helpers'
require 'chained_job/clean_up_queue'
require 'chained_job/store_job_arguments'

module ChainedJob
  class StartChains
    def self.run(args, job_class, job_arguments_key, array_of_job_arguments, parallelism)
      new(args, job_class, job_arguments_key, array_of_job_arguments, parallelism).run
    end

    attr_reader :args, :job_class, :job_arguments_key, :array_of_job_arguments, :parallelism

    def initialize(args, job_class, job_arguments_key, array_of_job_arguments, parallelism)
      @args = args
      @job_class = job_class
      @job_arguments_key = job_arguments_key
      @array_of_job_arguments = array_of_job_arguments
      @parallelism = parallelism
    end

    # rubocop:disable Metrics/AbcSize
    def run
      with_hooks do
        log_chained_job_cleanup

        ChainedJob::CleanUpQueue.run(job_arguments_key)

        next unless array_of_job_arguments.count.positive?

        ChainedJob::StoreJobArguments.run(job_arguments_key, job_tag, array_of_job_arguments)

        log_chained_job_start

        parallelism.times { |worked_id| job_class.perform_later(args, worked_id, job_tag) }
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def with_hooks
      ChainedJob.config.around_start_chains.call(options) { yield }
    end

    def options
      {
        job_class: job_class,
        array_of_job_arguments: array_of_job_arguments,
        parallelism: parallelism,
      }
    end

    def job_tag
      @job_tag ||= Time.now.to_f.to_s
    end

    def log_chained_job_start
      ChainedJob.logger.info(
        "#{job_class}:#{job_tag} starting #{parallelism} workers "\
        "processing #{array_of_job_arguments.count} items"
      )
    end

    def log_chained_job_cleanup
      ChainedJob.logger.info(
        "#{job_class}:#{job_tag} cleanup"
      )
    end
  end
end
