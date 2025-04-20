require "spec_helper"

RSpec.describe Lluminary::Models::Bedrock::AnthropicClaudeInstantV1 do
  subject(:model) { described_class.new }

  describe "#NAME" do
    it "returns the correct model name" do
      expect(described_class::NAME).to eq("anthropic.claude-instant-v1")
    end
  end

  describe "#compatible_with?" do
    it "returns true for :bedrock provider" do
      expect(model.compatible_with?(:bedrock)).to be true
    end

    it "returns false for other providers" do
      expect(model.compatible_with?(:openai)).to be false
    end
  end
end
