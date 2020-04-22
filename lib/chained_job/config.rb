# frozen_string_literal: true

require 'logger'

module ChainedJob
  class Config
    DEFAULT_ARGUMENTS_BATCH_SIZE = 1_000

    attr_accessor(
      :arguments_batch_size,
      :debug,
      :logger,
      :redis,
    )

    def initialize
      self.arguments_batch_size = DEFAULT_ARGUMENTS_BATCH_SIZE

      self.logger = ::Logger.new(STDOUT)

      self.debug = true
    end
  end
end
