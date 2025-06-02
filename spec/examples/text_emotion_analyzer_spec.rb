# frozen_string_literal: true
require "spec_helper"
require_relative "../../examples/text_emotion_analyzer"

RSpec.describe TextEmotionAnalyzer do
  let(:sample_text) { <<~TEXT }
      The sun was setting behind the mountains, casting long shadows across the valley. 
      Sarah felt a mix of emotions as she watched the last rays of light disappear. 
      There was a deep sense of peace, but also a tinge of sadness knowing this beautiful moment would soon be gone. 
      She smiled through her tears, grateful for the experience yet longing for it to last just a little longer.
    TEXT

  describe "input validation" do
    it "accepts valid text input" do
      expect { described_class.call!(text: sample_text) }.not_to raise_error
    end

    it "requires text to be present" do
      expect { described_class.call!(text: "") }.to raise_error(
        Lluminary::ValidationError
      )
    end
  end

  describe "output validation" do
    let(:result) { described_class.call(text: sample_text) }

    it "returns a dictionary of emotion scores" do
      expect(result.output.emotion_scores).to be_a(Hash)
      expect(result.output.emotion_scores).not_to be_empty
    end

    it "returns float scores between 0.0 and 1.0" do
      result.output.emotion_scores.each do |emotion, score|
        expect(score).to be_a(Float)
        expect(score).to be_between(0.0, 1.0)
      end
    end

    it "returns a dominant emotion" do
      expect(result.output.dominant_emotion).to be_a(String)
      expect(result.output.dominant_emotion).not_to be_empty
    end

    it "returns an analysis" do
      expect(result.output.analysis).to be_a(String)
      expect(result.output.analysis).not_to be_empty
    end

    it "returns valid JSON response" do
      expect(result.output.raw_response).to be_a(String)
      expect { JSON.parse(result.output.raw_response) }.not_to raise_error
      json = JSON.parse(result.output.raw_response)
      expect(json).to have_key("emotion_scores")
      expect(json).to have_key("dominant_emotion")
      expect(json).to have_key("analysis")
    end
  end

  describe "emotion detection" do
    it "detects multiple emotions in complex text" do
      result = described_class.call(text: sample_text)
      expect(result.output.emotion_scores.size).to be >= 2
    end

    it "identifies the highest scoring emotion as dominant" do
      result = described_class.call(text: sample_text)
      dominant_score =
        result.output.emotion_scores[result.output.dominant_emotion]
      result.output.emotion_scores.each do |emotion, score|
        expect(score).to be <= dominant_score
      end
    end
  end
end
