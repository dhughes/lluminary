# frozen_string_literal: true
require "spec_helper"

RSpec.describe Lluminary::Models::Base do
  let(:model) { described_class.new }

  describe "#compatible_with?" do
    it "raises NotImplementedError" do
      expect { model.compatible_with?(:openai) }.to raise_error(
        NotImplementedError
      )
    end
  end

  describe "#name" do
    it "raises NotImplementedError" do
      expect { model.name }.to raise_error(NotImplementedError)
    end
  end

  describe "#format_prompt" do
    let(:task_class) do
      Class.new(Lluminary::Task) do
        def task_prompt
          "Test prompt"
        end
      end
    end

    let(:task) { task_class.new }

    context "with simple field types" do
      context "with string field type" do
        before do
          task_class.output_schema do
            string :name, description: "The person's name"
          end
        end

        it "formats string field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # name
            Type: string
            Description: The person's name
            Example: "your name here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with integer field type" do
        before do
          task_class.output_schema do
            integer :age, description: "The person's age"
          end
        end

        it "formats integer field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # age
            Type: integer
            Description: The person's age
            Example: 0
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with boolean field type" do
        before do
          task_class.output_schema do
            boolean :active, description: "Whether the person is active"
          end
        end

        it "formats boolean field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # active
            Type: boolean
            Description: Whether the person is active
            Example: true
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with float field type" do
        before do
          task_class.output_schema do
            float :score, description: "The person's score"
          end
        end

        it "formats float field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # score
            Type: float
            Description: The person's score
            Example: 0.0
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with datetime field type" do
        before do
          task_class.output_schema do
            datetime :created_at, description: "When the person was created"
          end
        end

        it "formats datetime field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # created_at
            Type: datetime in ISO8601 format
            Description: When the person was created
            Example: "2024-01-01T12:00:00+00:00"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end
    end

    context "with array fields" do
      context "with simple array of strings" do
        before do
          task_class.output_schema do
            array :tags, description: "List of tags" do
              string
            end
          end
        end

        it "formats array of strings field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # tags
            Type: array of string
            Description: List of tags
            Example: ["first tag", "second tag", "..."]
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with array of floats" do
        before do
          task_class.output_schema do
            array :scores, description: "List of scores" do
              float
            end
          end
        end

        it "formats array of floats field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # scores
            Type: array of float
            Description: List of scores
            Example: [1.0, 2.0, 3.0]
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with array of datetimes" do
        before do
          task_class.output_schema do
            array :dates, description: "List of important dates" do
              datetime
            end
          end
        end

        it "formats array of datetimes field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # dates
            Type: array of datetime in ISO8601 format
            Description: List of important dates
            Example: ["2024-01-01T12:00:00+00:00", "2024-01-02T12:00:00+00:00"]
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with 2D array (matrix)" do
        before do
          task_class.output_schema do
            array :matrix, description: "2D array of numbers" do
              array { integer }
            end
          end
        end

        it "formats 2D array field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # matrix
            Type: array of array of integer
            Description: 2D array of numbers
            Example: [[1, 2, 3], [1, 2, 3]]
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with 3D array (cube)" do
        before do
          task_class.output_schema do
            array :cube, description: "3D array of strings" do
              array { array { string } }
            end
          end
        end

        it "formats 3D array field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # cube
            Type: array of array of array of string
            Description: 3D array of strings
            Example: [[["first item", "second item", "..."], ["first item", "second item", "..."]], [["first item", "second item", "..."], ["first item", "second item", "..."]]]
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end
    end

    context "with validations" do
      context "presence validation" do
        before do
          task_class.output_schema do
            string :name, description: "The person's name"
            validates :name, presence: true
          end
        end

        it "includes presence validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # name
            Type: string
            Description: The person's name
            Validations: must be present
            Example: "your name here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "inclusion validation" do
        before do
          task_class.output_schema do
            string :status, description: "The status"
            validates :status, inclusion: { in: %w[active inactive] }
          end
        end

        it "includes inclusion validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # status
            Type: string
            Description: The status
            Validations: must be one of: active, inactive
            Example: "your status here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "exclusion validation" do
        before do
          task_class.output_schema do
            string :status, description: "The status"
            validates :status, exclusion: { in: %w[banned blocked] }
          end
        end

        it "includes exclusion validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # status
            Type: string
            Description: The status
            Validations: must not be one of: banned, blocked
            Example: "your status here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "format validation" do
        before do
          task_class.output_schema do
            string :email, description: "Email address"
            validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
          end
        end

        it "includes format validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # email
            Type: string
            Description: Email address
            Validations: must match format: (?-mix:\\A[^@\\s]+@[^@\\s]+\\z)
            Example: "your email here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "length validation" do
        before do
          task_class.output_schema do
            string :password, description: "The password"
            validates :password, length: { minimum: 8, maximum: 20 }
          end
        end

        it "includes length validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # password
            Type: string
            Description: The password
            Validations: must be at least 8 characters, must be at most 20 characters
            Example: "your password here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "numericality validation" do
        before do
          task_class.output_schema do
            integer :age, description: "The age"
            validates :age,
                      numericality: {
                        greater_than: 0,
                        less_than_or_equal_to: 120
                      }
          end
        end

        it "includes numericality validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # age
            Type: integer
            Description: The age
            Validations: must be greater than 0, must be less than or equal to 120
            Example: 0
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "multiple validations" do
        before do
          task_class.output_schema do
            string :username, description: "The username"
            validates :username,
                      presence: true,
                      length: {
                        in: 3..20
                      },
                      format: {
                        with: /\A[a-z0-9_]+\z/
                      }
          end
        end

        it "includes all validations in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # username
            Type: string
            Description: The username
            Validations: must be present, must be between 3 and 20 characters, must match format: (?-mix:\\A[a-z0-9_]+\\z)
            Example: "your username here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end
    end

    context "JSON example generation" do
      context "with simple field types" do
        it "generates correct JSON example for string field" do
          task_class.output_schema do
            string :name, description: "The person's name"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "name": "your name here"
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for integer field" do
          task_class.output_schema do
            integer :age, description: "The person's age"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "age": 0
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for boolean field" do
          task_class.output_schema do
            boolean :is_active, description: "Whether the person is active"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "is_active": true
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for float field" do
          task_class.output_schema { float :score, description: "The score" }

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "score": 0.0
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for datetime field" do
          task_class.output_schema do
            datetime :created_at, description: "When it was created"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "created_at": "2024-01-01T12:00:00+00:00"
            }
          JSON

          expect(prompt).to include(expected_json)
        end
      end

      context "with array fields" do
        it "generates correct JSON example for array of strings" do
          task_class.output_schema do
            array :tags, description: "List of tags" do
              string
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "tags": [
                "first tag",
                "second tag",
                "..."
              ]
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for array of integers" do
          task_class.output_schema do
            array :counts, description: "List of counts" do
              integer
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "counts": [
                1,
                2,
                3
              ]
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for array of datetimes" do
          task_class.output_schema do
            array :timestamps, description: "List of timestamps" do
              datetime
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "timestamps": [
                "2024-01-01T12:00:00+00:00",
                "2024-01-02T12:00:00+00:00"
              ]
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for array without element type" do
          task_class.output_schema do
            array :items, description: "List of items"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "items": []
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for nested array of strings" do
          task_class.output_schema do
            array :groups, description: "Groups of items" do
              array { string }
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "groups": [
                [
                  "first item",
                  "second item",
                  "..."
                ],
                [
                  "first item",
                  "second item",
                  "..."
                ]
              ]
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for three-dimensional array of integers" do
          task_class.output_schema do
            array :matrices, description: "Collection of matrices" do
              array { array { integer } }
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "matrices": [
                [
                  [
                    1,
                    2,
                    3
                  ],
                  [
                    1,
                    2,
                    3
                  ]
                ],
                [
                  [
                    1,
                    2,
                    3
                  ],
                  [
                    1,
                    2,
                    3
                  ]
                ]
              ]
            }
          JSON

          expect(prompt).to include(expected_json)
        end
      end

      context "with multiple fields" do
        it "generates correct JSON example for mixed field types" do
          task_class.output_schema do
            string :name, description: "The person's name"
            integer :age, description: "The person's age"
            array :hobbies, description: "List of hobbies" do
              string
            end
            datetime :joined_at, description: "When they joined"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "name": "your name here",
              "age": 0,
              "hobbies": [
                "first hobby",
                "second hobby",
                "..."
              ],
              "joined_at": "2024-01-01T12:00:00+00:00"
            }
          JSON

          expect(prompt).to include(expected_json)
        end
      end

      context "with hash fields" do
        it "generates correct JSON example for simple hash" do
          task_class.output_schema do
            hash :config do
              string :host
              integer :port
            end
          end

          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # config
            Type: hash with fields:
              host: string
              port: integer
            Example: {
              "host": "your host here",
              "port": 0
            }
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end

        it "generates correct JSON example for nested hash" do
          task_class.output_schema do
            hash :config do
              string :name
              hash :database do
                string :host
                integer :port
              end
            end
          end

          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # config
            Type: hash with fields:
              name: string
              database: hash with fields:
                host: string
                port: integer
            Example: {
              "name": "your name here",
              "database": {
                "host": "your host here",
                "port": 0
              }
            }
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end

        it "generates correct JSON example for hash with array" do
          task_class.output_schema do
            hash :config do
              string :name
              array :tags do
                string
              end
            end
          end

          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # config
            Type: hash with fields:
              name: string
              tags: array of string
            Example: {
              "name": "your name here",
              "tags": [
                "first tag",
                "second tag",
                "..."
              ]
            }
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end

        it "generates correct JSON example for array of hashes" do
          task_class.output_schema do
            array :users do
              hash do
                string :name
                integer :age
              end
            end
          end

          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # users
            Type: array of hash with fields:
              name: string
              age: integer
            Example: {
              "users": [
                {
                  "name": "your name here",
                  "age": 0
                },
                {
                  "name": "your name here",
                  "age": 0
                }
              ]
            }
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end
    end
  end
end
