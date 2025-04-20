# frozen_string_literal: true

require_relative "base"

module Lluminary
  module Models
    module Bedrock
      class AmazonNovaProV1 < Lluminary::Models::Bedrock::Base
        NAME = "amazon.nova-pro-v1"
        VERSIONS = %w[0].freeze
        CONTEXT_WINDOWS = %w[24k 300k].freeze

        def compatible_with?(provider_name)
          provider_name == :bedrock
        end
      end
    end
  end
end
