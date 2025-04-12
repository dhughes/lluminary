require 'spec_helper'

RSpec.describe Luminary::Schema do
  let(:schema) { described_class.new }

  describe '#initialize' do
    it 'creates an empty fields hash' do
      expect(schema.fields).to eq({})
    end
  end

  describe '#string' do
    it 'adds a string field to the schema' do
      schema.string(:name)
      expect(schema.fields).to eq({ name: { type: :string } })
    end
  end

  describe '#fields' do
    it 'returns the fields hash' do
      schema.string(:name)
      expect(schema.fields).to eq({ name: { type: :string } })
    end

    it 'returns the same hash instance' do
      schema.string(:name)
      first_call = schema.fields
      second_call = schema.fields
      expect(first_call).to be(second_call)
    end
  end
end 