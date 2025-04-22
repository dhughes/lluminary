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

    context "with individual validations" do
      it "formats presence validation" do
        field = {
          type: :string,
          description: "A required field",
          validations: [[{}, { presence: true }]]
        }
        description = described_class.new("required_field", field)
        expect(description.to_s).to eq(
          "required_field (string): A required field (must be present)"
        )
      end

      it "formats inclusion validation" do
        field = {
          type: :string,
          description: "A status field",
          validations: [[{}, { inclusion: { in: %w[active inactive] } }]]
        }
        description = described_class.new("status", field)
        expect(description.to_s).to eq(
          "status (string): A status field (must be one of: active, inactive)"
        )
      end

      it "formats exclusion validation" do
        field = {
          type: :string,
          description: "A username field",
          validations: [[{}, { exclusion: { in: %w[admin root] } }]]
        }
        description = described_class.new("username", field)
        expect(description.to_s).to eq(
          "username (string): A username field (must not be one of: admin, root)"
        )
      end

      it "formats numericality validation" do
        field = {
          type: :integer,
          description: "An age field",
          validations: [
            [{}, { numericality: { greater_than: 0, less_than: 120 } }]
          ]
        }
        description = described_class.new("age", field)
        expect(description.to_s).to eq(
          "age (integer): An age field (must be greater than 0, must be less than 120)"
        )
      end

      it "formats comparison validation" do
        field = {
          type: :integer,
          description: "A quantity field",
          validations: [
            [
              {},
              { comparison: { greater_than: 10, less_than_or_equal_to: 100 } }
            ]
          ]
        }
        description = described_class.new("quantity", field)
        expect(description.to_s).to eq(
          "quantity (integer): A quantity field (must be greater than 10, must be less than or equal to 100)"
        )
      end

      it "formats absence validation" do
        field = {
          type: :string,
          description: "A restricted field",
          validations: [[{}, { absence: true }]]
        }
        description = described_class.new("restricted_field", field)
        expect(description.to_s).to eq(
          "restricted_field (string): A restricted field (must be absent)"
        )
      end
    end

    context "with complex validation combinations" do
      it "formats length with format and presence validations" do
        field = {
          type: :string,
          description: "A username field",
          validations: [
            [{}, { presence: true }],
            [{}, { length: { in: 3..20 } }],
            [{}, { format: { with: "/^[a-z0-9_]+$/" } }]
          ]
        }
        description = described_class.new("username", field)
        expect(description.to_s).to eq(
          "username (string): A username field (must be present, must be between 3 and 20 characters, must match format: /^[a-z0-9_]+$/)"
        )
      end

      it "formats numericality with inclusion validations" do
        field = {
          type: :integer,
          description: "A rating field",
          validations: [
            [{}, { numericality: { greater_than_or_equal_to: 1 } }],
            [{}, { inclusion: { in: [1, 2, 3, 4, 5] } }]
          ]
        }
        description = described_class.new("rating", field)
        expect(description.to_s).to eq(
          "rating (integer): A rating field (must be greater than or equal to 1, must be one of: 1, 2, 3, 4, 5)"
        )
      end
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
      expect(description.to_s).to eq("items (array of string): A list of items")
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
        items (array of string): A list of items
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
        numbers (array of integer): A list of numbers
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
        decimals (array of float): A list of decimals
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
        flags (array of boolean): A list of flags
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
        groups (array of array of string): Groups of related items
        Example: [["first item", "second item", "..."], ["first item", "second item", "..."]]
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
        groups (array of array of boolean): Groups of flags
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
        groups (array of array): Groups of items
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
        items (array of string): A list of items
        Validation: must be present
        Example: ["first item", "second item", "..."]
      DESCRIPTION
      expect(description.to_schema_s).to eq(expected)
    end
  end
end
