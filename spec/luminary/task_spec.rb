require 'luminary'

RSpec.describe Luminary::Task do
  let(:task_class) do
    Class.new(described_class) do
      def prompt
        "Say hello world"
      end
    end
  end

  describe '.call' do
    it 'returns a result with a raw response' do
      result = task_class.call
      expect(result.raw_response).to eq("hello world")
    end
  end
end 