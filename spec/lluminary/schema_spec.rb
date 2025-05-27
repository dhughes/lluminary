# frozen_string_literal: true
require "spec_helper"

RSpec.describe Lluminary::Schema do
  let(:schema) { described_class.new }

  describe "#initialize" do
    it "creates an empty fields hash" do
      expect(schema.fields).to eq({})
    end
  end

  describe "#validate" do
    it "registers a custom validation method" do
      schema.validate(:validate_something)
      expect(schema.custom_validations).to eq(
        [{ method: :validate_something, description: nil }]
      )
    end

    it "can register multiple validation methods" do
      schema.validate(:validate_something)
      schema.validate(:validate_something_else)
      expect(schema.custom_validations).to eq(
        [
          { method: :validate_something, description: nil },
          { method: :validate_something_else, description: nil }
        ]
      )
    end

    it "registers a custom validation method with a description" do
      schema.validate(
        :validate_score_range,
        description: "Score must be between 0 and 100"
      )
      expect(schema.custom_validations).to eq(
        [
          {
            method: :validate_score_range,
            description: "Score must be between 0 and 100"
          }
        ]
      )
    end

    it "registers multiple custom validations with and without descriptions" do
      schema.validate(
        :validate_score_range,
        description: "Score must be between 0 and 100"
      )
      schema.validate(:validate_score_parity)
      expect(schema.custom_validations).to eq(
        [
          {
            method: :validate_score_range,
            description: "Score must be between 0 and 100"
          },
          { method: :validate_score_parity, description: nil }
        ]
      )
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

  describe "#array" do
    it "adds an untyped array field to the schema" do
      schema.array(:items)
      expect(schema.fields).to eq({ items: { type: :array, description: nil } })
    end

    it "adds an untyped array field with description" do
      schema.array(:items, description: "A list of items")
      expect(schema.fields).to eq(
        { items: { type: :array, description: "A list of items" } }
      )
    end

    it "requires a name for the array field" do
      expect { schema.array }.to raise_error(ArgumentError)
    end

    it "accepts array type without a name" do
      schema.array(:items) { array { string } }
      expect(schema.fields).to eq(
        {
          items: {
            type: :array,
            element_type: {
              type: :array,
              element_type: {
                type: :string,
                description: nil
              },
              description: nil
            },
            description: nil
          }
        }
      )
    end

    it "accepts string type without a name" do
      schema.array(:items) { string }
      expect(schema.fields).to eq(
        {
          items: {
            type: :array,
            element_type: {
              type: :string,
              description: nil
            },
            description: nil
          }
        }
      )
    end

    it "accepts integer type without a name" do
      schema.array(:items) { integer }
      expect(schema.fields).to eq(
        {
          items: {
            type: :array,
            element_type: {
              type: :integer,
              description: nil
            },
            description: nil
          }
        }
      )
    end

    it "accepts boolean type without a name" do
      schema.array(:items) { boolean }
      expect(schema.fields).to eq(
        {
          items: {
            type: :array,
            element_type: {
              type: :boolean,
              description: nil
            },
            description: nil
          }
        }
      )
    end

    it "accepts float type without a name" do
      schema.array(:items) { float }
      expect(schema.fields).to eq(
        {
          items: {
            type: :array,
            element_type: {
              type: :float,
              description: nil
            },
            description: nil
          }
        }
      )
    end

    it "accepts datetime type without a name" do
      schema.array(:items) { datetime }
      expect(schema.fields).to eq(
        {
          items: {
            type: :array,
            element_type: {
              type: :datetime,
              description: nil
            },
            description: nil
          }
        }
      )
    end

    it "supports hashes inside arrays" do
      schema.array(:users) do
        hash do
          string :name
          integer :age
        end
      end

      expect(schema.fields[:users]).to eq(
        {
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
      )
    end

    it "supports dictionaries inside arrays" do
      schema.array(:configs) { dictionary { string } }

      expect(schema.fields[:configs]).to eq(
        {
          type: :array,
          description: nil,
          element_type: {
            type: :dictionary,
            description: nil,
            value_type: {
              type: :string,
              description: nil
            }
          }
        }
      )
    end
  end

  describe "#hash" do
    it "requires a block for hash fields" do
      expect { schema.hash(:config) }.to raise_error(
        ArgumentError,
        "Hash fields must be defined with a block"
      )
    end

    it "adds a hash field with nested fields to the schema" do
      schema.hash(:config, description: "Configuration") do
        string :host, description: "The server hostname"
        integer :port
      end

      expect(schema.fields).to eq(
        {
          config: {
            type: :hash,
            description: "Configuration",
            fields: {
              host: {
                type: :string,
                description: "The server hostname"
              },
              port: {
                type: :integer,
                description: nil
              }
            }
          }
        }
      )
    end

    it "supports nested hashes" do
      schema.hash(:config) do
        string :name
        hash :database do
          string :host
          integer :port
          hash :credentials do
            string :username
            string :password
          end
        end
      end

      expect(schema.fields[:config]).to eq(
        {
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
      )
    end

    it "supports arrays inside hashes" do
      schema.hash(:config) do
        string :name
        array :tags do
          string
        end
      end

      expect(schema.fields[:config]).to eq(
        {
          type: :hash,
          description: nil,
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
      )
    end

    it "supports dictionaries inside hashes" do
      schema.hash(:config) do
        string :name
        dictionary :settings do
          string
        end
      end

      expect(schema.fields[:config]).to eq(
        {
          type: :hash,
          description: nil,
          fields: {
            name: {
              type: :string,
              description: nil
            },
            settings: {
              type: :dictionary,
              description: nil,
              value_type: {
                type: :string,
                description: nil
              }
            }
          }
        }
      )
    end
  end

  describe "#dictionary" do
    it "adds a dictionary field to the schema" do
      schema.dictionary(:tags) { string }
      expect(schema.fields).to eq(
        {
          tags: {
            type: :dictionary,
            description: nil,
            value_type: {
              type: :string,
              description: nil
            }
          }
        }
      )
    end

    it "adds a dictionary field with description" do
      schema.dictionary(:tags, description: "A map of tags") { string }
      expect(schema.fields).to eq(
        {
          tags: {
            type: :dictionary,
            description: "A map of tags",
            value_type: {
              type: :string,
              description: nil
            }
          }
        }
      )
    end

    it "requires a name for the dictionary field" do
      expect { schema.dictionary }.to raise_error(ArgumentError)
    end

    it "requires a block for dictionary fields" do
      expect { schema.dictionary(:tags) }.to raise_error(
        ArgumentError,
        "Dictionary fields must be defined with a block"
      )
    end

    it "accepts string type without a name" do
      schema.dictionary(:tags) { string }
      expect(schema.fields).to eq(
        {
          tags: {
            type: :dictionary,
            description: nil,
            value_type: {
              type: :string,
              description: nil
            }
          }
        }
      )
    end

    it "accepts integer type without a name" do
      schema.dictionary(:scores) { integer }
      expect(schema.fields).to eq(
        {
          scores: {
            type: :dictionary,
            description: nil,
            value_type: {
              type: :integer,
              description: nil
            }
          }
        }
      )
    end

    it "accepts boolean type without a name" do
      schema.dictionary(:flags) { boolean }
      expect(schema.fields).to eq(
        {
          flags: {
            type: :dictionary,
            description: nil,
            value_type: {
              type: :boolean,
              description: nil
            }
          }
        }
      )
    end

    it "accepts float type without a name" do
      schema.dictionary(:ratings) { float }
      expect(schema.fields).to eq(
        {
          ratings: {
            type: :dictionary,
            description: nil,
            value_type: {
              type: :float,
              description: nil
            }
          }
        }
      )
    end

    it "accepts datetime type without a name" do
      schema.dictionary(:timestamps) { datetime }
      expect(schema.fields).to eq(
        {
          timestamps: {
            type: :dictionary,
            description: nil,
            value_type: {
              type: :datetime,
              description: nil
            }
          }
        }
      )
    end

    it "supports hashes as dictionary values" do
      schema.dictionary(:users) do
        hash do
          string :name
          integer :age
        end
      end

      expect(schema.fields[:users]).to eq(
        {
          type: :dictionary,
          description: nil,
          value_type: {
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
      )
    end

    it "supports arrays as dictionary values" do
      schema.dictionary(:categories) { array { string } }

      expect(schema.fields[:categories]).to eq(
        {
          type: :dictionary,
          description: nil,
          value_type: {
            type: :array,
            description: nil,
            element_type: {
              type: :string,
              description: nil
            }
          }
        }
      )
    end
  end

  describe "primitive types" do
    it "requires a name for string fields" do
      expect { schema.string }.to raise_error(ArgumentError)
    end

    it "requires a name for integer fields" do
      expect { schema.integer }.to raise_error(ArgumentError)
    end

    it "requires a name for boolean fields" do
      expect { schema.boolean }.to raise_error(ArgumentError)
    end

    it "requires a name for float fields" do
      expect { schema.float }.to raise_error(ArgumentError)
    end

    it "requires a name for datetime fields" do
      expect { schema.datetime }.to raise_error(ArgumentError)
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

  describe "custom method validations" do
    it "passes custom validations to schema model" do
      schema = described_class.new
      schema.integer(:score)
      schema.validate(:validate_score_range)

      model_class = schema.schema_model
      method_names =
        model_class.custom_validation_methods.map { |v| v[:method] }
      expect(method_names).to contain_exactly(:validate_score_range)
    end

    it "accepts multiple custom validations" do
      schema = described_class.new
      schema.integer(:score)
      schema.validate(:validate_score_range)
      schema.validate(:validate_score_parity)

      model_class = schema.schema_model
      method_names =
        model_class.custom_validation_methods.map { |v| v[:method] }
      expect(method_names).to contain_exactly(
        :validate_score_range,
        :validate_score_parity
      )
    end
  end
end
