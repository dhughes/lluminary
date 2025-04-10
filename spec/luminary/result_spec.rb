require 'luminary'

RSpec.describe Luminary::Result do
  describe '#raw_response' do
    it 'returns the raw response' do
      result = described_class.new(raw_response: "test response")
      expect(result.raw_response).to eq("test response")
    end
  end
end 