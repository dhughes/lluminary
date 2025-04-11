require 'luminary'

class SummarizeText < Luminary::Task
  use_provider :openai, api_key: ENV['OPENAI_API_KEY']

  input_schema do
    string :text
  end

  output_schema do
    string :summary
  end

  private

  def task_prompt
    "Summarize the following text in one short sentence:\n\n#{text}"
  end
end
