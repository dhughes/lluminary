require 'spec_helper'
require_relative '../../examples/quote_task'

RSpec.describe QuoteTask do
  describe '.call' do
    it 'returns a quote and its author' do
      result = described_class.call

      expect(result.output.quote).to be_a(String)
      expect(result.output.quote).not_to be_empty
      
      expect(result.output.author).to be_a(String)
      expect(result.output.author).not_to be_empty
    end

    it 'can be called without any input parameters' do
      expect { described_class.call }.not_to raise_error
    end

    it 'returns a valid result object' do
      result = described_class.call
      expect(result).to be_a(Luminary::Task)
      expect(result.input).to be_a(Luminary::SchemaModel)
      expect(result.input.valid?).to be true
    end
  end
end 