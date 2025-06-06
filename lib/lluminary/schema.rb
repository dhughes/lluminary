# frozen_string_literal: true
require "active_model"
require_relative "schema_model"

module Lluminary
  # Represents a JSON schema for validating task inputs and outputs.
  # Provides methods for defining and validating schemas.
  class Schema
    def initialize
      @fields = {}
      @validations = []
      @custom_validations = []
    end

    def string(name, description: nil)
      @fields[name] = { type: :string, description: description }
    end

    def integer(name, description: nil)
      @fields[name] = { type: :integer, description: description }
    end

    def boolean(name, description: nil)
      @fields[name] = { type: :boolean, description: description }
    end

    def float(name, description: nil)
      @fields[name] = { type: :float, description: description }
    end

    def datetime(name, description: nil)
      @fields[name] = { type: :datetime, description: description }
    end

    def array(name, description: nil, &block)
      field = { type: :array, description: description }

      if block
        element_schema = ElementTypeSchema.new
        field[:element_type] = element_schema.instance_eval(&block)
      end

      @fields[name] = field
    end

    def hash(name, description: nil, &block)
      unless block
        raise ArgumentError, "Hash fields must be defined with a block"
      end

      nested_schema = Schema.new
      nested_schema.instance_eval(&block)

      @fields[name] = {
        type: :hash,
        description: description,
        fields: nested_schema.fields
      }
    end

    def dictionary(name, description: nil, &block)
      unless block
        raise ArgumentError, "Dictionary fields must be defined with a block"
      end

      element_schema = ElementTypeSchema.new
      value_type = element_schema.instance_eval(&block)

      @fields[name] = {
        type: :dictionary,
        description: description,
        value_type: value_type
      }
    end

    attr_reader :fields, :custom_validations

    def validates(*args, **options)
      @validations << [args, options]
      # Attach the validation to each field it applies to
      args.each do |field_name|
        field = @fields[field_name]
        next unless field # Skip if field doesn't exist yet

        field[:validations] ||= []
        # Store each validation option separately
        options.each { |key, value| field[:validations] << { key => value } }
      end
    end

    def validate(method_name, description: nil)
      @custom_validations << { method: method_name, description: description }
    end

    def validations_for(field_name)
      @validations.select { |args, _| args.include?(field_name) }
    end

    def schema_model
      @schema_model ||=
        SchemaModel.build(
          fields: @fields,
          validations: @validations,
          custom_validations: @custom_validations
        )
    end

    # Internal class for defining element types for arrays and dictionaries (or any other container-type objects)
    class ElementTypeSchema
      def string(description: nil)
        { type: :string, description: description }
      end

      def integer(description: nil)
        { type: :integer, description: description }
      end

      def boolean(description: nil)
        { type: :boolean, description: description }
      end

      def float(description: nil)
        { type: :float, description: description }
      end

      def datetime(description: nil)
        { type: :datetime, description: description }
      end

      def array(description: nil, &block)
        field = { type: :array, description: description }
        field[:element_type] = ElementTypeSchema.new.instance_eval(
          &block
        ) if block
        field
      end

      def hash(description: nil, &block)
        unless block
          raise ArgumentError, "Hash fields must be defined with a block"
        end

        nested_schema = Schema.new
        nested_schema.instance_eval(&block)

        { type: :hash, description: description, fields: nested_schema.fields }
      end

      def dictionary(description: nil, &block)
        unless block
          raise ArgumentError, "Dictionary fields must be defined with a block"
        end

        element_schema = ElementTypeSchema.new
        value_type = element_schema.instance_eval(&block)

        { type: :dictionary, description: description, value_type: value_type }
      end
    end
  end
end
