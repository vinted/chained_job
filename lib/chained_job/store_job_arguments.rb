# frozen_string_literal: true

require 'chained_job/helpers'

module ChainedJob
  class StoreJobArguments
    def self.run(job_arguments_key, job_tag, array_of_job_arguments)
      new(job_arguments_key, job_tag, array_of_job_arguments).run
    end

    attr_reader :job_arguments_key, :job_tag, :array_of_job_arguments

    def initialize(job_arguments_key, job_tag, array_of_job_arguments)
      @job_arguments_key = job_arguments_key
      @job_tag = job_tag
      @array_of_job_arguments = array_of_job_arguments
    end

    def run
      set_tag_list

      array_of_job_arguments.each_slice(config.arguments_batch_size) do |sublist|
        ChainedJob.redis.call(:rpush, redis_key, Helpers.serialize(sublist))
      end

      ChainedJob.redis.call(:expire, redis_key, config.arguments_queue_expiration)
    end

    private

    def set_tag_list
      ChainedJob.redis.call(:sadd, tag_list, job_tag)
    end

    def tag_list
      Helpers.tag_list(job_key)
    end

    def redis_key
      @redis_key ||= Helpers.redis_key(job_key, job_tag)
    end

    def job_key
      @job_key ||= Helpers.job_key(job_arguments_key)
    end

    def config
      ChainedJob.config
    end
  end
end
