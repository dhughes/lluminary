require 'luminary'

RSpec.describe Luminary do
  describe '.hello' do
    it 'returns a welcome message' do
      expect(Luminary.hello).to eq('Welcome to Luminary - your LLM framework!')
    end
  end
end 