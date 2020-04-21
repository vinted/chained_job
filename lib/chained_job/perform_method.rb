# frozen_string_literal: true

require 'chained_job/start_chains'
require 'chained_job/process'

class ChainedJob::PerformMethod
  def self.run(target_class)
    new(target_class).run
  end

  attr_reader :target_class

  def initialize(target_class)
    @target_class = target_class
  end

  def run
    target_class.class_eval do
      def perform(worked_id = nil)
        if worked_id
          ChainedJob::Process.run(self, worked_id)
        else
          ChainedJob::StartChains.run(target_class, array_of_job_arguments, parallelism)
        end
      end
    end
  end
end
