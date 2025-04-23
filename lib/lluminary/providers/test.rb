# frozen_string_literal: true

module Lluminary
  module Providers
    # Test provider for development and testing.
    # Returns predefined responses for testing purposes.
    class Test < Base
      NAME = :test

      def call(_prompt, task)
        response = generate_response(task.class.output_fields)
        raw_response = JSON.pretty_generate(response).gsub(/\n\s*/, "")
        { raw: raw_response, parsed: JSON.parse(raw_response) }
      end

      def model
        @model ||= Lluminary::Models::Base.new
      end

      private

      def generate_response(fields)
        fields.transform_values { |field| generate_value(field[:type]) }
      end

      def generate_value(type)
        case type
        when :string
          "Test #{type} value"
        when :integer
          0
        else
          raise "Unsupported type: #{type}"
        end
      end
    end
  end
end
