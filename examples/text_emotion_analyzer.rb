# frozen_string_literal: true
require_relative "config"

# Analyzes text to detect and score various emotions present in the content.
# Uses LLM to identify emotional undertones and return structured emotion scores.
class TextEmotionAnalyzer < Lluminary::Task
  use_provider :bedrock

  input_schema do
    string :text, description: "The text to analyze for emotional content"
    validates :text, presence: true
  end

  output_schema do
    dictionary :emotion_scores,
               description: "Scores for each detected emotion (0.0 to 1.0)" do
      float
    end

    string :dominant_emotion, description: "The most strongly detected emotion"
    string :analysis,
           description: "A brief explanation of the emotional analysis"

    validates :dominant_emotion, presence: true
    validates :analysis, presence: true
  end

  def task_prompt
    <<~PROMPT
      Analyze the following text for emotional content. For each emotion you detect, provide a score between 0.0 and 1.0 indicating its intensity.
      Also identify the dominant emotion and provide a brief analysis of the emotional content.

      Text: #{text}
    PROMPT
  end
end

# Example usage
if __FILE__ == $PROGRAM_NAME
  puts "#> Running TextEmotionAnalyzer example"

  text = <<~TEXT
    The sun was setting behind the mountains, casting long shadows across the valley. 
    Sarah felt a mix of emotions as she watched the last rays of light disappear. 
    There was a deep sense of peace, but also a tinge of sadness knowing this beautiful moment would soon be gone. 
    She smiled through her tears, grateful for the experience yet longing for it to last just a little longer.
  TEXT

  result = TextEmotionAnalyzer.call(text: text)

  puts "##> Input"
  puts result.input
  puts result.input.valid?

  puts "\n##> Generated prompt"
  puts result.prompt

  puts "\n##> Output"
  puts "Emotion Scores:"
  ap result.output.emotion_scores, indent: -2
  puts "\nDominant Emotion: #{result.output.dominant_emotion}"
  puts "Analysis: #{result.output.analysis}"
end
