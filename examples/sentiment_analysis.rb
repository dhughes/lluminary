# frozen_string_literal: true
require_relative "config"

# Analyzes the sentiment of text using LLM.
# Returns structured sentiment analysis with scores and explanations.
class SentimentAnalysis < Lluminary::Task
  use_provider :bedrock

  input_schema do
    string :text, description: "The text to analyze for sentiment"
    validates :text, presence: true
  end

  output_schema do
    string :sentiment,
           description: "The overall sentiment (positive, negative, or neutral)"
    string :explanation,
           description: "A brief explanation of the sentiment analysis"
    integer :confidence, description: "Confidence score from 0-100"
  end

  def task_prompt
    <<~PROMPT
      Analyze the sentiment of the following text:

      #{text}
    PROMPT
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "#> Running SentimentAnalysis example"

  result = SentimentAnalysis.call(text: "I love this product!")

  puts result.output
end
