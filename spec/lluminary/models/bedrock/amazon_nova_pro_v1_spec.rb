# frozen_string_literal: true

require "spec_helper"
require "lluminary/models/bedrock/amazon_nova_pro_v1"

RSpec.describe Lluminary::Models::Bedrock::AmazonNovaProV1 do
  let(:model) { described_class.new }

  describe "NAME" do
    it "has the correct model name" do
      expect(described_class::NAME).to eq("amazon.nova-pro-v1")
    end
  end

  describe "#compatible_with?" do
    it "returns true for bedrock provider" do
      expect(model.compatible_with?(:bedrock)).to be true
    end

    it "returns false for other providers" do
      expect(model.compatible_with?(:openai)).to be false
    end
  end

  describe "#name" do
    it "returns the model name" do
      expect(model.name).to eq("amazon.nova-pro-v1:0")
    end
  end
end
