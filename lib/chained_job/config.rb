# frozen_string_literal: true

module ChainedJob
  class Config
    DEFAULT_ARGUMENTS_BATCH_SIZE = 1_000

    attr_accessor(
      :arguments_batch_size,
      :debug,
    )

    def initialize
      self.arguments_batch_size = DEFAULT_ARGUMENTS_BATCH_SIZE

      self.debug = true
    end
  end
end
