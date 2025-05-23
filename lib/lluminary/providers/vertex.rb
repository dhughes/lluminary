# frozen_string_literal: true

require "google/cloud/ai_platform"
require "json"
require_relative "../provider_error"

module Lluminary
  module Providers
    class Vertex < Base
      NAME = :vertex
      DEFAULT_MODEL = Models::Vertex::GeminiPro

      attr_reader :client, :config

      def initialize(**config_overrides)
        super
        @config = { model: DEFAULT_MODEL }.merge(config)
        @client = Google::Cloud::AIPlatform.prediction_service
      end

      def call(prompt, _task)
        # Expect the full endpoint resource name in config, e.g.:
        # "projects/PROJECT_ID/locations/LOCATION/endpoints/ENDPOINT_ID"
        endpoint = config[:endpoint]
        raise ProviderError, "Vertex endpoint not configured" unless endpoint

        response =
          @client.predict(endpoint: endpoint, instances: [{ prompt: prompt }])

        content =
          begin
            response.predictions.first["content"]
          rescue StandardError
            nil
          end

        {
          raw: content,
          parsed:
            begin
              JSON.parse(content) if content
            rescue JSON::ParserError
              nil
            end
        }
      rescue Google::Cloud::Error => e
        raise ProviderError, "Vertex API error: #{e.message}"
      end

      def model
        @model ||= config[:model].new
      end

      def models
        # For now, we'll just return the Gemini Pro model
        # In the future, we could fetch this from the API
        ["gemini-pro"]
      end
    end
  end
end
