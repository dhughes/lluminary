# frozen_string_literal: true
require_relative "config"

# A simpler demo task to show custom validations in action
class CustomValidationDemo < Lluminary::Task
  use_provider :test

  input_schema do
    string :text, description: "Any text for testing"
    validates :text, presence: true
  end

  output_schema do
    string :summary, description: "A summary of the text"
    integer :score, description: "A score between 0 and 100"

    # Add custom validation
    validate_with :validate_score_range
  end

  def task_prompt
    "Summarize this text: #{text}"
  end

  # Custom validation method - works just like in Rails
  def validate_score_range
    # Access the score directly through the dynamically defined accessor
    if score && (score < 0 || score > 100)
      errors.add(:score, "must be between 0 and 100")
    end
  end
end

# Patch the test provider to return predictable results
module Lluminary
  module Providers
    class Test
      def call(prompt, task)
        # Return a static response for demonstration
        {
          raw: '{"summary": "A test summary", "score": 150}',
          parsed: {
            "summary" => "A test summary",
            "score" => 150 # Invalid score for testing
          }
        }
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "#> Running CustomValidationDemo"

  # Run the task with the test provider
  result = CustomValidationDemo.call(text: "Hello world!")

  # Output the validation results
  puts "Output valid? #{result.output.valid?}"
  puts "Validation errors: #{result.output.errors.full_messages.inspect}"
  puts "Output values: #{result.output.attributes.inspect}"
end
