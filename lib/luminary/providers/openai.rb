require 'openai'
require 'json'

module Luminary
  module Providers
    class OpenAI < Base
      attr_reader :client

      def initialize(**config)
        super
        @client = ::OpenAI::Client.new(access_token: config[:api_key])
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
          { 
            raw: content, 
            parsed: JSON.parse(content) 
          }
        rescue JSON::ParserError => e
          raise ProviderError, "Failed to parse JSON response: #{e.message}"
        end
      end
    end
  end
end 