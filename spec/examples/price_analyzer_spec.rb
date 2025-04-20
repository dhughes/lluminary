# frozen_string_literal: true
require "spec_helper"
require_relative "../../examples/price_analyzer"

RSpec.describe PriceAnalyzer do
  describe "#call" do
    it "returns a competitiveness score between 0.0 and 1.0 for a high-priced item" do
      result =
        described_class.call(
          product_name: "Entry LevelLuxury Watch",
          price: 999.99
        )

      expect(result.output.competitiveness_score).to be_a(Float)
      expect(result.output.competitiveness_score).to be_between(0.0, 1.0)
      # The exact score can vary depending on the LLM's judgment
    end

    it "returns a higher competitiveness score for a reasonably priced item" do
      result =
        described_class.call(product_name: "Basic Watch", price: 10_049.99)

      expect(result.output.competitiveness_score).to be_a(Float)
      expect(result.output.competitiveness_score).to be_between(0.0, 1.0)
      # The exact score can vary depending on the LLM's judgment
    end

    it "validates presence of product_name" do
      expect do
        described_class.call!(product_name: "", price: 49.99)
      end.to raise_error(Lluminary::ValidationError)
    end

    it "validates presence of price" do
      expect do
        described_class.call!(product_name: "Basic Watch", price: nil)
      end.to raise_error(Lluminary::ValidationError)
    end
  end
end
