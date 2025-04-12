require 'spec_helper'
require_relative '../../examples/sentiment_analysis'

RSpec.describe SentimentAnalysis do
  before do
    described_class.use_provider(:bedrock, test_mode: true)
  end

  describe '#call' do
    it 'analyzes sentiment of given text' do
      result = described_class.call(text: "I absolutely love this new feature!")
      
      expect(result.output.sentiment).to eq('positive')
      expect(result.output.explanation).to be_a(String)
      expect(result.output.confidence).to be_between(0, 100)
    end

    it 'requires text input' do
      result = described_class.call({})
      expect(result.valid?).to be false
    end
  end
end 