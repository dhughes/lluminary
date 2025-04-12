require 'aws-sdk-bedrockruntime'
require 'json'

require 'pry-byebug'

module Lluminary
  module Providers
    class Bedrock < Base
      attr_reader :client

      def initialize(**config)
        super
        
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
          model_id: 'anthropic.claude-instant-v1',
          messages: [
            {
              role: 'user',
              content: [{text: prompt}]
            }
          ]
        )

        content = response.dig(:output, :message, :content).first.text
        
        begin
          { 
            raw: content, 
            parsed: JSON.parse(content) 
          }
        rescue JSON::ParserError => e
          raise ProviderError, "Failed to parse JSON response: #{e.message}"
        end
      end
    end
  end
end 