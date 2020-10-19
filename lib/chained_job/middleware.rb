# frozen_string_literal: true

require 'chained_job/start_chains'
require 'chained_job/process'

module ChainedJob
  module Middleware
    def self.included(base)
      base.queue_as ChainedJob.config.queue if ChainedJob.config.queue
    end

    def perform(worker_id = nil, tag = nil)
      if worker_id
        ChainedJob::Process.run(self, worker_id, tag)
      else
        ChainedJob::StartChains.run(self.class, arguments_array, parallelism)
      end
    end

    def arguments_array
      options = { job_class: self.class }
      ChainedJob.config.around_array_of_job_arguments.call(options) { array_of_job_arguments }
    end

    def array_of_job_arguments
      raise NoMethodError, 'undefined method array_of_job_arguments'
    end

    def parallelism
      raise NoMethodError, 'undefined method parallelism'
    end
  end
end

