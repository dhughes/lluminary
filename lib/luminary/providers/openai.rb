require 'openai'
require 'json'

module Luminary
  module Providers
    class OpenAI < Base
      def initialize(api_key:, **options)
        @client = ::OpenAI::Client.new(access_token: api_key)
        @options = options
      end

      def call(prompt, task)
        response = @client.chat(
          parameters: {
            model: "gpt-3.5-turbo",
            messages: [{ role: "user", content: prompt }],
            response_format: { type: "json_object" }
          }
        )

        content = response.dig("choices", 0, "message", "content")
        
        begin
          parsed = JSON.parse(content)
          [content, parsed]
        rescue JSON::ParserError => e
          raise ProviderError, "Failed to parse JSON response: #{e.message}"
        end
      end
    end
  end
end 