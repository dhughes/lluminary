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
        element_schema = Schema.new
        element_schema.instance_eval(&block)
        field[:element_type] = element_schema.fields[:element]
      end

      @fields[name] = field
    end

    attr_reader :fields

    def validates(*args, **options)
      @validations << [args, options]
    end

    def validations_for(field_name)
      @validations.select { |args, _| args.include?(field_name) }
    end

    def schema_model
      @schema_model ||=
        SchemaModel.build(fields: @fields, validations: @validations)
    end

    def validate(values)
      instance = schema_model.new(values)
      instance.valid? ? [] : instance.errors.full_messages
    end
  end
end
