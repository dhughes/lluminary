# frozen_string_literal: true

require "anthropic"
require "json"
require_relative "../provider_error"

module Lluminary
  module Providers
    # Provider for Anthropic's models.
    # Implements the Base provider interface for Anthropic's API.
    class Anthropic < Base
      NAME = :anthropic
      DEFAULT_MODEL = Models::Anthropic::Claude35Sonnet

      attr_reader :client, :config

      def initialize(**config_overrides)
        super
        @config = { model: DEFAULT_MODEL }.merge(config)
        @client = ::Anthropic::Client.new(api_key: config[:api_key])
      end

      def call(prompt, _task)
        message =
          client.messages.create(
            max_tokens: 1024, # TODO: make this configurable
            messages: [{ role: "user", content: prompt }],
            model: model.class::NAME
          )

        content = message.content.first.text

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
        response = @client.models.list
        response.data.map { |model| model.id }
      end
    end
  end
end
