module Luminary
  module Providers
    class Test < Base
      def initialize(**config)
        super
      end

      def call(prompt, task)
        response = if task.class.output_fields.key?(:quote) && task.class.output_fields.key?(:author)
          {
            quote: "Life is what happens while you're busy making other plans",
            author: "John Lennon"
          }
        else
          {
            summary: "Test response"
          }
        end

        raw_response = JSON.pretty_generate(response).gsub(/\n\s*/, '')
        {
          raw: raw_response,
          parsed: JSON.parse(raw_response)
        }
      end
    end
  end
end 