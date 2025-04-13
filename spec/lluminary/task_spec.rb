require 'spec_helper'

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

  let(:task_with_test) do
    Class.new(described_class) do
      use_provider :test
    end
  end

  describe '.call' do
    it 'returns a result with a raw response from the provider' do
      result = task_class.call(message: "hello")
      expect(result.output.raw_response).to eq('{"summary": "Test string value"}')
    end

    it 'string input allows providing a string input' do
      result = task_class.call(message: "hello")
      expect(result.output.raw_response).to eq('{"summary": "Test string value"}')
    end

    it 'string output returns the output in the result' do
      result = task_class.call(message: "hello")
      expect(result.output.summary).to eq("Test string value")
    end

    it 'includes schema descriptions in the prompt' do
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

  describe '.call without descriptions' do
    let(:task_without_descriptions) do
      Class.new(described_class) do
        input_schema do
          string :message
        end

        output_schema do
          string :summary
        end

        private

        def task_prompt
          "Say: #{message}"
        end
      end
    end

    it 'includes basic schema in the prompt' do
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

  describe '.provider' do
    it 'defaults to Test provider' do
      expect(task_class.provider).to be_a(Lluminary::Providers::Test)
    end

    it 'allows setting a custom provider' do
      custom_provider = double('CustomProvider')
      task_class.provider = custom_provider
      expect(task_class.provider).to eq(custom_provider)
    end
  end

  describe '.use_provider' do
    it 'with :test provider sets the test provider' do
      expect(task_with_test.provider).to be_a(Lluminary::Providers::Test)
    end

    it 'with :openai instantiates OpenAI provider with config' do
      task_class.use_provider(:openai, api_key: 'test')
      expect(task_class.provider).to be_a(Lluminary::Providers::OpenAI)
      expect(task_class.provider.config).to eq(api_key: 'test')
    end

    it 'raises ArgumentError for unknown provider' do
      expect {
        task_class.use_provider(:unknown)
      }.to raise_error(ArgumentError, "Unknown provider: unknown")
    end
  end

  describe '#json_schema_example' do
    it 'generates a schema example with descriptions' do
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

    it 'generates a schema example with datetime field' do
      task_with_datetime = Class.new(described_class) do
        input_schema do
          string :message
        end

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

        start_time (datetime): When the event starts
        Example: "2024-01-01T12:00:00+00:00"

        Your response must be ONLY this JSON object:
        {
          "start_time": "2024-01-01T12:00:00+00:00"
        }
      SCHEMA
      expect(task.send(:json_schema_example)).to eq(expected_output.chomp)
    end

    it 'generates a schema example without descriptions' do
      task_without_descriptions = Class.new(described_class) do
        input_schema do
          string :message
        end

        output_schema do
          string :summary
        end

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
  end

  describe '#validate_input' do
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

    it 'validates string input type' do
      task = task_with_types.new(name: "John", age: 30, start_time: DateTime.now)
      expect { task.send(:validate_input) }.not_to raise_error
    end

    it 'raises error for invalid string input' do
      task = task_with_types.new(name: 123, age: 30, start_time: DateTime.now)
      expect { task.send(:validate_input) }.to raise_error(Lluminary::ValidationError, "Name must be a String")
    end

    it 'validates integer input type' do
      task = task_with_types.new(name: "John", age: 30, start_time: DateTime.now)
      expect { task.send(:validate_input) }.not_to raise_error
    end

    it 'raises error for invalid integer input' do
      task = task_with_types.new(name: "John", age: "30", start_time: DateTime.now)
      expect { task.send(:validate_input) }.to raise_error(Lluminary::ValidationError, "Age must be an Integer")
    end

    it 'validates datetime input type' do
      task = task_with_types.new(name: "John", age: 30, start_time: DateTime.now)
      expect { task.send(:validate_input) }.not_to raise_error
    end

    it 'raises error for invalid datetime input' do
      task = task_with_types.new(name: "John", age: 30, start_time: "2024-01-01")
      expect { task.send(:validate_input) }.to raise_error(Lluminary::ValidationError, "Start time must be a DateTime")
    end
  end

  describe 'SchemaModel integration' do
    let(:task_with_schema) do
      Class.new(described_class) do
        input_schema do
          string :text
          integer :min_length

          validates :text, presence: true
          validates :min_length, presence: true, numericality: { greater_than: 0 }
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

    it 'wraps input in a SchemaModel instance' do
      result = task_with_schema.call(text: "hello", min_length: 3)
      expect(result.input).to be_a(Lluminary::SchemaModel)
      expect(result.input.text).to eq("hello")
      expect(result.input.min_length).to eq(3)
    end

    it 'validates input using SchemaModel' do
      result = task_with_schema.call(text: "hello", min_length: 3)
      expect(result.input.valid?).to be true
      expect(result.input.errors).to be_empty
    end

    it 'returns validation errors for invalid input' do
      result = task_with_schema.call(text: nil, min_length: nil)
      expect(result.input.valid?).to be false
      expect(result.input.errors.full_messages).to contain_exactly(
        "Text can't be blank",
        "Min length can't be blank",
        "Min length is not a number"
      )
    end

    it 'does not execute task when input is invalid' do
      result = task_with_schema.call(text: nil, min_length: nil)
      expect(result.parsed_response).to be_nil
      expect(result.output).to be_nil
    end

    it 'raises ValidationError for invalid input when using call!' do
      expect {
        task_with_schema.call!(text: nil, min_length: nil)
      }.to raise_error(Lluminary::ValidationError, "Text can't be blank, Min length can't be blank, Min length is not a number")
    end

    it 'validates that the response is valid JSON' do
      task = task_with_schema.new(text: "hello", min_length: 3)
      allow(task.class.provider).to receive(:call).and_return({
        raw: "not valid json at all",
        parsed: nil
      })

      result = task.call
      expect(result.input.valid?).to be true
      expect(result.output.valid?).to be false
      expect(result.output.errors.full_messages).to include("Raw response must be valid JSON")
    end
  end

  describe 'tasks without inputs' do
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

    it 'can be called without any input parameters' do
      result = quote_task.call
      expect(result.output.quote).to be_a(String)
      expect(result.output.author).to be_a(String)
    end

    it 'returns a valid result object' do
      result = quote_task.call
      expect(result).to be_a(Lluminary::Task)
      expect(result.input).to be_a(Lluminary::SchemaModel)
      expect(result.input.valid?).to be true
    end
  end
end 