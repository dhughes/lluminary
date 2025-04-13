require 'spec_helper'

RSpec.describe Lluminary::FieldDescription do
  describe '#to_s' do
    it 'generates a description for a string field' do
      field = {
        type: :string,
        description: 'A test field'
      }
      description = described_class.new('test_field', field)
      expect(description.to_s).to eq('test_field (string): A test field')
    end

    it 'generates a description for a field without a description' do
      field = {
        type: :integer
      }
      description = described_class.new('count', field)
      expect(description.to_s).to eq('count (integer)')
    end

    it 'includes validation descriptions when present' do
      field = {
        type: :string,
        description: 'A test field',
        validations: [
          [{}, { length: { minimum: 5, maximum: 10 } }],
          [{}, { format: { with: '/^[A-Z]+$/' } }]
        ]
      }
      description = described_class.new('test_field', field)
      expected = 'test_field (string): A test field (must be at least 5 characters, must be at most 10 characters, must match format: /^[A-Z]+$/)'
      expect(description.to_s).to eq(expected)
    end
  end
end 