# frozen_string_literal: true
require_relative "config"

# This example was created to show that output validation works correctly. The prompt is intentionally vague to show that the output validator
# will not allow any options other than the original 16 CSS Level 1 colors. (Orange, OrangeRed, etc) are not allowed.
class ColorAnalyzer < Lluminary::Task
  use_provider :bedrock

  # List of valid CSS color names
  CSS_LEVEL1_COLOR_NAMES = %w[
    aqua
    black
    blue
    fuchsia
    gray
    green
    lime
    maroon
    navy
    olive
    purple
    red
    silver
    teal
    white
    yellow
  ].freeze

  input_schema do
    string :image_description,
           description:
             "A description of an image or scene to analyze for its dominant CSS level 1 color"

    validates :image_description, presence: true
  end

  output_schema do
    string :color_name,
           description:
             "The lower case CSS level 1 color name that best matches the described image. Originally CSS Level 1 only supported 16 colors, but modern CSS supports many more. We only want one of the 16 original ones."

    validates :color_name, presence: true
    validates :color_name,
              inclusion: {
                in: CSS_LEVEL1_COLOR_NAMES,
                message: "must be a valid CSS level 1 color name"
              }
    validates :color_name,
              format: {
                with: /\A[a-z]+\z/,
                message: "must be in lowercase"
              }
  end

  private

  def task_prompt
    <<~PROMPT
      Analyze the following image description and determine the CSS level 1 color name that best matches the dominant or most significant color in the scene.
      
      Description: #{image_description}
    PROMPT
  end
end

# Example usage
if __FILE__ == $PROGRAM_NAME
  puts "#> Running ColorAnalyzer example"

  result =
    ColorAnalyzer.call(
      image_description:
        "A breathtaking sunset over the ocean. The sky is painted with vibrant reds, oranges, and pinks, fading into deep purples near the horizon. Clouds catch the light and appear to be on fire. The ocean reflects these warm hues, creating a shimmering path of light across the water. Small waves catch the last rays of sunlight, creating sparkling highlights. The scene is framed by silhouettes of distant palm trees against the colorful sky and azure ocean."
    )

  puts "##> Input"
  puts result.input
  puts result.input.valid?

  puts "##> Output"
  puts result.output
  puts result.output.valid?
  puts result.output.errors.full_messages
end
