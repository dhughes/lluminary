# frozen_string_literal: true
require "ostruct"

module Lluminary
  class Result
    attr_reader :raw_response, :output, :prompt

    def initialize(raw_response:, output:, prompt:)
      @raw_response = raw_response
      @output = OpenStruct.new(output)
      @prompt = prompt
    end
  end
end
