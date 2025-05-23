# frozen_string_literal: true

require "gemini-ai"
require "json"
require_relative "../provider_error"
require "pry-byebug"

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
          Gemini.new(
            credentials: credentials,
            options: {
              model: model.class::NAME,
              server_sent_events: true
            }
          )
      end

      def call(prompt, _task)
        result =
          @client.stream_generate_content(
            {
              contents: {
                role: "user",
                parts: {
                  text: prompt
                }
              },
              generation_config: {
                response_mime_type: "application/json"
              }
            }
          )

        content =
          result
            .map do |response|
              response.dig("candidates", 0, "content", "parts")
            end
            .map { |parts| parts.map { |part| part["text"] }.join }
            .join

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
        # For now, we'll just return the Gemini Pro model
        # In the future, we could fetch this from the API
        ["gemini-pro"]
      end

      private

      def credentials
        if api?
          { service: service, api_key: config[:api_key], version: "v1beta" }
        else
          {
            service: service,
            credentials: gcp_credentials,
            region: config[:region],
            version: "v1beta"
          }
        end
      end

      def gcp_credentials
        if File.exist?(config[:credentials])
          File.read(config[:credentials])
        else
          config[:credentials]
        end
      end

      def service
        api? ? "generative-language-api" : "vertex-ai-api"
      end

      def api?
        !config[:api_key].nil?
      end
    end
  end
end
