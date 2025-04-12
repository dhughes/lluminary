module Lluminary
  module Providers
    class Test < Base
      def initialize(**config)
        super
      end

      def call(prompt, task)
        response = generate_response(task.class.output_fields)
        raw_response = JSON.pretty_generate(response).gsub(/\n\s*/, '')
        {
          raw: raw_response,
          parsed: JSON.parse(raw_response)
        }
      end

      private

      def generate_response(fields)
        fields.each_with_object({}) do |(name, field), hash|
          hash[name] = generate_value(field[:type])
        end
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