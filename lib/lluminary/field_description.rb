# frozen_string_literal: true
module Lluminary
  class FieldDescription
    def initialize(name, field)
      @name = name
      @type = field[:type]
      @description = field[:description]
      @validations = field[:validations] || []
    end

    def to_s
      parts = []
      parts << "#{@name} (#{type_description})"
      parts << ": #{@description}" if @description
      if validation_descriptions.any?
        parts << " (#{validation_descriptions.join(", ")})"
      end
      parts.join
    end

    def to_schema_s
      parts = []
      parts << "#{@name} (#{type_description})"
      parts << ": #{@description}" if @description
      if validation_descriptions.any?
        parts << "\nValidation: #{validation_descriptions.join(", ")}"
      end
      parts << "\nExample: #{example_value}"
      parts.join
    end

    private

    def type_description
      case @type
      when :datetime
        "datetime in ISO8601 format"
      else
        @type.to_s
      end
    end

    def validation_descriptions
      @validations
        .map do |_, options|
          case options.keys.first
          when :absence
            "must be absent"
          when :comparison
            comparison_descriptions(options[:comparison])
          when :exclusion
            "must not be one of: #{options[:exclusion][:in].join(", ")}"
          when :format
            "must match format: #{options[:format][:with]}"
          when :inclusion
            "must be one of: #{options[:inclusion][:in].join(", ")}"
          when :length
            length_descriptions(options[:length])
          when :numericality
            numericality_descriptions(options[:numericality])
          when :presence
            "must be present"
          end
        end
        .compact
    end

    def comparison_descriptions(options)
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

    def length_descriptions(options)
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

    def numericality_descriptions(options)
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

    def example_value
      case @type
      when :string
        "\"your #{@name} here\""
      when :integer
        "0"
      when :datetime
        "\"2024-01-01T12:00:00+00:00\""
      when :boolean
        "true"
      when :float
        "0.0"
      end
    end
  end
end
