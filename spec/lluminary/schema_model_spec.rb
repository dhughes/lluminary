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

  describe "boolean field validation" do
    let(:fields) do
      { active: { type: :boolean, description: "Whether the item is active" } }
    end
    let(:model_class) { described_class.build(fields: fields, validations: []) }

    it "accepts true values" do
      instance = model_class.new(active: true)
      expect(instance.valid?).to be true
      expect(instance.errors.full_messages).to be_empty
    end

    it "accepts false values" do
      instance = model_class.new(active: false)
      expect(instance.valid?).to be true
      expect(instance.errors.full_messages).to be_empty
    end

    it "accepts nil values" do
      instance = model_class.new(active: nil)
      expect(instance.valid?).to be true
      expect(instance.errors.full_messages).to be_empty
    end

    it "returns errors for non-boolean values" do
      instance = model_class.new(active: "true")
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to contain_exactly(
        "Active must be true or false"
      )

      instance = model_class.new(active: 1)
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to contain_exactly(
        "Active must be true or false"
      )
    end

    it "can be required using presence validation" do
      validations = [[[:active], { presence: true }]]
      model_class_with_presence =
        described_class.build(fields: fields, validations: validations)
      instance = model_class_with_presence.new(active: nil)
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to contain_exactly(
        "Active can't be blank"
      )
    end
  end

  describe "hash field with array validation" do
    let(:fields) do
      {
        config: {
          type: :hash,
          description: "Configuration",
          fields: {
            name: {
              type: :string,
              description: nil
            },
            tags: {
              type: :array,
              description: nil,
              element_type: {
                type: :string,
                description: nil
              }
            }
          }
        }
      }
    end
    let(:model_class) { described_class.build(fields: fields, validations: []) }

    it "validates arrays inside hashes" do
      instance =
        model_class.new(
          config: {
            name: "test",
            tags: ["valid", 123, "also valid"]
          }
        )
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to contain_exactly(
        "Config[tags][1] must be a String"
      )
    end
  end

  describe "nested hash validation" do
    let(:fields) do
      {
        config: {
          type: :hash,
          description: nil,
          fields: {
            name: {
              type: :string,
              description: nil
            },
            database: {
              type: :hash,
              description: nil,
              fields: {
                host: {
                  type: :string,
                  description: nil
                },
                port: {
                  type: :integer,
                  description: nil
                },
                credentials: {
                  type: :hash,
                  description: nil,
                  fields: {
                    username: {
                      type: :string,
                      description: nil
                    },
                    password: {
                      type: :string,
                      description: nil
                    }
                  }
                }
              }
            }
          }
        }
      }
    end
    let(:model_class) { described_class.build(fields: fields, validations: []) }

    it "validates nested hashes" do
      instance =
        model_class.new(
          config: {
            name: "test",
            database: {
              host: 123, # should be string
              port: "80", # should be integer
              credentials: {
                username: 456, # should be string
                password: 789 # should be string
              }
            }
          }
        )
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to contain_exactly(
        "Config[database][host] must be a String",
        "Config[database][port] must be an Integer",
        "Config[database][credentials][username] must be a String",
        "Config[database][credentials][password] must be a String"
      )
    end
  end

  describe "hash type enforcement" do
    let(:fields) do
      {
        config: {
          type: :hash,
          description: nil,
          fields: {
            host: {
              type: :string,
              description: nil
            }
          }
        }
      }
    end
    let(:model_class) { described_class.build(fields: fields, validations: []) }

    it "validates that value is a hash" do
      instance = model_class.new(config: "not a hash")
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to contain_exactly(
        "Config must be a Hash"
      )
    end
  end

  describe "array of hashes validation" do
    let(:fields) do
      {
        users: {
          type: :array,
          description: nil,
          element_type: {
            type: :hash,
            description: nil,
            fields: {
              name: {
                type: :string,
                description: nil
              },
              age: {
                type: :integer,
                description: nil
              }
            }
          }
        }
      }
    end
    let(:model_class) { described_class.build(fields: fields, validations: []) }

    it "validates hashes inside arrays" do
      instance =
        model_class.new(
          users: [
            { name: "Alice", age: 30 },
            { name: 123, age: "invalid" }, # name should be string, age should be integer
            { name: "Bob", age: 25 }
          ]
        )
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to contain_exactly(
        "Users[1][name] must be a String",
        "Users[1][age] must be an Integer"
      )
    end
  end

  describe "float field validation" do
    let(:fields) { { score: { type: :float, description: "The score" } } }
    let(:model_class) { described_class.build(fields: fields, validations: []) }

    it "accepts float values" do
      instance = model_class.new(score: 3.14)
      expect(instance.valid?).to be true
      expect(instance.errors.full_messages).to be_empty
    end

    it "accepts nil values" do
      instance = model_class.new(score: nil)
      expect(instance.valid?).to be true
      expect(instance.errors.full_messages).to be_empty
    end

    it "returns errors for non-float values" do
      instance = model_class.new(score: "not a float")
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to contain_exactly(
        "Score must be a float"
      )

      instance = model_class.new(score: 42)
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to contain_exactly(
        "Score must be a float"
      )
    end
  end
end
