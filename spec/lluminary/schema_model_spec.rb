# frozen_string_literal: true
require "spec_helper"

RSpec.describe Lluminary::SchemaModel do
  describe ".build" do
    let(:fields) do
      {
        name: {
          type: :string,
          description: "The user's name"
        },
        age: {
          type: :integer,
          description: "The user's age"
        }
      }
    end

    let(:validations) do
      [
        [[:name], { presence: true }],
        [[:age], { numericality: { greater_than: 0 } }]
      ]
    end

    let(:model_class) do
      described_class.build(fields: fields, validations: validations)
    end

    it "creates a class that inherits from SchemaModel" do
      expect(model_class.ancestors).to include(described_class)
    end

    it "includes ActiveModel::Validations" do
      expect(model_class.ancestors).to include(ActiveModel::Validations)
    end

    it "adds accessors for fields" do
      instance = model_class.new(name: "John", age: 30)
      expect(instance.name).to eq("John")
      expect(instance.age).to eq(30)
    end

    it "validates presence" do
      instance = model_class.new(age: 30)
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include("Name can't be blank")
    end

    it "validates numericality" do
      instance = model_class.new(name: "John", age: 0)
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include(
        "Age must be greater than 0"
      )
    end

    it "validates types" do
      instance = model_class.new(name: 123, age: "30")
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include(
        "Name must be a String",
        "Age must be an Integer"
      )
    end

    it "validates float types" do
      fields = { price: { type: :float, description: "The price" } }
      model_class = described_class.build(fields: fields, validations: [])

      # Test that nil is allowed
      instance = model_class.new(price: nil)
      expect(instance.valid?).to be true

      # Test invalid float value
      instance = model_class.new(price: "not a float")
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include("Price must be a float")

      # Test valid float value
      instance = model_class.new(price: 12.34)
      expect(instance.valid?).to be true
    end

    it "accepts valid attributes" do
      instance = model_class.new(name: "John", age: 30)
      expect(instance.valid?).to be true
    end

    it "provides access to raw attributes" do
      instance = model_class.new(name: "John", age: 30)
      expect(instance.attributes).to eq({ "name" => "John", "age" => 30 })
    end

    it "validates array types" do
      fields = {
        items: {
          type: :array,
          element_type: {
            type: :string,
            description: nil
          },
          description: "A list of strings"
        }
      }
      model_class = described_class.build(fields: fields, validations: [])

      # Test that nil is allowed
      instance = model_class.new(items: nil)
      expect(instance.valid?).to be true

      # Test valid array of strings
      instance = model_class.new(items: %w[one two])
      expect(instance.valid?).to be true

      # Test invalid array (not an array)
      instance = model_class.new(items: "not an array")
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include("Items must be an Array")

      # Test invalid array elements
      instance = model_class.new(items: ["one", 2, "three"])
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include(
        "Items[1] must be a String"
      )
    end

    it "validates nested array types" do
      fields = {
        matrix: {
          type: :array,
          element_type: {
            type: :array,
            element_type: {
              type: :integer,
              description: nil
            },
            description: nil
          },
          description: "A matrix of integers"
        }
      }
      model_class = described_class.build(fields: fields, validations: [])

      # Test valid nested arrays
      instance = model_class.new(matrix: [[1, 2], [3, 4]])
      expect(instance.valid?).to be true

      # Test invalid outer array
      instance = model_class.new(matrix: "not an array")
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include(
        "Matrix must be an Array"
      )

      # Test invalid inner array
      instance = model_class.new(matrix: ["not an array"])
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include(
        "Matrix[0] must be an Array"
      )

      # Test invalid inner array elements
      instance = model_class.new(matrix: [[1, "2"], [3, 4]])
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include(
        "Matrix[0][1] must be an Integer"
      )
    end
  end
end
