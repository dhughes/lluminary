# frozen_string_literal: true

module Lluminary
  module Models
    module Bedrock
      class AnthropicClaudeInstantV1 < Base
        def name
          "anthropic.claude-instant-v1"
        end

        def compatible_with?(provider_name)
          provider_name == :bedrock
        end
      end
    end
  end
end
