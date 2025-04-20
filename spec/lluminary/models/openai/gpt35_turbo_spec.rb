# frozen_string_literal: true
require "spec_helper"

RSpec.describe Lluminary::Models::OpenAi::Gpt35Turbo do
  subject(:model) { described_class.new }

  describe "#NAME" do
    it "returns the correct model name" do
      expect(described_class::NAME).to eq("gpt-3.5-turbo")
    end
  end

  describe "#compatible_with?" do
    it "returns true for :openai provider" do
      expect(model.compatible_with?(:openai)).to be true
    end

    it "returns false for other providers" do
      expect(model.compatible_with?(:bedrock)).to be false
    end
  end
end
