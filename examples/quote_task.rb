require_relative 'config'

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'lluminary'

class QuoteTask < Lluminary::Task
  use_provider :openai

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

if __FILE__ == $0
  puts "#> Running QuoteTask example"

  result = QuoteTask.call

  puts result.output
end