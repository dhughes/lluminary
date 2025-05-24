# frozen_string_literal: true

# TODO: the gemini-ai gem appears to be abandoned. I may need to borrow from it to get the full range of support
# But also, apparently google has an openai compatible endpoint. See: https://ai.google.dev/gemini-api/docs/openai
#
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
              # TODO: generate `response_schema` from the task's output schema
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
        # The models endpoint returns a fair amount of info about the available models
        # However, the list doesn't seem complete. It's not paginating. This is an issue with
        # the gemini-ai gem. I'm considering forking the gem, but it seems pretty dead at 10 months
        # without any activity.
        client.models["models"].map { |model| model["name"] }
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
