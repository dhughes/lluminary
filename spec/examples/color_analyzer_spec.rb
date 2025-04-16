# frozen_string_literal: true
require "spec_helper"
require_relative "../../examples/color_analyzer"

RSpec.describe ColorAnalyzer do
  describe "#call" do
    it 'returns "red" for a description strongly suggesting the color red' do
      result = described_class.call(image_description: <<~DESCRIPTION)
              A bright red sports car parked in front of a red brick building at sunset. The car's glossy red paint reflects the warm light, making it appear even more vibrant. A red stop sign stands nearby, and red roses bloom in a garden beside the building.
            DESCRIPTION

      expect(result.output.color_name).to eq("red")
      expect(result.output.valid?).to be true
    end

    it "returns invalid output when description strongly suggests orange" do
      # This should fail validation because "orange" is not a CSS Level 1 color
      result = described_class.call(image_description: <<~DESCRIPTION)
              A field of ripe oranges under a bright orange sunset. The fruit glows with a warm orange hue, and the sky is painted in shades of orange and gold. Orange butterflies flutter among the trees, and orange flowers bloom throughout the scene.
            DESCRIPTION

      expect(result.output.valid?).to be false
      expect(result.output.errors.full_messages).to include(
        "Color name must be a valid CSS level 1 color name"
      )
    end

    it "validates presence of image_description" do
      expect { described_class.call!(image_description: "") }.to raise_error(
        Lluminary::ValidationError
      )
    end

    it "validates that color_name is lowercase" do
      result =
        described_class.call(image_description: "A bright red sports car")

      expect(result.output.valid?).to be true
      expect(result.output.color_name).to eq(result.output.color_name.downcase)
    end
  end
end
