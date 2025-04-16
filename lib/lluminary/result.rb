# frozen_string_literal: true
require "ostruct"

module Lluminary
  # Represents the result of a task execution.
  # Contains the output data and any metadata about the execution.
  class Result
    attr_reader :raw_response, :output, :prompt

    def initialize(raw_response:, output:, prompt:)
      @raw_response = raw_response
      @output = OpenStruct.new(output)
      @prompt = prompt
    end
  end
end
