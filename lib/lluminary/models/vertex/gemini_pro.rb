# frozen_string_literal: true

module Lluminary
  module Models
    module Vertex
      class GeminiPro < Lluminary::Models::Base
        NAME = "gemini-pro"

        def compatible_with?(provider_name)
          provider_name == :vertex
        end

        def name
          NAME
        end
      end
    end
  end
end
