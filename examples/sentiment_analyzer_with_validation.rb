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
    validate_with :validate_confidence_score
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

    if @output.confidence < 0 || @output.confidence > 100
      add_error(:confidence, "must be between 0 and 100")
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "#> Running SentimentAnalyzerWithValidation example"

  # Example with valid confidence
  puts "\n# Example with valid input"
  result = SentimentAnalyzerWithValidation.call(text: "I love this product!")

  puts "Valid? #{result.output.valid?}"
  unless result.output.valid?
    puts "Errors: #{result.output.errors.full_messages}"
  end
  puts "Output: #{result.output.attributes.inspect}"

  # Create a more robust test for invalid data
  puts "\n# Example with manually created invalid confidence"

  # Create a task instance
  task = SentimentAnalyzerWithValidation.new(text: "I hate this product!")

  # Manually create schema model with invalid data
  output_model =
    SentimentAnalyzerWithValidation.output_schema_model.new(
      sentiment: "negative",
      explanation: "User expresses dislike for the product.",
      confidence: 150 # Invalid confidence score
    )

  # Set as task's output
  task.instance_variable_set(:@output, output_model)

  # Run the custom validations
  puts "Before custom validations: #{output_model.valid?}"
  puts "Before errors: #{output_model.errors.full_messages.inspect}"

  # Run custom validations
  task.run_custom_validations

  # Check validation results
  puts "After custom validations valid? #{output_model.valid?}"
  puts "After errors: #{output_model.errors.full_messages.inspect}"
  puts "Output: #{output_model.attributes.inspect}"

  # Try direct validation
  puts "\n# Direct validation test"
  output_model.errors.add(:confidence, "direct test error")
  puts "After direct error add: #{output_model.errors.full_messages.inspect}"
  puts "Valid? #{output_model.valid?}"
end
