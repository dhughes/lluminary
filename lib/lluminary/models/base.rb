# frozen_string_literal: true

module Lluminary
  module Models
    # Base class for all LLM models.
    # Defines the interface that all model classes must implement and provides
    # default prompt formatting behavior.
    class Base
      # Checks if this model is compatible with a given provider
      # @param provider_name [Symbol] The name of the provider to check
      # @return [Boolean]
      def compatible_with?(provider_name)
        raise NotImplementedError, "Subclasses must implement #compatible_with?"
      end

      # Returns the name of the model
      # @return [String]
      def name
        raise NotImplementedError, "Subclasses must implement #name"
      end

      def format_prompt(task)
        <<~PROMPT
          #{task.task_prompt.chomp}

          #{output_preamble}
          
          #{format_field_descriptions(task.class.output_fields)}
          
          #{json_preamble}
          
          #{format_json_example(task.class.output_fields)}
        PROMPT
      end

      private

      def output_preamble
        <<~PREAMBLE.chomp
          You must respond with ONLY a valid JSON object. Do not include any other text, explanations, or formatting.
          The JSON object must contain the following fields:
        PREAMBLE
      end

      def json_preamble
        "Your response must be ONLY this JSON object:"
      end

      def format_field_descriptions(fields)
        fields
          .map do |name, field|
            desc = <<~DESC.chomp
            # #{name} 
            Type: #{format_type(field)}
            Description: #{field[:description].chomp}
          DESC

            if (validations = describe_validations(field[:validations]))
              desc += "\nValidations: #{validations}"
            end

            desc += "\nExample: #{generate_example_value(name, field)}"
            desc
          end
          .join("\n\n")
      end

      def describe_validations(validations)
        return unless validations&.any?

        validations
          .map do |options|
            case options.keys.first
            when :presence
              "must be present"
            when :inclusion
              "must be one of: #{options[:inclusion][:in].join(", ")}"
            when :exclusion
              "must not be one of: #{options[:exclusion][:in].join(", ")}"
            when :format
              "must match format: #{options[:format][:with]}"
            when :length
              describe_length_validation(options[:length])
            when :numericality
              describe_numericality_validation(options[:numericality])
            when :comparison
              describe_comparison_validation(options[:comparison])
            when :absence
              "must be absent"
            end
          end
          .compact
          .join(", ")
      end

      def describe_length_validation(options)
        descriptions = []
        if options[:minimum]
          descriptions << "must be at least #{options[:minimum]} characters"
        end
        if options[:maximum]
          descriptions << "must be at most #{options[:maximum]} characters"
        end
        if options[:is]
          descriptions << "must be exactly #{options[:is]} characters"
        end
        if options[:in]
          descriptions << "must be between #{options[:in].min} and #{options[:in].max} characters"
        end
        descriptions.join(", ")
      end

      def describe_numericality_validation(options)
        descriptions = []
        if options[:greater_than]
          descriptions << "must be greater than #{options[:greater_than]}"
        end
        if options[:greater_than_or_equal_to]
          descriptions << "must be greater than or equal to #{options[:greater_than_or_equal_to]}"
        end
        if options[:equal_to]
          descriptions << "must be equal to #{options[:equal_to]}"
        end
        if options[:less_than]
          descriptions << "must be less than #{options[:less_than]}"
        end
        if options[:less_than_or_equal_to]
          descriptions << "must be less than or equal to #{options[:less_than_or_equal_to]}"
        end
        if options[:other_than]
          descriptions << "must be other than #{options[:other_than]}"
        end
        if options[:in]
          descriptions << "must be in: #{options[:in].to_a.join(", ")}"
        end
        descriptions << "must be odd" if options[:odd]
        descriptions << "must be even" if options[:even]
        descriptions.join(", ")
      end

      def describe_comparison_validation(options)
        descriptions = []
        if options[:greater_than]
          descriptions << "must be greater than #{options[:greater_than]}"
        end
        if options[:greater_than_or_equal_to]
          descriptions << "must be greater than or equal to #{options[:greater_than_or_equal_to]}"
        end
        if options[:equal_to]
          descriptions << "must be equal to #{options[:equal_to]}"
        end
        if options[:less_than]
          descriptions << "must be less than #{options[:less_than]}"
        end
        if options[:less_than_or_equal_to]
          descriptions << "must be less than or equal to #{options[:less_than_or_equal_to]}"
        end
        if options[:other_than]
          descriptions << "must be other than #{options[:other_than]}"
        end
        descriptions.join(", ")
      end

      def format_json_example(fields)
        example =
          fields.each_with_object({}) do |(name, field), hash|
            hash[name] = generate_example_value(name, field)
          end
        JSON.pretty_generate(example)
      end

      def format_type(field)
        type = field[:type]
        case type
        when :datetime
          "datetime in ISO8601 format"
        when :array
          if field[:element_type]
            "array of #{format_type(field[:element_type])}"
          else
            "array"
          end
        else
          type.to_s
        end
      end

      def generate_example_value(name, field)
        case field[:type]
        when :string
          "your #{name} here"
        when :integer
          0
        when :datetime
          "2024-01-01T12:00:00+00:00"
        when :boolean
          true
        when :float
          0.0
        when :array
          generate_array_example(name, field)
        end
      end

      def generate_array_example(name, field)
        return [] unless field[:element_type]

        case field[:element_type][:type]
        when :string
          [
            "first #{name.to_s.singularize}",
            "second #{name.to_s.singularize}",
            "..."
          ]
        when :integer
          [1, 2, 3]
        when :float
          [1.0, 2.0, 3.0]
        when :boolean
          [true, false, true]
        when :datetime
          %w[2024-01-01T12:00:00+00:00 2024-01-02T12:00:00+00:00]
        when :array
          if field[:element_type][:element_type]
            inner_example = generate_array_example("item", field[:element_type])
            [inner_example, inner_example]
          else
            [["..."], ["..."]]
          end
        end
      end
    end
  end
end
