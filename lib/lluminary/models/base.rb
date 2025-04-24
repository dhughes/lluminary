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
            case field[:type]
            when :hash
              format_hash_description(name, field)
            when :array
              format_array_description(name, field)
            else
              format_simple_field_description(name, field)
            end
          end
          .compact # Remove nil entries from skipped types
          .join("\n\n")
      end

      def format_hash_description(name, field)
        return nil unless field[:fields]

        lines = []
        # Add hash field description
        lines << "# #{name}"
        lines << "Description: #{field[:description]}" if field[:description]
        lines << "Type: object"

        # Add validation info for the hash field itself
        if (validations = describe_validations(field))
          lines << "Validations: #{validations}"
        end

        example_value = generate_hash_example(name, field)
        # Format example on a single line - ensure all hashes are converted to JSON
        example_json = format_json_for_examples(example_value)
        lines << "Example: #{example_json}"

        # Add descriptions for each field in the hash
        field[:fields].each do |subname, subfield|
          if subfield[:type] == :hash
            lines << "\n#{format_hash_description("#{name}.#{subname}", subfield)}"
          else
            lines << "\n#{format_simple_field_description("#{name}.#{subname}", subfield)}"
          end
        end

        lines.join("\n")
      end

      # Helper to ensure consistent JSON formatting for examples
      def format_json_for_examples(value)
        case value
        when Hash
          JSON.generate(value)
        when Array
          JSON.generate(value)
        else
          value.inspect
        end
      end

      def format_simple_field_description(name, field)
        lines = []
        lines << "# #{name}"
        lines << "Description: #{field[:description]}" if field[:description]
        lines << "Type: #{format_type(field)}"

        if (validations = describe_validations(field))
          lines << "Validations: #{validations}"
        end

        example_value = generate_example_value(name.to_s.split(".").last, field)
        lines << "Example: #{example_value.inspect}"

        lines.join("\n")
      end

      def format_array_description(name, field)
        lines = []
        lines << "# #{name}"
        lines << "Description: #{field[:description]}" if field[:description]
        lines << "Type: #{format_type(field)}"

        if (validations = describe_validations(field))
          lines << "Validations: #{validations}"
        end

        example_value = generate_array_example(name, field)
        # Use the same formatting helper as for hashes
        lines << "Example: #{format_json_for_examples(example_value)}"

        # Handle nested array fields
        if field[:element_type]
          if field[:element_type][:type] == :array
            nested_description =
              format_nested_array_descriptions(
                "#{name}[]",
                field[:element_type]
              )
            lines << "\n#{nested_description}" if nested_description
            # Add this block to handle hash elements inside arrays
          elsif field[:element_type][:type] == :hash &&
                field[:element_type][:fields]
            field[:element_type][:fields].each do |subname, subfield|
              lines << "\n# #{name}[].#{subname}"
              if subfield[:description]
                lines << "Description: #{subfield[:description]}"
              end
              lines << "Type: #{format_type(subfield)}"
              example_value = generate_example_value(subname, subfield)
              lines << "Example: #{example_value.inspect}"
            end
          end
        end

        lines.join("\n")
      end

      def format_nested_array_descriptions(prefix, field)
        lines = []
        lines << "# #{prefix}"
        lines << "Description: #{field[:description]}" if field[:description]
        lines << "Type: #{format_type(field)}"
        example_value = generate_array_example("item", field)
        # Use the same formatting helper as for hashes
        lines << "Example: #{format_json_for_examples(example_value)}"

        if field[:element_type][:type] == :array
          nested_description =
            format_nested_array_descriptions(
              "#{prefix}[]",
              field[:element_type]
            )
          lines << "\n#{nested_description}" if nested_description
        else
          # Always add description for the innermost element
          lines << "\n# #{prefix}[]"
          if field[:element_type][:description]
            lines << "Description: #{field[:element_type][:description]}"
          end
          lines << "Type: #{field[:element_type][:type]}"
          lines << "Example: #{generate_example_value("item", field[:element_type]).inspect}"
        end

        lines.join("\n")
      end

      def format_type(field)
        case field[:type]
        when :datetime
          "datetime in ISO8601 format"
        when :array
          if field[:element_type].nil?
            "array"
          elsif field[:element_type][:type] == :array
            "array of arrays"
          elsif field[:element_type][:type] == :datetime
            "array of datetimes in ISO8601 format"
          elsif field[:element_type][:type] == :hash
            "array of objects"
          else
            "array of #{field[:element_type][:type]}s"
          end
        when :hash
          "object"
        else
          field[:type].to_s
        end
      end

      def describe_validations(field)
        return unless field[:validations]&.any?

        field[:validations]
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
              describe_length_validation(options[:length], field[:type])
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

      def describe_length_validation(options, field_type = nil)
        descriptions = []
        units = field_type == :array ? "elements" : "characters"

        if options[:minimum]
          descriptions << "must have at least #{options[:minimum]} #{units}"
        end
        if options[:maximum]
          descriptions << "must have at most #{options[:maximum]} #{units}"
        end
        if options[:is]
          descriptions << "must have exactly #{options[:is]} #{units}"
        end
        if options[:in]
          descriptions << "must have between #{options[:in].min} and #{options[:in].max} #{units}"
        end
        descriptions.join(", ")
      end

      def describe_numericality_validation(options)
        descriptions = []
        descriptions.concat(describe_common_comparisons(options))

        if options[:in]
          descriptions << "must be in: #{options[:in].to_a.join(", ")}"
        end
        descriptions << "must be odd" if options[:odd]
        descriptions << "must be even" if options[:even]
        descriptions.join(", ")
      end

      def describe_comparison_validation(options)
        describe_common_comparisons(options).join(", ")
      end

      def describe_common_comparisons(options)
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
        descriptions
      end

      def format_json_example(fields)
        example =
          fields.each_with_object({}) do |(name, field), hash|
            hash[name] = generate_example_value(name, field)
          end
        JSON.pretty_generate(example)
      end

      def generate_example_value(name, field)
        case field[:type]
        when :string
          if name == "item" # For items in arrays
            "first #{name}"
          else
            "your #{name} here"
          end
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
        when :hash
          generate_hash_example(name, field)
        end
      end

      def generate_array_example(name, field)
        return [] unless field[:element_type]

        case field[:element_type][:type]
        when :string
          ["first #{name.to_s.singularize}", "second #{name.to_s.singularize}"]
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
            [[], []]
          end
        when :hash
          example =
            generate_hash_example(name.to_s.singularize, field[:element_type])
          [example, example]
        end
      end

      def generate_hash_example(name, field)
        return {} unless field[:fields]

        field[:fields].each_with_object({}) do |(subname, subfield), hash|
          hash[subname] = generate_example_value(subname, subfield)
        end
      end
    end
  end
end
