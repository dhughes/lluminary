# frozen_string_literal: true
require "aws-sdk-bedrockruntime"
require "aws-sdk-bedrock"
require "json"
require_relative "../provider_error"

module Lluminary
  module Providers
    # Provider for AWS Bedrock models.
    # Implements the Base provider interface for AWS Bedrock's API.
    class Bedrock < Base
      NAME = :bedrock
      DEFAULT_MODEL = Models::Bedrock::AnthropicClaudeInstantV1

      attr_reader :client, :config

      def initialize(**config_overrides)
        super
        @config = { model: DEFAULT_MODEL }.merge(config)

        @client =
          Aws::BedrockRuntime::Client.new(
            region: config[:region],
            credentials:
              Aws::Credentials.new(
                config[:access_key_id],
                config[:secret_access_key]
              )
          )
      end

      def call(prompt, _task)
        response =
          client.converse(
            model_id: model.name,
            messages: [{ role: "user", content: [{ text: prompt }] }]
          )

        content = response.dig(:output, :message, :content, 0, :text)

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

      def models
        models_client =
          Aws::Bedrock::Client.new(
            region: config[:region],
            credentials:
              Aws::Credentials.new(
                config[:access_key_id],
                config[:secret_access_key]
              )
          )
        response = models_client.list_foundation_models
        response.foundation_models.map(&:model_id)
      end
    end
  end
end
