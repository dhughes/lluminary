require_relative '../lib/luminary'

class WordCounter < Luminary::Task
  use_provider(:openai, api_key: ENV['OPENAI_API_KEY'])

  input_schema do
    string :text
    integer :min_length
  end

  output_schema do
    string :longest_word
    integer :word_count
  end

  def task_prompt
    <<~PROMPT
      Analyze the following text and find:
      1. The longest word in the text
      2. The number of words that are at least #{min_length} characters long

      Text: #{text}
    PROMPT
  end
end 