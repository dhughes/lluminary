module Luminary
  module Providers
    class Test < Base
      def initialize(**config)
        super
      end

      def call(prompt, task)
        content = '{"summary": "Test response"}'
        { 
          raw: content, 
          parsed: JSON.parse(content) 
        }
      end
    end
  end
end 