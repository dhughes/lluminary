require 'aws-sdk-bedrockruntime'
require 'json'
require_relative '../provider_error'

require 'pry-byebug'

module Lluminary
  module Providers
    class Bedrock < Base
      DEFAULT_MODEL_ID = 'anthropic.claude-instant-v1'

      attr_reader :client, :config

      def initialize(**config)
        super
        @config = config

        @client = Aws::BedrockRuntime::Client.new(
          region: config[:region],
          credentials: Aws::Credentials.new(
            config[:access_key_id],
            config[:secret_access_key]
          )
        )
      end

      def call(prompt, task)
        response = @client.converse(
          model_id: config[:model_id] || DEFAULT_MODEL_ID,
          messages: [
            {
              role: 'user',
              content: [{text: prompt}]
            }
          ]
        )

        content = response.dig(:output, :message, :content, 0, :text)
        
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