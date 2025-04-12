require 'spec_helper'

RSpec.describe Luminary::Task do
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
      expect(result.raw_response).to eq('{"summary": "Test response"}')
    end

    it 'string input allows providing a string input' do
      result = task_class.call(message: "hello")
      expect(result.raw_response).to eq('{"summary": "Test response"}')
    end

    it 'string output returns the output in the result' do
      result = task_class.call(message: "hello")
      expect(result.output.summary).to eq("Test response")
    end

    it 'includes schema descriptions in the prompt' do
      result = task_class.call(message: "hello")
      expected_schema = <<~SCHEMA
        You must respond with a valid JSON object with the following fields:

        summary (string): A brief summary of the message
        Example: "your summary here"

        Your response should look like this:
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
        You must respond with a valid JSON object with the following fields:

        summary (string)
        Example: "your summary here"

        Your response should look like this:
        {
          "summary": "your summary here"
        }
      SCHEMA
      expect(result.prompt).to include(expected_schema.chomp)
    end
  end

  describe '.provider' do
    it 'defaults to Test provider' do
      expect(task_class.provider).to be_a(Luminary::Providers::Test)
    end

    it 'allows setting a custom provider' do
      custom_provider = double('CustomProvider')
      task_class.provider = custom_provider
      expect(task_class.provider).to eq(custom_provider)
    end
  end

  describe '.use_provider' do
    it 'with :test provider sets the test provider' do
      expect(task_with_test.provider).to be_a(Luminary::Providers::Test)
    end

    it 'with :openai instantiates OpenAI provider with config' do
      task_class.use_provider(:openai, api_key: 'test')
      expect(task_class.provider).to be_a(Luminary::Providers::OpenAI)
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
        You must respond with a valid JSON object with the following fields:

        summary (string): A brief summary of the message
        Example: "your summary here"

        Your response should look like this:
        {
          "summary": "your summary here"
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
        You must respond with a valid JSON object with the following fields:

        summary (string)
        Example: "your summary here"

        Your response should look like this:
        {
          "summary": "your summary here"
        }
      SCHEMA
      expect(task.send(:json_schema_example)).to eq(expected_output.chomp)
    end
  end
end 