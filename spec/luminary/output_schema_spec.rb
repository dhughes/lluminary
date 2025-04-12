require 'luminary'
require 'spec_helper'

RSpec.describe Luminary::OutputSchema do
  let(:schema) { described_class.new }

  describe '#string' do
    it 'adds a string output to the schema' do
      schema.string(:name)
      expect(schema.outputs).to eq({ name: { type: :string } })
    end

    it 'allows defining multiple string outputs' do
      schema.string(:summary1)
      schema.string(:summary2)
      expect(schema.outputs.keys).to contain_exactly(:summary1, :summary2)
    end
  end

  describe '#outputs' do
    it 'returns a copy of the outputs hash' do
      schema.string(:name)
      original = schema.outputs
      schema.string(:age)
      
      expect(original).to eq({ name: { type: :string } })
      expect(schema.outputs).to eq({ 
        name: { type: :string },
        age: { type: :string }
      })
    end
  end
end 