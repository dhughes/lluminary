module Luminary
  class InputSchema
    def initialize
      @inputs = {}
    end

    def string(name)
      @inputs[name] = { type: :string }
    end

    def inputs
      @inputs.dup
    end
  end
end 