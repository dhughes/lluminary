module Luminary
  class Schema
    def initialize
      @fields = {}
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

    def validate(values)
      errors = []
      values.each do |name, value|
        field = @fields[name]
        next unless field # Skip if field not defined in schema

        case field[:type]
        when :string
          unless value.is_a?(String)
            errors << "#{name} must be a String"
          end
        when :integer
          unless value.is_a?(Integer)
            errors << "#{name} must be an Integer"
          end
        end
      end
      errors
    end
  end
end 