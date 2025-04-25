# frozen_string_literal: true
require "active_model"

module Lluminary
  # Base class for models that use JSON schema validation.
  # Provides ActiveModel integration and schema validation.
  class SchemaModel
    include ActiveModel::Validations

    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = attributes.transform_keys(&:to_s)
    end

    def to_s
      attrs = attributes.dup
      attrs.delete("raw_response")
      "#<#{self.class.name} #{attrs.inspect}>"
    end

    def self.build(fields:, validations:, custom_validations: [])
      Class.new(self) do
        class << self
          attr_accessor :schema_fields, :custom_validation_methods
        end

        self.schema_fields = fields
        self.custom_validation_methods = custom_validations

        # Add accessors for each field
        fields.each_key do |name|
          define_method(name) { @attributes[name.to_s] }
          define_method("#{name}=") { |value| @attributes[name.to_s] = value }
        end

        # Add raw_response field and validation
        define_method(:raw_response) { @attributes["raw_response"] }
        define_method("raw_response=") do |value|
          @attributes["raw_response"] = value
        end

        validate do |record|
          if record.raw_response
            begin
              JSON.parse(record.raw_response)
            rescue JSON::ParserError
              record.errors.add(:raw_response, "must be valid JSON")
            end
          end

          record.attributes.each do |name, value|
            next if name == "raw_response"
            next if value.nil?

            field = self.class.schema_fields[name.to_sym]
            next unless field

            case field[:type]
            when :hash
              validate_hash_field(record, name.to_s.capitalize, value, field)
            when :array
              validate_array_field(
                record,
                name.to_s.capitalize,
                value,
                field[:element_type]
              )
            when :string
              unless value.is_a?(String)
                record.errors.add(name.to_s.capitalize, "must be a String")
              end
            when :integer
              unless value.is_a?(Integer)
                record.errors.add(name.to_s.capitalize, "must be an Integer")
              end
            when :boolean
              unless [true, false].include?(value)
                record.errors.add(name.to_s.capitalize, "must be true or false")
              end
            when :float
              unless value.is_a?(Float)
                record.errors.add(name.to_s.capitalize, "must be a float")
              end
            when :datetime
              unless value.is_a?(DateTime)
                record.errors.add(name.to_s.capitalize, "must be a DateTime")
              end
            end
          end
        end

        # Add ActiveModel validations
        validations.each { |args, options| validates(*args, **options) }

        # Set model name for error messages
        define_singleton_method(:model_name) do
          ActiveModel::Name.new(self, nil, "SchemaModel")
        end

        private

        def validate_hash_field(
          record,
          name,
          value,
          field_definition,
          path = nil
        )
          field_name = path || name

          unless value.is_a?(Hash)
            record.errors.add(field_name, "must be a Hash")
            return
          end

          field_definition[:fields].each do |key, field|
            current_path = path ? "#{path}[#{key}]" : "#{field_name}[#{key}]"
            # Try both string and symbol keys
            field_value = value[key.to_s] || value[key.to_sym]

            next if field_value.nil?

            case field[:type]
            when :hash
              validate_hash_field(record, key, field_value, field, current_path)
            when :array
              validate_array_field(
                record,
                key,
                field_value,
                field[:element_type],
                current_path
              )
            when :string
              unless field_value.is_a?(String)
                record.errors.add(current_path, "must be a String")
              end
            when :integer
              unless field_value.is_a?(Integer)
                record.errors.add(current_path, "must be an Integer")
              end
            when :boolean
              unless [true, false].include?(field_value)
                record.errors.add(current_path, "must be true or false")
              end
            when :float
              unless field_value.is_a?(Float)
                record.errors.add(current_path, "must be a float")
              end
            when :datetime
              unless field_value.is_a?(DateTime)
                record.errors.add(current_path, "must be a DateTime")
              end
            end
          end
        end

        def validate_array_field(record, name, value, element_type, path = nil)
          field_name = path || name

          unless value.is_a?(Array)
            record.errors.add(field_name, "must be an Array")
            return
          end

          return unless element_type # untyped array

          value.each_with_index do |element, index|
            current_path = "#{field_name}[#{index}]"

            case element_type[:type]
            when :hash
              validate_hash_field(
                record,
                name,
                element,
                element_type,
                current_path
              )
            when :array
              validate_array_field(
                record,
                name,
                element,
                element_type[:element_type],
                current_path
              )
            when :string
              unless element.is_a?(String)
                record.errors.add(current_path, "must be a String")
              end
            when :integer
              unless element.is_a?(Integer)
                record.errors.add(current_path, "must be an Integer")
              end
            when :boolean
              unless [true, false].include?(element)
                record.errors.add(current_path, "must be true or false")
              end
            when :float
              unless element.is_a?(Float)
                record.errors.add(current_path, "must be a float")
              end
            when :datetime
              unless element.is_a?(DateTime)
                record.errors.add(current_path, "must be a DateTime")
              end
            end
          end
        end
      end
    end
  end
end
