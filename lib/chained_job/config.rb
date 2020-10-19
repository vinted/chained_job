# frozen_string_literal: true

require 'logger'

module ChainedJob
  class Config
    DEFAULT_ARGUMENTS_BATCH_SIZE = 1_000
    DEFAULT_ARGUMENTS_QUEUE_EXPIRATION = 7 * 24 * 60 * 60 # 7 days

    attr_accessor(
      :arguments_batch_size,
      :arguments_queue_expiration,
      :around_start_chains,
      :around_chain_process,
      :around_array_of_job_arguments,
      :debug,
      :logger,
      :redis,
      :queue,
    )

    def initialize
      self.arguments_batch_size = DEFAULT_ARGUMENTS_BATCH_SIZE
      self.arguments_queue_expiration = DEFAULT_ARGUMENTS_QUEUE_EXPIRATION

      self.logger = ::Logger.new(STDOUT)

      self.around_start_chains = ->(_options, &block) { block.call }
      self.around_chain_process = ->(_options, &block) { block.call }
      self.around_array_of_job_arguments = ->(_options, &block) { block.call }

      self.debug = true
    end
  end
end
