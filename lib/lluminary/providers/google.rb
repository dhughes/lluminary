# frozen_string_literal: true

require "openai"
require "json"
require_relative "../provider_error"

# This is a quick and dirty implementation of a provided that works with Google's AI studio.
# It does not currently support vertex. Plans are to eventually create a separate gem similar
# `gemini-ai` that can work with either AI studio or Vertex. For now, this just uses the
# OpenAI compatible endpoint.
module Lluminary
  module Providers
    class Google < Base
      NAME = :google
      DEFAULT_MODEL = Models::Google::Gemini20Flash

      attr_reader :client, :config

      def initialize(**config_overrides)
        super
        @config = { model: DEFAULT_MODEL }.merge(config)
        @client =
          ::OpenAI::Client.new(
            access_token: config[:api_key],
            api_version: "",
            uri_base: "https://generativelanguage.googleapis.com/v1beta/openai"
          )
      end

      def call(prompt, _task)
        response =
          client.chat(
            parameters: {
              model: model.class::NAME,
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

      def models
        response = @client.models.list
        response["data"].map { |model| model["id"].split("/").last }
      end
    end
  end
end
