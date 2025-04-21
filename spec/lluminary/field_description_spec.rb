# frozen_string_literal: true
require "spec_helper"

RSpec.describe Lluminary::FieldDescription do
  describe "#to_s" do
    it "generates a description for a string field" do
      field = { type: :string, description: "A test field" }
      description = described_class.new("test_field", field)
      expect(description.to_s).to eq("test_field (string): A test field")
    end

    it "generates a description for a field without a description" do
      field = { type: :integer }
      description = described_class.new("count", field)
      expect(description.to_s).to eq("count (integer)")
    end

    it "includes validation descriptions when present" do
      field = {
        type: :string,
        description: "A test field",
        validations: [
          [{}, { length: { minimum: 5, maximum: 10 } }],
          [{}, { format: { with: "/^[A-Z]+$/" } }]
        ]
      }
      description = described_class.new("test_field", field)
      expected = <<~DESCRIPTION.chomp
        test_field (string): A test field (must be at least 5 characters, must be at most 10 characters, must match format: /^[A-Z]+$/)
      DESCRIPTION
      expect(description.to_s).to eq(expected)
    end

    it "generates a description for an array field with element type" do
      field = {
        type: :array,
        description: "A list of items",
        element_type: {
          type: :string
        }
      }
      description = described_class.new("items", field)
      expect(description.to_s).to eq(
        "items (array of strings): A list of items"
      )
    end

    it "generates a description for an array field without element type" do
      field = { type: :array, description: "A list of items" }
      description = described_class.new("items", field)
      expect(description.to_s).to eq("items (array): A list of items")
    end
  end

  describe "#to_schema_s" do
    it "generates schema description for a string field" do
      field = { type: :string, description: "A test field" }
      description = described_class.new("test_field", field)
      expected = <<~DESCRIPTION.chomp
        test_field (string): A test field
        Example: "your test_field here"
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end

    it "generates schema description for a datetime field" do
      field = { type: :datetime, description: "A timestamp" }
      description = described_class.new("created_at", field)
      expected = <<~DESCRIPTION.chomp
        created_at (datetime in ISO8601 format): A timestamp
        Example: "2024-01-01T12:00:00+00:00"
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end

    it "generates schema description for an array of strings" do
      field = {
        type: :array,
        description: "A list of items",
        element_type: {
          type: :string
        }
      }
      description = described_class.new("items", field)
      expected = <<~DESCRIPTION.chomp
        items (array of strings): A list of items
        Example: ["first item", "second item", "..."]
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end

    it "generates schema description for an array of integers" do
      field = {
        type: :array,
        description: "A list of numbers",
        element_type: {
          type: :integer
        }
      }
      description = described_class.new("numbers", field)
      expected = <<~DESCRIPTION.chomp
        numbers (array of integers): A list of numbers
        Example: [1, 2, 3]
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end

    it "generates schema description for an array of floats" do
      field = {
        type: :array,
        description: "A list of decimals",
        element_type: {
          type: :float
        }
      }
      description = described_class.new("decimals", field)
      expected = <<~DESCRIPTION.chomp
        decimals (array of floats): A list of decimals
        Example: [1.0, 2.0, 3.0]
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end

    it "generates schema description for an array of booleans" do
      field = {
        type: :array,
        description: "A list of flags",
        element_type: {
          type: :boolean
        }
      }
      description = described_class.new("flags", field)
      expected = <<~DESCRIPTION.chomp
        flags (array of booleans): A list of flags
        Example: [true, false, true]
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end

    it "generates schema description for an array of datetimes" do
      field = {
        type: :array,
        description: "A list of dates",
        element_type: {
          type: :datetime
        }
      }
      description = described_class.new("dates", field)
      expected = <<~DESCRIPTION.chomp
        dates (array of datetime in ISO8601 format): A list of dates
        Example: ["2024-01-01T12:00:00+00:00", "2024-01-02T12:00:00+00:00"]
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end

    it "generates schema description for an array of arrays of strings" do
      field = {
        type: :array,
        description: "Groups of related items",
        element_type: {
          type: :array,
          element_type: {
            type: :string
          }
        }
      }
      description = described_class.new("groups", field)
      expected = <<~DESCRIPTION.chomp
        groups (array of arrays of strings): Groups of related items
        Example: [["first group", "second group", "..."], ["first group", "second group", "..."]]
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end

    it "generates schema description for an array of arrays of booleans" do
      field = {
        type: :array,
        description: "Groups of flags",
        element_type: {
          type: :array,
          element_type: {
            type: :boolean
          }
        }
      }
      description = described_class.new("groups", field)
      expected = <<~DESCRIPTION.chomp
        groups (array of arrays of booleans): Groups of flags
        Example: [[true, false, true], [true, false, true]]
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end

    it "generates schema description for an array of untyped arrays" do
      field = {
        type: :array,
        description: "Groups of items",
        element_type: {
          type: :array
        }
      }
      description = described_class.new("groups", field)
      expected = <<~DESCRIPTION.chomp
        groups (array of arrays): Groups of items
        Example: [[...], [...]]
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end

    it "includes validation descriptions for arrays" do
      field = {
        type: :array,
        description: "A list of items",
        element_type: {
          type: :string
        },
        validations: [[{}, { presence: true }]]
      }
      description = described_class.new("items", field)
      expected = <<~DESCRIPTION.chomp
        items (array of strings): A list of items
        Validation: must be present
        Example: ["first item", "second item", "..."]
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end
  end
end
