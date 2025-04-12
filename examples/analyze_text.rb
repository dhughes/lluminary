require 'luminary'

class AnalyzeText < Luminary::Task
  use_provider :openai, api_key: ENV['OPENAI_API_KEY']

  input_schema do
    string :text
  end

  output_schema do
    string :analysis
  end

  private

  def task_prompt
    "Analyze the following text and provide a brief thematic analysis:\n\n#{text}"
  end
end 