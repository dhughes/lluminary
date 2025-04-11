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
    it 'returns a result with a raw response' do
      result = task_class.call
      expect(result.raw_response).to eq("hello world")
      expect(result.output.summary).to eq("hello world")
    end
  end

  describe 'string input' do
    it 'allows providing a string input' do
      result = task_class.call(text: "hello")
      expect(result.raw_response).to eq("hello world")
      expect(result.output.summary).to eq("hello world")
    end

    it 'makes the input available in the prompt' do
      task = task_class.new(text: "hello")
      expect(task.prompt).to eq("Say: hello")
    end
  end

  describe 'string output' do
    it 'returns the output in the result' do
      result = task_class.call(text: "hello")
      expect(result.output.summary).to eq("hello world")
    end
  end
end 