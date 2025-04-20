# frozen_string_literal: true

module Lluminary
  module Models
    module Bedrock
      class AmazonNovaProV1 < Base
        NAME = "amazon.nova-pro-v1:0"

        def compatible_with?(provider_name)
          provider_name == :bedrock
        end
      end
    end
  end
end
