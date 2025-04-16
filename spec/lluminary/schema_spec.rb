# frozen_string_literal: true
require "spec_helper"

RSpec.describe Lluminary::Schema do
  let(:schema) { described_class.new }

  describe "#initialize" do
    it "creates an empty fields hash" do
      expect(schema.fields).to eq({})
    end
  end

  describe "#string" do
    it "adds a string field to the schema" do
      schema.string(:name)
      expect(schema.fields).to eq({ name: { type: :string, description: nil } })
    end

    it "adds a string field with description" do
      schema.string(:name, description: "The user's full name")
      expect(schema.fields).to eq(
        { name: { type: :string, description: "The user's full name" } }
      )
    end
  end

  describe "#integer" do
    it "adds an integer field to the schema" do
      schema.integer(:count)
      expect(schema.fields).to eq(
        { count: { type: :integer, description: nil } }
      )
    end

    it "adds an integer field with description" do
      schema.integer(:count, description: "The total number of items")
      expect(schema.fields).to eq(
        { count: { type: :integer, description: "The total number of items" } }
      )
    end
  end

  describe "#boolean" do
    it "adds a boolean field to the schema" do
      schema.boolean(:active)
      expect(schema.fields).to eq(
        { active: { type: :boolean, description: nil } }
      )
    end

    it "adds a boolean field with description" do
      schema.boolean(:active, description: "Whether the item is active")
      expect(schema.fields).to eq(
        {
          active: {
            type: :boolean,
            description: "Whether the item is active"
          }
        }
      )
    end
  end

  describe "#float" do
    it "adds a float field to the schema" do
      schema.float(:price)
      expect(schema.fields).to eq({ price: { type: :float, description: nil } })
    end

    it "adds a float field with description" do
      schema.float(:price, description: "The price of the item")
      expect(schema.fields).to eq(
        { price: { type: :float, description: "The price of the item" } }
      )
    end
  end

  describe "#datetime" do
    it "adds a datetime field to the schema" do
      schema.datetime(:start_time)
      expect(schema.fields).to eq(
        { start_time: { type: :datetime, description: nil } }
      )
    end

    it "adds a datetime field with description" do
      schema.datetime(:start_time, description: "When the event starts")
      expect(schema.fields).to eq(
        {
          start_time: {
            type: :datetime,
            description: "When the event starts"
          }
        }
      )
    end
  end

  describe "#fields" do
    it "returns the fields hash" do
      schema.string(:name)
      expect(schema.fields).to eq({ name: { type: :string, description: nil } })
    end

    it "returns the same hash instance" do
      schema.string(:name)
      first_call = schema.fields
      second_call = schema.fields
      expect(first_call).to be(second_call)
    end

    context "with datetime fields" do
      let(:schema) { described_class.new.tap { |s| s.datetime(:start_time) } }

      it "accepts DateTime values" do
        errors = schema.validate(start_time: DateTime.now)
        expect(errors).to be_empty
      end

      it "accepts nil values" do
        errors = schema.validate(start_time: nil)
        expect(errors).to be_empty
      end

      it "returns errors for non-DateTime values" do
        errors = schema.validate(start_time: "2024-01-01")
        expect(errors).to contain_exactly("Start time must be a DateTime")
      end

      it "can be required using presence validation" do
        schema.validates :start_time, presence: true
        errors = schema.validate(start_time: nil)
        expect(errors).to contain_exactly("Start time can't be blank")
      end
    end
  end

  describe "#validate" do
    let(:schema) do
      described_class.new.tap do |s|
        s.string(:name)
        s.integer(:age)
      end
    end

    it "returns no errors when all values match their field types" do
      errors = schema.validate(name: "John", age: 30)
      expect(errors).to be_empty
    end

    it "returns errors for type mismatches" do
      errors = schema.validate(name: 123, age: "30")
      expect(errors).to contain_exactly(
        "Name must be a String",
        "Age must be an Integer"
      )
    end

    context "with boolean fields" do
      let(:schema) { described_class.new.tap { |s| s.boolean(:active) } }

      it "accepts true values" do
        errors = schema.validate(active: true)
        expect(errors).to be_empty
      end

      it "accepts false values" do
        errors = schema.validate(active: false)
        expect(errors).to be_empty
      end

      it "accepts nil values" do
        errors = schema.validate(active: nil)
        expect(errors).to be_empty
      end

      it "returns errors for non-boolean values" do
        errors = schema.validate(active: "true")
        expect(errors).to contain_exactly("Active must be true or false")

        errors = schema.validate(active: 1)
        expect(errors).to contain_exactly("Active must be true or false")
      end

      it "can be required using presence validation" do
        schema.validates :active, presence: true
        errors = schema.validate(active: nil)
        expect(errors).to contain_exactly("Active can't be blank")
      end
    end

    context "with string fields" do
      let(:schema) { described_class.new.tap { |s| s.string(:name) } }

      it "accepts string values" do
        errors = schema.validate(name: "John")
        expect(errors).to be_empty
      end

      it "accepts nil values" do
        errors = schema.validate(name: nil)
        expect(errors).to be_empty
      end

      it "returns errors for non-string values" do
        errors = schema.validate(name: 123)
        expect(errors).to contain_exactly("Name must be a String")
      end

      it "can be required using presence validation" do
        schema.validates :name, presence: true
        errors = schema.validate(name: nil)
        expect(errors).to contain_exactly("Name can't be blank")
      end
    end

    context "with integer fields" do
      let(:schema) { described_class.new.tap { |s| s.integer(:age) } }

      it "accepts integer values" do
        errors = schema.validate(age: 30)
        expect(errors).to be_empty
      end

      it "accepts nil values" do
        errors = schema.validate(age: nil)
        expect(errors).to be_empty
      end

      it "returns errors for non-integer values" do
        errors = schema.validate(age: "30")
        expect(errors).to contain_exactly("Age must be an Integer")
      end

      it "can be required using presence validation" do
        schema.validates :age, presence: true
        errors = schema.validate(age: nil)
        expect(errors).to contain_exactly("Age can't be blank")
      end
    end
  end

  describe "ActiveModel validations" do
    let(:schema) do
      described_class.new.tap do |s|
        s.string(:name)
        s.integer(:age)

        s.validates :name, presence: true
        s.validates :age, numericality: { greater_than: 0 }
      end
    end

    it "generates a class that includes ActiveModel::Validations" do
      schema_model = schema.schema_model
      expect(schema_model.ancestors).to include(ActiveModel::Validations)
    end

    it "adds accessors for defined fields" do
      schema_model = schema.schema_model
      instance = schema_model.new
      instance.name = "John"
      instance.age = 30
      expect(instance.name).to eq("John")
      expect(instance.age).to eq(30)
    end

    it "validates presence" do
      schema_model = schema.schema_model
      instance = schema_model.new
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include("Name can't be blank")
    end

    it "validates numericality" do
      schema_model = schema.schema_model
      instance = schema_model.new(name: "John", age: 0)
      expect(instance.valid?).to be false
      expect(instance.errors.full_messages).to include(
        "Age must be greater than 0"
      )
    end

    it "returns true for valid instances" do
      schema_model = schema.schema_model
      instance = schema_model.new(name: "John", age: 30)
      expect(instance.valid?).to be true
    end
  end
end
