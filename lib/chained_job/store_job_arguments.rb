# frozen_string_literal: true

require 'chained_job/helpers'

module ChainedJob
  class StoreJobArguments
    def self.run(job_class, job_tag, array_of_job_arguments)
      new(job_class, job_tag, array_of_job_arguments).run
    end

    attr_reader :job_class, :job_tag, :array_of_job_arguments

    def initialize(job_class, job_tag, array_of_job_arguments)
      @job_class = job_class
      @job_tag = job_tag
      @array_of_job_arguments = array_of_job_arguments
    end

    def run
      update_tag_list

      array_of_job_arguments.each_slice(config.arguments_batch_size) do |sublist|
        redis.rpush(redis_key(job_tag), sublist)
      end

      redis.expire(redis_key(job_tag), config.arguments_queue_expiration)
    end

    private

    def update_tag_list
      redis.sadd(tag_list, job_tag)
    end

    def tag_list
      Helpers.tag_list(job_key)
    end

    def redis_key(job_tag)
      @redis_key ||= Helpers.redis_key(job_key, job_tag)
    end

    def job_key
      @job_key ||= Helpers.job_key(job_class)
    end

    def redis
      ChainedJob.redis
    end

    def config
      ChainedJob.config
    end
  end
end
