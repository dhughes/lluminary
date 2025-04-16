# frozen_string_literal: true

module Lluminary
  module Models
    module OpenAi
      # Model class for OpenAI's GPT-3.5 Turbo
      class Gpt35Turbo < Base
        def name
          "gpt-3.5-turbo"
        end

        def compatible_with?(provider_name)
          provider_name == :openai
        end
      end
    end
  end
end
