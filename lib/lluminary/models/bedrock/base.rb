# frozen_string_literal: true

module Lluminary
  module Models
    module Bedrock
      # TODO: test me
      class Base < Lluminary::Models::Base
        VERSIONS = [].freeze
        CONTEXT_WINDOWS = [].freeze

        def default_version
          self.class::VERSIONS.last
        end

        def default_context_window
          nil
        end

        def name
          [
            self.class::NAME,
            default_version,
            default_context_window
          ].compact.join(":")
        end
      end
    end
  end
end
