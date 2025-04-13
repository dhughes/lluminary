require 'spec_helper'
require_relative '../../examples/content_analyzer'

RSpec.describe ContentAnalyzer do
  let(:technical_text) do
    <<~TEXT
      The revolutionary new quantum processor leverages advanced photonic circuits to achieve unprecedented computational speeds. 
      By utilizing entangled photon pairs, it can perform complex calculations in parallel, significantly reducing processing time.
      This breakthrough technology represents a major advancement in quantum computing.
    TEXT
  end

  let(:emotional_text) do
    <<~TEXT
      I can't believe how amazing this experience was! My heart was racing with excitement as I watched the performance. 
      The raw emotion and passion in every movement brought tears to my eyes. It was truly a transformative moment that I'll never forget.
    TEXT
  end

  describe '#call' do
    it 'correctly identifies technical content' do
      result = described_class.call(
        text: technical_text,
        content_type: "technical"
      )

      expect(result.output.contains_type).to be true
    end

    it 'correctly identifies non-technical content' do
      result = described_class.call(
        text: emotional_text,
        content_type: "technical"
      )

      expect(result.output.contains_type).to be false
    end

    it 'correctly identifies emotional content' do
      result = described_class.call(
        text: emotional_text,
        content_type: "emotional"
      )

      expect(result.output.contains_type).to be true
    end

    it 'correctly identifies non-emotional content' do
      result = described_class.call(
        text: technical_text,
        content_type: "emotional"
      )

      expect(result.output.contains_type).to be false
    end

    it 'validates presence of text' do
      expect {
        described_class.call!(
          text: "",
          content_type: "technical"
        )
      }.to raise_error(Lluminary::ValidationError)
    end

    it 'validates presence of content_type' do
      expect {
        described_class.call!(
          text: technical_text,
          content_type: ""
        )
      }.to raise_error(Lluminary::ValidationError)
    end
  end
end 