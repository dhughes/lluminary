# frozen_string_literal: true
require "spec_helper"
require_relative "../../examples/meal_suggester"

RSpec.describe MealSuggester do
  let(:valid_ingredients) { %w[eggs bread butter] }
  let(:valid_count) { 3 }
  let(:valid_params) do
    { ingredients: valid_ingredients, suggestions_count: valid_count }
  end

  describe "input validation" do
    it "accepts valid parameters" do
      expect { described_class.call!(**valid_params) }.not_to raise_error
    end

    it "requires ingredients to be present" do
      expect do
        described_class.call!(ingredients: [], suggestions_count: valid_count)
      end.to raise_error(Lluminary::ValidationError)
    end

    it "requires suggestions_count to be present" do
      expect do
        described_class.call!(
          ingredients: valid_ingredients,
          suggestions_count: nil
        )
      end.to raise_error(Lluminary::ValidationError)
    end
  end

  describe "output validation" do
    let(:result) { described_class.call(**valid_params) }

    it "returns an array of meal suggestions" do
      expect(result.output.meal_suggestions).to be_an(Array)
    end

    it "returns the requested number of suggestions" do
      expect(result.output.meal_suggestions.length).to eq(valid_count)
    end

    it "returns string suggestions" do
      expect(result.output.meal_suggestions).to all(be_a(String))
    end

    it "returns non-empty suggestions" do
      expect(result.output.meal_suggestions).to all(be_present)
    end
  end

  describe "prompt generation" do
    let(:result) { described_class.call(**valid_params) }

    it "includes the ingredients in the prompt" do
      expect(result.prompt).to include(valid_ingredients.inspect)
    end

    it "includes the suggestions count in the prompt" do
      expect(result.prompt).to include(valid_count.to_s)
    end
  end
end
