require 'ostruct'

module Luminary
  class Result
    attr_reader :raw_response, :output

    def initialize(raw_response:, output:)
      @raw_response = raw_response
      @output = OpenStruct.new(output)
    end
  end
end 