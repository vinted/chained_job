# frozen_string_literal: true

require 'chained_job/start_chains'
require 'chained_job/process'

module ChainedJob
  module Middleware
    def self.included(target_class)
      target_class.include ClassMethods
    end

    module ClassMethods
      module_function

      def perform(worked_id = nil)
        if worked_id
          ChainedJob::Process.run(self, worked_id)
        else
          ChainedJob::StartChains.run(self.class, array_of_job_arguments, parallelism)
        end
      end
    end
  end
end
