require_relative 'config'

class ContentAnalyzer < Lluminary::Task
  use_provider :openai

  input_schema do
    string :text, description: "The text content to analyze"
    string :content_type, description: "Type of content to check for (e.g., 'technical', 'emotional', 'persuasive')"
    
    validates :text, presence: true
    validates :content_type, presence: true
  end

  output_schema do
    boolean :contains_type, description: "Whether the text contains the specified content type"

    # validates :contains_type, presence: true
  end

  private

  def task_prompt
    <<~PROMPT
      Analyze the following text and determine if it contains #{content_type} content. Consider the language, tone, and style used in the text.
        
      Text: #{text}"
    PROMPT
  end
end

# Example usage
if __FILE__ == $0
  puts "#> Running ContentAnalyzer example"

  text = <<~TEXT
    The revolutionary new quantum processor leverages advanced photonic circuits to achieve unprecedented computational speeds. 
    By utilizing entangled photon pairs, it can perform complex calculations in parallel, significantly reducing processing time.
    This breakthrough technology represents a major advancement in quantum computing.
  TEXT

  result = ContentAnalyzer.call(
    text: text,
    content_type: "technical"
  )

  puts "##> Input"
  puts result.input
  puts result.input.valid?
  
  puts "##> Output"
  puts result.output
  puts result.output.valid?

  result = ContentAnalyzer.call(
    text: text,
    content_type: "emotional"
  )

  puts "##> Input"
  puts result.input
  puts result.input.valid?
  
  puts "##> Output"
  puts result.output
  puts result.output.valid?
end 