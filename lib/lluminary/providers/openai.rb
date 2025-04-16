# frozen_string_literal: true
require "openai"
require "json"
require_relative "../provider_error"

module Lluminary
  module Providers
    # Provider for OpenAI's GPT models.
    # Implements the Base provider interface for OpenAI's API.
    class OpenAI < Base
      DEFAULT_MODEL = Models::OpenAi::Gpt35Turbo

      attr_reader :client, :config

      def initialize(**config)
        super
        @config = { model: DEFAULT_MODEL }.merge(config)
        @client = ::OpenAI::Client.new(access_token: config[:api_key])
      end

      def call(prompt, _task)
        response =
          @client.chat(
            parameters: {
              model: model.name,
              messages: [{ role: "user", content: prompt }],
              response_format: {
                type: "json_object"
              }
            }
          )

        content = response.dig("choices", 0, "message", "content")

        {
          raw: content,
          parsed:
            begin
              JSON.parse(content) if content
            rescue JSON::ParserError
              nil
            end
        }
      end

      def model
        @model ||= config[:model].new
      end
    end
  end
end
