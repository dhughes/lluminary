require 'openai'

module Luminary
  module Providers
    class OpenAI < Base
      def initialize(config = {})
        super
        @client = ::OpenAI::Client.new(api_key: config[:api_key])
      end

      def call(prompt:)
        response = @client.chat(
          parameters: {
            model: config[:model] || "gpt-3.5-turbo",
            messages: [{ role: "user", content: prompt }]
          }
        )
        
        response.dig("choices", 0, "message", "content")
      end
    end
  end
end 