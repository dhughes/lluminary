require 'spec_helper'
require 'luminary/providers/test'

RSpec.describe Luminary::Providers::Test do
  let(:provider) { described_class.new }
  let(:prompt) { "Test prompt" }
  let(:task) { double("Task") }

  describe '#call' do
    it 'returns a hash with raw and parsed response' do
      response = provider.call(prompt, task)

      expect(response).to be_a(Hash)
      expect(response[:raw]).to eq('{"summary": "Test response"}')
      expect(response[:parsed]).to eq({ "summary" => "Test response" })
    end
  end
end 