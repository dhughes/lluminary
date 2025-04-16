# frozen_string_literal: true

module Lluminary
  module Providers
    # Base class for all LLM providers.
    # Defines the interface that all providers must implement.
    class Base
      attr_reader :config

      def initialize(**config)
        @config = config
      end

      def call(prompt, task)
        raise NotImplementedError, "Subclasses must implement #call"
      end
    end
  end
end
