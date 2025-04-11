require 'luminary'

RSpec.describe Luminary::Task do
  let(:task_class) do
    Class.new(described_class) do
      input_schema do
        string :text
      end

      output_schema do
        string :summary
      end

      def prompt
        "Say: #{text}"
      end
    end
  end

  describe '.call' do
    it 'returns a result with a raw response from the provider' do
      result = task_class.call(text: "hello")
      expect(result.raw_response).to eq("Test response to: Say: hello")
      expect(result.output.summary).to eq("Test response to: Say: hello")
    end
  end

  describe 'string input' do
    it 'allows providing a string input' do
      result = task_class.call(text: "hello")
      expect(result.raw_response).to eq("Test response to: Say: hello")
      expect(result.output.summary).to eq("Test response to: Say: hello")
    end

    it 'makes the input available in the prompt' do
      task = task_class.new(text: "hello")
      expect(task.prompt).to eq("Say: hello")
    end
  end

  describe 'string output' do
    it 'returns the output in the result' do
      result = task_class.call(text: "hello")
      expect(result.output.summary).to eq("Test response to: Say: hello")
    end
  end

  describe '.provider' do
    it 'defaults to TestProvider' do
      expect(task_class.provider).to be_a(Luminary::Providers::TestProvider)
    end

    it 'allows setting a custom provider' do
      custom_provider = double('CustomProvider')
      task_class.provider = custom_provider
      expect(task_class.provider).to eq(custom_provider)
    end
  end

  describe '.use_provider' do
    context 'with :test provider' do
      let(:task_with_test) do
        Class.new(described_class) do
          use_provider :test
        end
      end

      it 'sets the test provider' do
        expect(task_with_test.provider).to be_a(Luminary::Providers::TestProvider)
      end
    end

    context 'with a custom provider class' do
      let(:custom_provider_class) do
        Class.new(Luminary::Providers::Base)
      end

      let(:task_with_custom) do
        provider_class = custom_provider_class
        Class.new(described_class) do
          use_provider provider_class, api_key: 'test-key'
        end
      end

      it 'instantiates the provider with config' do
        expect(task_with_custom.provider).to be_a(custom_provider_class)
      end
    end
  end
end 