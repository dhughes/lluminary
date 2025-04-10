module Luminary
  class Task
    def self.call
      new.call
    end

    def call
      Result.new(raw_response: "hello world")
    end

    def prompt
      raise NotImplementedError, "Subclasses must implement #prompt"
    end
  end

  class Result
    attr_reader :raw_response

    def initialize(raw_response:)
      @raw_response = raw_response
    end
  end
end 