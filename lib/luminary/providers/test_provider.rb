module Luminary
  module Providers
    class TestProvider < Base
      def call(prompt:)
        "Test response to: #{prompt}"
      end
    end
  end
end 