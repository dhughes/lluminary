require 'luminary'

RSpec.describe Luminary::Providers::TestProvider do
  let(:provider) { described_class.new }

  describe '#call' do
    it 'returns a test response with the prompt' do
      response = provider.call(prompt: 'test prompt')
      expect(response).to eq('Test response to: test prompt')
    end

    it 'handles different prompts' do
      response = provider.call(prompt: 'another prompt')
      expect(response).to eq('Test response to: another prompt')
    end
  end
end 