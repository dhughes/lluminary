module Luminary
  module Providers
    class Test < Base
      def initialize(**options)
        @options = options
      end

      def call(prompt, task)
        content = '{"summary": "Test response"}'
        [content, JSON.parse(content)]
      end
    end
  end
end 