# frozen_string_literal: true

class ChainedJob::StartChains
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
    # store array_of_job_arguments to redis
    # start jobs:
    # parallelism.times { |worked_id| target_class.perform_later(worked_id) }
  end
end
