require 'luminary'

RSpec.describe Luminary::Providers::Base do
  describe '#call' do
    it 'raises NotImplementedError' do
      expect { described_class.new.call(prompt: 'test') }.to raise_error(NotImplementedError)
    end
  end
end 