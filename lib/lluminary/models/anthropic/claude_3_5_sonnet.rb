# frozen_string_literal: true

# require_relative "../base"

module Lluminary
  module Models
    module Anthropic
      class Claude35Sonnet < Lluminary::Models::Base
        NAME = "claude-3-5-sonnet-latest"

        def compatible_with?(provider_name)
          provider_name == :anthropic
        end
      end
    end
  end
end
