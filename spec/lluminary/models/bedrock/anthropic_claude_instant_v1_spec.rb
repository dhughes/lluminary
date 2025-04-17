require "spec_helper"

RSpec.describe Lluminary::Models::Bedrock::AnthropicClaudeInstantV1 do
  subject(:model) { described_class.new }

  describe "#compatible_with?" do
    it "returns true for :bedrock provider" do
      expect(model.compatible_with?(:bedrock)).to be true
    end

    it "returns false for other providers" do
      expect(model.compatible_with?(:openai)).to be false
    end
  end
end
