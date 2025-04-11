module Luminary
  class Schema
    def initialize
      @fields = {}
    end

    def string(name)
      @fields[name] = { type: :string }
    end

    def fields
      @fields
    end
  end
end 