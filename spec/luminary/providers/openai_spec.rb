require 'spec_helper'

RSpec.describe Luminary::Providers::OpenAI do
  let(:api_key) { 'test_key' }
  let(:provider) { described_class.new(api_key: api_key) }
  let(:task) { double('Task') }
  let(:client) { instance_double(OpenAI::Client) }
  let(:prompt) { "Test prompt" }
  let(:response) do
    {
      "choices" => [
        {
          "message" => {
            "content" => '{"summary": "Test response"}'
          }
        }
      ]
    }
  end

  before do
    allow(OpenAI::Client).to receive(:new).with(access_token: api_key).and_return(client)
    allow(client).to receive(:chat).and_return(response)
  end

  describe '#call' do
    it 'calls the OpenAI API with the correct parameters' do
      provider.call(prompt, task)

      expect(client).to have_received(:chat).with(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: prompt }],
          response_format: { type: "json_object" }
        }
      )
    end

    it 'returns both raw and parsed responses' do
      result = provider.call(prompt, task)
      
      expect(result).to be_an(Array)
      expect(result.first).to eq('{"summary": "Test response"}')
      expect(result.last).to eq({ "summary" => "Test response" })
    end
  end
end 