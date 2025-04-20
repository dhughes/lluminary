# frozen_string_literal: true

module Lluminary
  module Models
    module OpenAi
      # Model class for OpenAI's GPT-3.5 Turbo
      class Gpt35Turbo < Base
        NAME = "gpt-3.5-turbo"

        def compatible_with?(provider_name)
          provider_name == :openai
        end

        def name
          NAME
        end
      end
    end
  end
end
