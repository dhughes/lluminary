require 'luminary'

RSpec.describe Luminary::Providers::OpenAI do
  let(:config) { { api_key: 'test-key', model: 'gpt-3.5-turbo' } }
  let(:provider) { described_class.new(config) }
  let(:mock_client) { instance_double(::OpenAI::Client) }

  before do
    allow(::OpenAI::Client).to receive(:new).and_return(mock_client)
  end

  describe '#initialize' do
    it 'creates an OpenAI client with the provided API key' do
      expect(::OpenAI::Client).to receive(:new).with(api_key: 'test-key')
      described_class.new(api_key: 'test-key')
    end
  end

  describe '#call' do
    let(:prompt) { 'Test prompt' }
    let(:mock_response) do
      {
        'choices' => [
          {
            'message' => {
              'content' => 'Test response'
            }
          }
        ]
      }
    end

    before do
      allow(mock_client).to receive(:chat).and_return(mock_response)
    end

    it 'calls the OpenAI API with the correct parameters' do
      expect(mock_client).to receive(:chat).with(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages: [{ role: 'user', content: prompt }]
        }
      )
      provider.call(prompt: prompt)
    end

    it 'returns the content from the response' do
      expect(provider.call(prompt: prompt)).to eq('Test response')
    end
  end
end 