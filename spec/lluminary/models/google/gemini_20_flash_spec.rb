# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lluminary::Models::Google::Gemini20Flash do
  subject(:model) { described_class.new }

  describe "#NAME" do
    it "has the correct model name" do
      expect(described_class::NAME).to eq("gemini-2.0-flash")
    end
  end

  describe "#compatible_with?" do
    it "returns true for google provider" do
      expect(model.compatible_with?(:google)).to be true
    end

    it "returns false for other providers" do
      expect(model.compatible_with?(:openai)).to be false
      expect(model.compatible_with?(:bedrock)).to be false
      expect(model.compatible_with?(:anthropic)).to be false
    end
  end

  describe "#name" do
    it "returns the model name" do
      expect(model.name).to eq("gemini-2.0-flash")
    end
  end
end
