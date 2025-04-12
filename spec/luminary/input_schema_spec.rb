require 'luminary'
require 'spec_helper'

RSpec.describe Luminary::InputSchema do
  let(:schema) { described_class.new }

  describe '#string' do
    it 'adds a string input to the schema' do
      schema.string(:name)
      expect(schema.inputs).to eq({ name: { type: :string } })
    end

    it 'allows defining multiple string inputs' do
      schema.string(:text1)
      schema.string(:text2)
      expect(schema.inputs.keys).to contain_exactly(:text1, :text2)
    end
  end

  describe '#inputs' do
    it 'returns a copy of the inputs hash' do
      schema.string(:name)
      original = schema.inputs
      schema.string(:age)
      
      expect(original).to eq({ name: { type: :string } })
      expect(schema.inputs).to eq({ 
        name: { type: :string },
        age: { type: :string }
      })
    end
  end
end 