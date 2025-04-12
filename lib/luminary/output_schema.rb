module Luminary
  class OutputSchema
    attr_reader :outputs

    def initialize
      @outputs = {}
    end

    def string(name)
      @outputs[name] = { type: :string }
    end

    def outputs
      @outputs.dup
    end
  end
end 