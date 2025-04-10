module Luminary
  class Result
    attr_reader :raw_response

    def initialize(raw_response:)
      @raw_response = raw_response
    end
  end
end 