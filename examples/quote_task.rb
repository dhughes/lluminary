# frozen_string_literal: true
require_relative "config"

# Extracts and analyzes quotes from text.
# Uses LLM to identify quotes and their context from input text.
class QuoteTask < Lluminary::Task
  use_provider :openai

  output_schema do
    string :quote, description: "An inspirational quote"
    string :author, description: "The person who said or wrote the quote"
  end

  def task_prompt
    <<~PROMPT
      Generate an inspirational quote and its author. The quote should be:
      1. Meaningful and thought-provoking
      2. From a well-known figure in history, literature, science, or philosophy
      3. Accurately attributed
      4. Between 5 and 20 words long
    PROMPT
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "#> Running QuoteTask example"

  result = QuoteTask.call

  puts result.output
end
