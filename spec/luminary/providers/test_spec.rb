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

    it 'handles prompts with schema descriptions' do
      prompt_with_schema = <<~PROMPT
        Test prompt

        You must respond with a valid JSON object with the following fields:

        summary (string): A brief summary of the message
        Example: "your summary here"

        Your response should look like this:
        {
          "summary": "your summary here"
        }
      PROMPT

      response = provider.call(prompt_with_schema, task)
      expect(response[:raw]).to eq('{"summary": "Test response"}')
      expect(response[:parsed]).to eq({ "summary" => "Test response" })
    end
  end
end 