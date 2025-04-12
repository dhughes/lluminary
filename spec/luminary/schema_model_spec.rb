require 'spec_helper'

RSpec.describe Luminary::SchemaModel do
  describe '.build' do
    let(:fields) do
      {
        name: { type: :string, description: "The user's name" },
        age: { type: :integer, description: "The user's age" }
      }
    end

    let(:validations) do
      [
        [[:name], { presence: true }],
        [[:age], { numericality: { greater_than: 0 } }]
      ]
    end

    let(:model_class) { described_class.build(fields: fields, validations: validations) }

    it 'creates a class with ActiveModel::Validations' do
      expect(model_class.ancestors).to include(ActiveModel::Validations)
    end

    it 'adds accessors for fields' do
      instance = model_class.new(name: "John", age: 30)
      expect(instance.name).to eq("John")
      expect(instance.age).to eq(30)
    end

    it 'validates presence' do
      instance = model_class.new(age: 30)
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include("Name can't be blank")
    end

    it 'validates numericality' do
      instance = model_class.new(name: "John", age: 0)
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include("Age must be greater than 0")
    end

    it 'validates types' do
      instance = model_class.new(name: 123, age: "30")
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include(
        "Name must be a String",
        "Age must be an Integer"
      )
    end

    it 'accepts valid attributes' do
      instance = model_class.new(name: "John", age: 30)
      expect(instance.valid?).to be true
    end

    it 'provides access to raw attributes' do
      instance = model_class.new(name: "John", age: 30)
      expect(instance.attributes).to eq({ "name" => "John", "age" => 30 })
    end
  end
end 