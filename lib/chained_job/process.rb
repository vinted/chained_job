# frozen_string_literal: true

module ChainedJob
  class Process
    def self.run(object, worker_id)
      new(object, worker_id).run
    end

    attr_reader :object, :worker_id

    def initialize(object, worker_id)
      @object = object
      @worker_id = worker_id
    end

    def run
      return unless argument

      object.process(argument)
      object.class.perform_later(worker_id)
    end

    private

    def argument
      @argument ||= ChainedJob.redis.lpop(redis_key)
    end

    def redis_key
      "chained_job:#{object.class}"
    end
  end
end
