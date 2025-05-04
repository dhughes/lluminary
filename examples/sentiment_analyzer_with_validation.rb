# frozen_string_literal: true
require_relative "config"
require "dotenv/load"

# Analyzes the sentiment of text using LLM with custom validation.
# Returns structured sentiment analysis with validation of confidence score.
class SentimentAnalyzerWithValidation < Lluminary::Task
  use_provider :openai

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

    validates :sentiment, inclusion: { in: %w[positive negative neutral] }

    # Add custom validation for confidence score
    validate :validate_confidence_score,
             description: "Confidence score must be between 0 and 100"
  end

  def task_prompt
    <<~PROMPT
      Analyze the sentiment of the following text:

      #{text}
    PROMPT
  end

  # Custom validation method
  def validate_confidence_score
    return if @output.nil? || @output.confidence.nil?

    # Yes, we could do this with a range, but we want to test the custom validation
    return unless @output.confidence < 0 || @output.confidence > 100
    errors.add(:confidence, "must be between 0 and 100")
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "#> Running SentimentAnalyzerWithValidation example"

  puts "\n# Example with valid input"
  result = SentimentAnalyzerWithValidation.call(text: "I love this product!")

  puts "##> Input"
  puts "Ingredients: #{result.input.text}"

  puts "\n##> Generated prompt"
  puts result.prompt

  puts "\n##> Output"
  puts "Valid? #{result.output.valid?}"
  puts "Errors: #{result.output.errors.full_messages}"

  puts "Sentiment: #{result.output.sentiment}"
  puts "Explanation: #{result.output.explanation}"
  puts "Confidence: #{result.output.confidence}"
end
