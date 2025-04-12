require 'spec_helper'
require_relative '../../examples/sentiment_analysis'

RSpec.describe SentimentAnalysis do
  let(:text) { "I absolutely love this new feature!" }

  describe '.call' do
    it 'analyzes sentiment of given text' do
      result = described_class.call(text: text)
      
      expect(result.output.sentiment).to be_a(String)
      expect(result.output.sentiment).not_to be_empty
      expect(result.output.explanation).to be_a(String)
      expect(result.output.explanation).not_to be_empty
      expect(result.output.confidence).to be_a(Integer)
      expect(result.output.confidence).to be_between(0, 100)
    end

    it 'returns valid JSON response' do
      result = described_class.call(text: text)
      expect(result.output.raw_response).to be_a(String)
      expect { JSON.parse(result.output.raw_response) }.not_to raise_error
      json = JSON.parse(result.output.raw_response)
      expect(json).to have_key("sentiment")
      expect(json).to have_key("explanation")
      expect(json).to have_key("confidence")
      expect(json["sentiment"]).to eq(result.output.sentiment)
      expect(json["explanation"]).to eq(result.output.explanation)
      expect(json["confidence"]).to eq(result.output.confidence)
    end

    it 'requires text input' do
      result = described_class.call({})
      expect(result.valid?).to be false
      expect(result.input.errors.full_messages).to include("Text can't be blank")
    end

    it 'returns a valid result object' do
      result = described_class.call(text: text)
      expect(result).to be_a(Lluminary::Task)
      expect(result.input).to be_a(Lluminary::SchemaModel)
      expect(result.input.valid?).to be true
    end
  end
end 