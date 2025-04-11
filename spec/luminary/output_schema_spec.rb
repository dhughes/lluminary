require 'luminary'

RSpec.describe Luminary::OutputSchema do
  let(:schema) { described_class.new }

  describe '#string' do
    it 'defines a string output that can be accessed' do
      schema.string(:summary)
      expect(schema.outputs[:summary]).to eq({ type: :string })
    end

    it 'allows defining multiple string outputs' do
      schema.string(:summary1)
      schema.string(:summary2)
      expect(schema.outputs.keys).to contain_exactly(:summary1, :summary2)
    end
  end

  describe '#outputs' do
    it 'returns a copy of the outputs hash' do
      schema.string(:summary)
      outputs = schema.outputs
      outputs[:summary] = :modified
      expect(schema.outputs[:summary]).to eq({ type: :string })
    end
  end
end 