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
      expect(schema.fields).to eq({ name: { type: :string, description: nil } })
    end

    it 'adds a string field with description' do
      schema.string(:name, description: "The user's full name")
      expect(schema.fields).to eq({ 
        name: { 
          type: :string,
          description: "The user's full name"
        } 
      })
    end
  end

  describe '#integer' do
    it 'adds an integer field to the schema' do
      schema.integer(:count)
      expect(schema.fields).to eq({ count: { type: :integer, description: nil } })
    end

    it 'adds an integer field with description' do
      schema.integer(:count, description: "The total number of items")
      expect(schema.fields).to eq({ 
        count: { 
          type: :integer,
          description: "The total number of items"
        } 
      })
    end
  end

  describe '#fields' do
    it 'returns the fields hash' do
      schema.string(:name)
      expect(schema.fields).to eq({ name: { type: :string, description: nil } })
    end

    it 'returns the same hash instance' do
      schema.string(:name)
      first_call = schema.fields
      second_call = schema.fields
      expect(first_call).to be(second_call)
    end
  end

  describe '#validate' do
    let(:schema) do
      described_class.new.tap do |s|
        s.string(:name)
        s.integer(:age)
      end
    end

    it 'returns no errors when all values match their field types' do
      errors = schema.validate(name: "John", age: 30)
      expect(errors).to be_empty
    end

    it 'returns errors for type mismatches' do
      errors = schema.validate(name: 123, age: "30")
      expect(errors).to contain_exactly(
        "name must be a String",
        "age must be an Integer"
      )
    end
  end
end 