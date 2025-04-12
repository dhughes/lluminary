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
  end
end 