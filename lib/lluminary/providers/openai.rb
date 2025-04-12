require 'openai'
require 'json'
require_relative '../provider_error'

module Lluminary
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

        content = response.dig('choices', 0, 'message', 'content')
        
        { 
          raw: content,
          parsed: begin
            JSON.parse(content) if content
          rescue JSON::ParserError
            nil
          end
        }
      end
    end
  end
end 