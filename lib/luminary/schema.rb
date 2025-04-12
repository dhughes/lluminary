require 'active_model'
require_relative 'schema_model'

module Luminary
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

    def fields
      @fields
    end

    def validates(*args, **options)
      @validations << [args, options]
    end

    def schema_model
      @schema_model ||= SchemaModel.build(
        fields: @fields,
        validations: @validations
      )
    end

    def validate(values)
      instance = schema_model.new(values)
      instance.valid? ? [] : instance.errors.full_messages
    end
  end
end 