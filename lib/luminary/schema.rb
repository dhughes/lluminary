module Luminary
  class Schema
    def initialize
      @fields = {}
    end

    def string(name)
      @fields[name] = { type: :string }
    end

    def integer(name)
      @fields[name] = { type: :integer }
    end

    def fields
      @fields
    end
  end
end 