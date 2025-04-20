# frozen_string_literal: true

module Lluminary
  module Models
    # Base class for all LLM models.
    # Defines the interface that all model classes must implement.
    class Base
      # Checks if this model is compatible with a given provider
      # @param provider_name [Symbol] The name of the provider to check
      # @return [Boolean]
      def compatible_with?(provider_name)
        raise NotImplementedError, "Subclasses must implement #compatible_with?"
      end

      # Returns the name of the model
      # @return [String]
      def name
        raise NotImplementedError, "Subclasses must implement #name"
      end
    end
  end
end
