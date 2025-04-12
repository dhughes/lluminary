require 'lluminary'

class QuoteTask < Lluminary::Task
  use_provider :openai, api_key: ENV['OPENAI_API_KEY']

  output_schema do
    string :quote, description: "An inspirational quote"
    string :author, description: "The person who said or wrote the quote"
  end

  private

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