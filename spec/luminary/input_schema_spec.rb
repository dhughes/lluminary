require 'luminary'

RSpec.describe Luminary::InputSchema do
  let(:schema) { described_class.new }

  describe '#string' do
    it 'defines a string input that can be accessed' do
      schema.string(:text)
      expect(schema.inputs[:text]).to eq({ type: :string })
    end

    it 'allows defining multiple string inputs' do
      schema.string(:text1)
      schema.string(:text2)
      expect(schema.inputs.keys).to contain_exactly(:text1, :text2)
    end
  end

  describe '#inputs' do
    it 'returns a copy of the inputs hash' do
      schema.string(:text)
      inputs = schema.inputs
      inputs[:text] = :modified
      expect(schema.inputs[:text]).to eq({ type: :string })
    end
  end
end 