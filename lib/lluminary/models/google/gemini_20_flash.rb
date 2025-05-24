# frozen_string_literal: true

module Lluminary
  module Models
    module Google
      class Gemini20Flash < Lluminary::Models::Base
        NAME = "gemini-2.0-flash"

        def compatible_with?(provider_name)
          provider_name == :google
        end

        def name
          NAME
        end
      end
    end
  end
end
