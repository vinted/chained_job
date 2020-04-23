# frozen_string_literal: true

require 'chained_job/start_chains'
require 'chained_job/process'

module ChainedJob
  module Middleware
    def perform(worker_id = nil)
      if worker_id
        ChainedJob::Process.run(self, worker_id)
      else
        ChainedJob::StartChains.run(self.class, array_of_job_arguments, parallelism)
      end
    end
  end
end
