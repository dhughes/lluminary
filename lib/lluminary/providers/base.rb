module Lluminary
  module Providers
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