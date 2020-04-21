# frozen_string_literal: true

class ChainedJob::Process
  def self.run(target, worked_id)
    new(target, worked_id).run
  end

  attr_reader :target, :worked_id

  def initialize(target, worked_id)
    @target = target
    @worked_id = worked_id
  end

  def run
    # get arg from redis
    # return if arg is nil
    # else start process:
    # target.process(2)
    # start another job:
    # target.class.perform_later(worked_id)
  end
end
