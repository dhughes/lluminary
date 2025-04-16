# frozen_string_literal: true
require "spec_helper"

RSpec.describe Lluminary::Task do
  let(:task_class) do
    Class.new(described_class) do
      input_schema do
        string :message, description: "The text message to process"
      end

      output_schema do
        string :summary, description: "A brief summary of the message"
      end

      private

      def task_prompt
        "Say: #{message}"
      end
    end
  end

  let(:task_with_test) { Class.new(described_class) { use_provider :test } }

  describe ".call" do
    it "returns a result with a raw response from the provider" do
      result = task_class.call(message: "hello")
      expect(result.output.raw_response).to eq(
        '{"summary": "Test string value"}'
      )
    end

    it "string input allows providing a string input" do
      result = task_class.call(message: "hello")
      expect(result.output.raw_response).to eq(
        '{"summary": "Test string value"}'
      )
    end

    it "string output returns the output in the result" do
      result = task_class.call(message: "hello")
      expect(result.output.summary).to eq("Test string value")
    end

    it "includes schema descriptions in the prompt" do
      result = task_class.call(message: "hello")
      expected_schema = <<~SCHEMA
        You must respond with ONLY a valid JSON object. Do not include any other text, explanations, or formatting.
        The JSON object must contain the following fields:

        summary (string): A brief summary of the message
        Example: "your summary here"

        Your response must be ONLY this JSON object:
        {
          "summary": "your summary here"
        }
      SCHEMA
      expect(result.prompt).to include(expected_schema.chomp)
    end
  end

  describe ".call without descriptions" do
    let(:task_without_descriptions) do
      Class.new(described_class) do
        input_schema { string :message }

        output_schema { string :summary }

        private

        def task_prompt
          "Say: #{message}"
        end
      end
    end

    it "includes basic schema in the prompt" do
      result = task_without_descriptions.call(message: "hello")
      expected_schema = <<~SCHEMA
        You must respond with ONLY a valid JSON object. Do not include any other text, explanations, or formatting.
        The JSON object must contain the following fields:

        summary (string)
        Example: "your summary here"

        Your response must be ONLY this JSON object:
        {
          "summary": "your summary here"
        }
      SCHEMA
      expect(result.prompt).to include(expected_schema.chomp)
    end
  end

  describe ".provider" do
    it "defaults to Test provider" do
      expect(task_class.provider).to be_a(Lluminary::Providers::Test)
    end

    it "allows setting a custom provider" do
      custom_provider = double("CustomProvider")
      task_class.provider = custom_provider
      expect(task_class.provider).to eq(custom_provider)
    end
  end

  describe ".use_provider" do
    it "with :test provider sets the test provider" do
      expect(task_with_test.provider).to be_a(Lluminary::Providers::Test)
    end

    it "with :openai instantiates OpenAI provider with config" do
      task_class.use_provider(:openai, api_key: "test")
      expect(task_class.provider).to be_a(Lluminary::Providers::OpenAI)
      expect(task_class.provider.config).to eq(api_key: "test", model: "gpt-4o")
    end

    it "raises ArgumentError for unknown provider" do
      expect { task_class.use_provider(:unknown) }.to raise_error(
        ArgumentError,
        "Unknown provider: unknown"
      )
    end
  end

  describe "#json_schema_example" do
    it "generates a schema example with descriptions" do
      task = task_class.new(message: "test")
      expected_output = <<~SCHEMA
        You must respond with ONLY a valid JSON object. Do not include any other text, explanations, or formatting.
        The JSON object must contain the following fields:

        summary (string): A brief summary of the message
        Example: "your summary here"

        Your response must be ONLY this JSON object:
        {
          "summary": "your summary here"
        }
      SCHEMA
      expect(task.send(:json_schema_example)).to eq(expected_output.chomp)
    end

    it "generates a schema example with datetime field" do
      task_with_datetime =
        Class.new(described_class) do
          input_schema { string :message }

          output_schema do
            datetime :start_time, description: "When the event starts"
          end

          private

          def task_prompt
            "Say: #{message}"
          end
        end

      task = task_with_datetime.new(message: "test")
      expected_output = <<~SCHEMA
        You must respond with ONLY a valid JSON object. Do not include any other text, explanations, or formatting.
        The JSON object must contain the following fields:

        start_time (datetime in ISO8601 format): When the event starts
        Example: "2024-01-01T12:00:00+00:00"

        Your response must be ONLY this JSON object:
        {
          "start_time": "2024-01-01T12:00:00+00:00"
        }
      SCHEMA
      expect(task.send(:json_schema_example)).to eq(expected_output.chomp)
    end

    it "generates a schema example with boolean field" do
      task_with_boolean =
        Class.new(described_class) do
          input_schema { string :message }

          output_schema do
            boolean :is_valid, description: "Whether the input is valid"
          end

          private

          def task_prompt
            "Say: #{message}"
          end
        end

      task = task_with_boolean.new(message: "test")
      expected_output = <<~SCHEMA
        You must respond with ONLY a valid JSON object. Do not include any other text, explanations, or formatting.
        The JSON object must contain the following fields:

        is_valid (boolean): Whether the input is valid
        Example: true

        Your response must be ONLY this JSON object:
        {
          "is_valid": true
        }
      SCHEMA
      expect(task.send(:json_schema_example)).to eq(expected_output.chomp)
    end

    it "generates a schema example with float field" do
      task_with_float =
        Class.new(described_class) do
          input_schema { string :message }

          output_schema { float :score, description: "The confidence score" }

          private

          def task_prompt
            "Say: #{message}"
          end
        end

      task = task_with_float.new(message: "test")
      expected_output = <<~SCHEMA
        You must respond with ONLY a valid JSON object. Do not include any other text, explanations, or formatting.
        The JSON object must contain the following fields:

        score (float): The confidence score
        Example: 0.0

        Your response must be ONLY this JSON object:
        {
          "score": 0.0
        }
      SCHEMA
      expect(task.send(:json_schema_example)).to eq(expected_output.chomp)
    end

    it "generates a schema example without descriptions" do
      task_without_descriptions =
        Class.new(described_class) do
          input_schema { string :message }

          output_schema { string :summary }

          private

          def task_prompt
            "Say: #{message}"
          end
        end

      task = task_without_descriptions.new(message: "test")
      expected_output = <<~SCHEMA
        You must respond with ONLY a valid JSON object. Do not include any other text, explanations, or formatting.
        The JSON object must contain the following fields:

        summary (string)
        Example: "your summary here"

        Your response must be ONLY this JSON object:
        {
          "summary": "your summary here"
        }
      SCHEMA
      expect(task.send(:json_schema_example)).to eq(expected_output.chomp)
    end

    context "validation descriptions" do
      context "presence validation" do
        it "includes presence validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                string :name, description: "The person's name"
                validates :name, presence: true
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "name (string): The person's name\nValidation: must be present\nExample: \"your name here\""
          )
        end
      end

      context "length validation" do
        it "includes minimum length validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                string :name, description: "The person's name"
                validates :name, length: { minimum: 2 }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "name (string): The person's name\nValidation: must be at least 2 characters\nExample: \"your name here\""
          )
        end

        it "includes maximum length validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                string :name, description: "The person's name"
                validates :name, length: { maximum: 20 }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "name (string): The person's name\nValidation: must be at most 20 characters\nExample: \"your name here\""
          )
        end

        it "includes range length validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                string :password, description: "The password"
                validates :password, length: { in: 8..20 }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "password (string): The password\nValidation: must be between 8 and 20 characters\nExample: \"your password here\""
          )
        end

        it "includes multiple length validations in description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                string :username, description: "The username"
                validates :username, length: { minimum: 3, maximum: 20 }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "username (string): The username\nValidation: must be at least 3 characters, must be at most 20 characters\nExample: \"your username here\""
          )
        end
      end

      context "numericality validation" do
        it "includes odd validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                integer :number, description: "Odd number"
                validates :number, numericality: { odd: true }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "number (integer): Odd number\nValidation: must be odd\nExample: 0"
          )
        end

        it "includes equal to validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                integer :level, description: "Level"
                validates :level, numericality: { equal_to: 5 }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "level (integer): Level\nValidation: must be equal to 5\nExample: 0"
          )
        end

        it "includes less than or equal to validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                integer :score, description: "Score"
                validates :score, numericality: { less_than_or_equal_to: 100 }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "score (integer): Score\nValidation: must be less than or equal to 100\nExample: 0"
          )
        end

        it "includes other than validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                integer :value, description: "Value"
                validates :value, numericality: { other_than: 0 }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "value (integer): Value\nValidation: must be other than 0\nExample: 0"
          )
        end

        it "includes in range validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                integer :rating, description: "Rating"
                validates :rating, numericality: { in: 1..5 }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "rating (integer): Rating\nValidation: must be in: 1, 2, 3, 4, 5\nExample: 0"
          )
        end

        it "includes multiple numericality validations in description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                integer :score, description: "Score"
                validates :score,
                          numericality: {
                            greater_than: 0,
                            less_than_or_equal_to: 100
                          }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "score (integer): Score\nValidation: must be greater than 0, must be less than or equal to 100\nExample: 0"
          )
        end

        it "includes multiple comparison validations in description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                integer :age, description: "Age"
                validates :age, comparison: { greater_than: 0, less_than: 120 }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "age (integer): Age\nValidation: must be greater than 0, must be less than 120\nExample: 0"
          )
        end
      end

      context "format validation" do
        it "includes format validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                string :email, description: "Email address"
                validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "email (string): Email address\nValidation: must match format: (?-mix:\\A[^@\\s]+@[^@\\s]+\\z)\nExample: \"your email here\""
          )
        end
      end

      context "inclusion validation" do
        it "includes inclusion validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                string :role, description: "User role"
                validates :role, inclusion: { in: %w[admin user guest] }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "role (string): User role\nValidation: must be one of: admin, user, guest\nExample: \"your role here\""
          )
        end
      end

      context "exclusion validation" do
        it "includes exclusion validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                string :status, description: "Status"
                validates :status, exclusion: { in: %w[banned blocked] }
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "status (string): Status\nValidation: must not be one of: banned, blocked\nExample: \"your status here\""
          )
        end
      end

      context "absence validation" do
        it "includes absence validation description" do
          task_class =
            Class.new(described_class) do
              output_schema do
                string :deleted_at, description: "Deletion timestamp"
                validates :deleted_at, absence: true
              end

              private

              def task_prompt = "Test prompt"
            end

          task = task_class.new
          expect(task.send(:json_schema_example)).to include(
            "deleted_at (string): Deletion timestamp\nValidation: must be absent\nExample: \"your deleted_at here\""
          )
        end
      end
    end
  end

  describe "#validate_input" do
    let(:task_with_types) do
      Class.new(described_class) do
        input_schema do
          string :name
          integer :age
          datetime :start_time
        end

        private

        def task_prompt
          "Test prompt"
        end
      end
    end

    it "validates string input type" do
      task =
        task_with_types.new(name: "John", age: 30, start_time: DateTime.now)
      expect { task.send(:validate_input) }.not_to raise_error
    end

    it "raises error for invalid string input" do
      task = task_with_types.new(name: 123, age: 30, start_time: DateTime.now)
      expect { task.send(:validate_input) }.to raise_error(
        Lluminary::ValidationError,
        "Name must be a String"
      )
    end

    it "validates integer input type" do
      task =
        task_with_types.new(name: "John", age: 30, start_time: DateTime.now)
      expect { task.send(:validate_input) }.not_to raise_error
    end

    it "raises error for invalid integer input" do
      task =
        task_with_types.new(name: "John", age: "30", start_time: DateTime.now)
      expect { task.send(:validate_input) }.to raise_error(
        Lluminary::ValidationError,
        "Age must be an Integer"
      )
    end

    it "validates datetime input type" do
      task =
        task_with_types.new(name: "John", age: 30, start_time: DateTime.now)
      expect { task.send(:validate_input) }.not_to raise_error
    end

    it "raises error for invalid datetime input" do
      task =
        task_with_types.new(name: "John", age: 30, start_time: "2024-01-01")
      expect { task.send(:validate_input) }.to raise_error(
        Lluminary::ValidationError,
        "Start time must be a DateTime"
      )
    end
  end

  describe "SchemaModel integration" do
    let(:task_with_schema) do
      Class.new(described_class) do
        input_schema do
          string :text
          integer :min_length

          validates :text, presence: true
          validates :min_length,
                    presence: true,
                    numericality: {
                      greater_than: 0
                    }
        end

        output_schema do
          string :longest_word
          integer :word_count
        end

        private

        def task_prompt
          "Test prompt"
        end
      end
    end

    it "wraps input in a SchemaModel instance" do
      result = task_with_schema.call(text: "hello", min_length: 3)
      expect(result.input).to be_a(Lluminary::SchemaModel)
      expect(result.input.text).to eq("hello")
      expect(result.input.min_length).to eq(3)
    end

    it "validates input using SchemaModel" do
      result = task_with_schema.call(text: "hello", min_length: 3)
      expect(result.input.valid?).to be true
      expect(result.input.errors).to be_empty
    end

    it "returns validation errors for invalid input" do
      result = task_with_schema.call(text: nil, min_length: nil)
      expect(result.input.valid?).to be false
      expect(result.input.errors.full_messages).to contain_exactly(
        "Text can't be blank",
        "Min length can't be blank",
        "Min length is not a number"
      )
    end

    it "does not execute task when input is invalid" do
      result = task_with_schema.call(text: nil, min_length: nil)
      expect(result.parsed_response).to be_nil
      expect(result.output).to be_nil
    end

    it "raises ValidationError for invalid input when using call!" do
      expect do
        task_with_schema.call!(text: nil, min_length: nil)
      end.to raise_error(
        Lluminary::ValidationError,
        "Text can't be blank, Min length can't be blank, Min length is not a number"
      )
    end

    it "validates that the response is valid JSON" do
      task = task_with_schema.new(text: "hello", min_length: 3)
      allow(task.class.provider).to receive(:call).and_return(
        { raw: "not valid json at all", parsed: nil }
      )

      result = task.call
      expect(result.input.valid?).to be true
      expect(result.output.valid?).to be false
      expect(result.output.errors.full_messages).to include(
        "Raw response must be valid JSON"
      )
    end
  end

  describe "tasks without inputs" do
    let(:quote_task) do
      Class.new(described_class) do
        use_provider :test

        output_schema do
          string :quote, description: "An inspirational quote"
          string :author, description: "The person who said the quote"
        end

        private

        def task_prompt
          "Generate an inspirational quote and its author"
        end
      end
    end

    it "can be called without any input parameters" do
      result = quote_task.call
      expect(result.output.quote).to be_a(String)
      expect(result.output.author).to be_a(String)
    end

    it "returns a valid result object" do
      result = quote_task.call
      expect(result).to be_a(Lluminary::Task)
      expect(result.input).to be_a(Lluminary::SchemaModel)
      expect(result.input.valid?).to be true
    end
  end

  describe "datetime handling" do
    let(:task_with_datetime) do
      Class.new(described_class) do
        use_provider :test

        output_schema do
          datetime :event_time, description: "When the event occurred"
        end

        private

        def task_prompt
          "Test prompt"
        end
      end
    end

    it "converts ISO8601 datetime strings to DateTime objects" do
      task = task_with_datetime.new
      allow(task.class.provider).to receive(:call).and_return(
        {
          raw: '{"event_time": "2024-01-01T12:00:00+00:00"}',
          parsed: {
            "event_time" => "2024-01-01T12:00:00+00:00"
          }
        }
      )

      result = task.call
      expect(result.output.valid?).to be true
      expect(result.output.event_time).to be_a(DateTime)
      expect(result.output.event_time.year).to eq(2024)
      expect(result.output.event_time.month).to eq(1)
      expect(result.output.event_time.day).to eq(1)
      expect(result.output.event_time.hour).to eq(12)
      expect(result.output.event_time.minute).to eq(0)
      expect(result.output.event_time.second).to eq(0)
    end

    it "handles invalid datetime strings" do
      task = task_with_datetime.new
      allow(task.class.provider).to receive(:call).and_return(
        {
          raw: '{"event_time": "not a valid datetime"}',
          parsed: {
            "event_time" => "not a valid datetime"
          }
        }
      )

      result = task.call
      expect(result.output.valid?).to be false
      expect(result.output.errors.full_messages).to include(
        "Event time must be a DateTime"
      )
    end
  end
end
