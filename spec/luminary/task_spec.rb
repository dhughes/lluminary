require 'spec_helper'

RSpec.describe Luminary::Task do
  let(:task_class) do
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
end 