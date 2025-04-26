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

    it "validates array elements" do
      schema.array(:numbers) { integer }
      errors = schema.check_validity(numbers: [1, "2", 3])
      expect(errors).to contain_exactly("Numbers[1] must be an Integer")
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

    it "validates hashes inside arrays" do
      schema.array(:users) do
        hash do
          string :name
          integer :age
        end
      end

      errors =
        schema.check_validity(
          users: [
            { name: "Alice", age: 30 },
            { name: 123, age: "invalid" }, # name should be string, age should be integer
            { name: "Bob", age: 25 }
          ]
        )

      expect(errors).to contain_exactly(
        "Users[1][name] must be a String",
        "Users[1][age] must be an Integer"
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

    it "validates hash values" do
      schema.hash(:config) do
        string :host
        integer :port
      end

      errors =
        schema.check_validity(
          config: {
            host: 123, # should be string
            port: "80" # should be integer
          }
        )

      expect(errors).to contain_exactly(
        "Config[host] must be a String",
        "Config[port] must be an Integer"
      )
    end

    it "validates that value is a hash" do
      schema.hash(:config) { string :host }

      errors = schema.check_validity(config: "not a hash")
      expect(errors).to contain_exactly("Config must be a Hash")
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

    it "validates nested hashes" do
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

      errors =
        schema.check_validity(
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

      expect(errors).to contain_exactly(
        "Config[database][host] must be a String",
        "Config[database][port] must be an Integer",
        "Config[database][credentials][username] must be a String",
        "Config[database][credentials][password] must be a String"
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

    it "validates arrays inside hashes" do
      schema.hash(:config) do
        string :name
        array :tags do
          string
        end
      end

      errors =
        schema.check_validity(
          config: {
            name: "test",
            tags: ["valid", 123, "also valid"] # second element should be string
          }
        )

      expect(errors).to contain_exactly("Config[tags][1] must be a String")
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

    context "with datetime fields" do
      let(:schema) { described_class.new.tap { |s| s.datetime(:start_time) } }

      it "accepts DateTime values" do
        errors = schema.check_validity(start_time: DateTime.now)
        expect(errors).to be_empty
      end

      it "accepts nil values" do
        errors = schema.check_validity(start_time: nil)
        expect(errors).to be_empty
      end

      it "returns errors for non-DateTime values" do
        errors = schema.check_validity(start_time: "2024-01-01")
        expect(errors).to contain_exactly("Start time must be a DateTime")
      end

      it "can be required using presence validation" do
        schema.validates :start_time, presence: true
        errors = schema.check_validity(start_time: nil)
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
      errors = schema.check_validity(name: "John", age: 30)
      expect(errors).to be_empty
    end

    it "returns errors for type mismatches" do
      errors = schema.check_validity(name: 123, age: "30")
      expect(errors).to contain_exactly(
        "Name must be a String",
        "Age must be an Integer"
      )
    end

    context "with boolean fields" do
      let(:schema) { described_class.new.tap { |s| s.boolean(:active) } }

      it "accepts true values" do
        errors = schema.check_validity(active: true)
        expect(errors).to be_empty
      end

      it "accepts false values" do
        errors = schema.check_validity(active: false)
        expect(errors).to be_empty
      end

      it "accepts nil values" do
        errors = schema.check_validity(active: nil)
        expect(errors).to be_empty
      end

      it "returns errors for non-boolean values" do
        errors = schema.check_validity(active: "true")
        expect(errors).to contain_exactly("Active must be true or false")

        errors = schema.check_validity(active: 1)
        expect(errors).to contain_exactly("Active must be true or false")
      end

      it "can be required using presence validation" do
        schema.validates :active, presence: true
        errors = schema.check_validity(active: nil)
        expect(errors).to contain_exactly("Active can't be blank")
      end
    end

    context "with string fields" do
      let(:schema) { described_class.new.tap { |s| s.string(:name) } }

      it "accepts string values" do
        errors = schema.check_validity(name: "John")
        expect(errors).to be_empty
      end

      it "accepts nil values" do
        errors = schema.check_validity(name: nil)
        expect(errors).to be_empty
      end

      it "returns errors for non-string values" do
        errors = schema.check_validity(name: 123)
        expect(errors).to contain_exactly("Name must be a String")
      end

      it "can be required using presence validation" do
        schema.validates :name, presence: true
        errors = schema.check_validity(name: nil)
        expect(errors).to contain_exactly("Name can't be blank")
      end
    end

    context "with integer fields" do
      let(:schema) { described_class.new.tap { |s| s.integer(:age) } }

      it "accepts integer values" do
        errors = schema.check_validity(age: 30)
        expect(errors).to be_empty
      end

      it "accepts nil values" do
        errors = schema.check_validity(age: nil)
        expect(errors).to be_empty
      end

      it "returns errors for non-integer values" do
        errors = schema.check_validity(age: "30")
        expect(errors).to contain_exactly("Age must be an Integer")
      end

      it "can be required using presence validation" do
        schema.validates :age, presence: true
        errors = schema.check_validity(age: nil)
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
