# frozen_string_literal: true

module Lluminary
  module Providers
    # Base class for all LLM providers.
    # Defines the interface that all providers must implement.
    class Base
      # The symbolic name of the provider. Must be overridden by subclasses.
      NAME = :base

      attr_reader :config

      def initialize(**config_overrides)
        @config = default_provider_config.merge(config_overrides)
      end

      def call(prompt, task)
        raise NotImplementedError, "Subclasses must implement #call"
      end

      private

      def default_provider_config
        Lluminary.config.provider_config(self.class::NAME)
      end
    end
  end
end
