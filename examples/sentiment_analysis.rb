require 'dotenv'
Dotenv.load

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'lluminary'

class SentimentAnalysis < Lluminary::Task
  use_provider :bedrock, 
    access_key_id: ENV['AWS_ACCESS_KEY_ID'], 
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], 
    region: ENV['AWS_REGION']

  input_schema do
    string :text, description: "The text to analyze for sentiment"
    validates :text, presence: true
  end

  output_schema do
    string :sentiment, description: "The overall sentiment (positive, negative, or neutral)"
    string :explanation, description: "A brief explanation of the sentiment analysis"
    integer :confidence, description: "Confidence score from 0-100"
  end

  private

  def task_prompt
    <<~PROMPT
      Analyze the sentiment of the following text:

      #{text}
    PROMPT
  end
end

if __FILE__ == $0
  puts "#> Running SentimentAnalysis example"

  result = SentimentAnalysis.call(text: "I love this product!")

  puts result.output
end
