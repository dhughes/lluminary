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

    def self.build(fields:, validations:)
      Class.new(self) do
        # Add accessors for each field
        fields.each_key do |name|
          define_method(name) { @attributes[name.to_s] }
          define_method("#{name}=") { |value| @attributes[name.to_s] = value }
        end

        # Add raw_response field and validation
        define_method(:raw_response) { @attributes["raw_response"] }
        define_method(:raw_response=) do |value|
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
        end

        # Add type validations
        validate do |record|
          record.attributes.each do |name, value|
            next if name == "raw_response"
            next if value.nil?

            field = fields[name.to_sym]
            next unless field

            case field[:type]
            when :string
              unless value.is_a?(String)
                record.errors.add(name, "must be a String")
              end
            when :integer
              unless value.is_a?(Integer)
                record.errors.add(name, "must be an Integer")
              end
            when :boolean
              unless [true, false].include?(value)
                record.errors.add(name, "must be true or false")
              end
            when :float
              unless value.is_a?(Float)
                record.errors.add(name, "must be a float")
              end
            when :datetime
              unless value.is_a?(DateTime)
                record.errors.add(name, "must be a DateTime")
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
      end
    end
  end
end
