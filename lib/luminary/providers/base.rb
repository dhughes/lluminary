module Luminary
  module Providers
    class Base
      def initialize(config = {})
        @config = config
      end

      def call(prompt:)
        raise NotImplementedError, "Subclasses must implement #call"
      end

      private

      attr_reader :config
    end
  end
end 