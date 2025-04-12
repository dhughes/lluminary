require 'spec_helper'

RSpec.describe Luminary::Providers::OpenAI do
  let(:config) { { api_key: 'test-key' } }
  let(:provider) { described_class.new(**config) }

  describe '#client' do
    it 'returns the OpenAI client instance' do
      expect(provider.client).to be_a(OpenAI::Client)
    end
  end

  describe '#call' do
    let(:prompt) { 'Test prompt' }
    let(:task) { 'Test task' }
    let(:mock_response) do
      {
        'choices' => [
          {
            'message' => {
              'content' => '{"summary": "Test response"}'
            }
          }
        ]
      }
    end

    before do
      allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return(mock_response)
    end

    it 'returns a hash with raw and parsed response' do
      response = provider.call(prompt, task)
      expect(response).to eq({
        raw: '{"summary": "Test response"}',
        parsed: { 'summary' => 'Test response' }
      })
    end
  end
end 