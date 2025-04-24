# frozen_string_literal: true
require_relative "config"

# Creates a detailed character profile from a text description.
# Uses LLM to extract and structure information about characters from text.
class CharacterProfiler < Lluminary::Task
  use_provider :bedrock,
               model: Lluminary::Models::Bedrock::AnthropicClaudeInstantV1

  input_schema do
    string :text,
           description: "Text containing character description or dialogue"
    validates :text, presence: true
  end

  output_schema do
    hash :character_profile,
         description: "Structured profile of the character" do
      string :name, description: "Character's full name or main identifier"
      string :personality,
             description: "Brief description of character's personality traits"

      hash :appearance do
        string :physical_traits, description: "Notable physical characteristics"
        string :style, description: "How the character typically dresses"
      end

      array :motivations,
            description: "Character's main goals or motivations" do
        string
      end

      hash :relationships do
        array :allies, description: "Characters that support this character" do
          string
        end
        array :adversaries,
              description: "Characters that oppose this character" do
          string
        end
      end

      float :complexity_score,
            description:
              "A score from 0-1 indicating how complex the character seems"
    end
  end

  def task_prompt
    <<~PROMPT
      Analyze the following text and create a detailed character profile.
      Extract or infer as much information as possible about the character's traits, 
      appearance, motivations, and relationships.
      
      If some information isn't explicitly stated, you may make reasonable inferences
      based on the text, but prioritize what's directly mentioned.
      
      Text:
      #{text}
    PROMPT
  end
end

# Example usage
if __FILE__ == $PROGRAM_NAME
  puts "#> Running CharacterProfiler example"

  # Example with a fictional character description
  sample_text = <<~TEXT
    Eliza Montenegro was not the kind of person who made a grand entrance, despite her striking appearance. 
    At 5'9" with curly auburn hair that framed an angular face, she preferred tailored blazers and vintage boots that had seen better days.
    
    Her colleagues at the research lab respected her brilliant mind but found her difficult to read. She spoke rarely in meetings, 
    but when she did, everyone listened. The only time she seemed to lower her guard was around Dr. Chen, her mentor of fifteen years,
    or when discussing her passion project: developing affordable water filtration systems for remote villages like the one her grandmother grew up in.
    
    The board of directors saw her as a problem - especially Richardson, who had tried to redirect her funding three times. 
    But with two patents already bringing in revenue and a dedicated team willing to work overtime just to be part of her vision, 
    even her critics couldn't deny her value to the company.
  TEXT

  result = CharacterProfiler.call(text: sample_text)

  puts "##> Input"
  puts "Text excerpt: #{result.input.text[0..50]}..."

  puts "\n##> Generated prompt"
  puts result.prompt

  puts "\n##> Output"
  puts "Character Profile:"
  ap result.output.character_profile, indent: -2

  # Example with a different character
  literary_text = <<~TEXT
    "I am Gatsby," he said suddenly.
    
    "What!" I exclaimed. "Oh, I beg your pardon."
    
    "I thought you knew, old sport. I'm afraid I'm not a very good host."
    
    He smiled understandingly--much more than understandingly. It was one of those rare smiles with a quality of eternal reassurance in it, 
    that you may come across four or five times in life. It faced--or seemed to face--the whole eternal world for an instant, 
    and then concentrated on you with an irresistible prejudice in your favor. It understood you just as far as you wanted to be understood, 
    believed in you as you would like to believe in yourself, and assured you that it had precisely the impression of you that, at your best, 
    you hoped to convey.
    
    His elaborate formality of speech just missed being absurd. Some time before he introduced himself I'd got a strong impression that he was picking his words with care.
  TEXT

  result = CharacterProfiler.call(text: literary_text)

  puts "\n\n##> Second Example"
  puts "Text excerpt: #{result.input.text[0..50]}..."
  puts "\nCharacter Profile:"
  ap result.output.character_profile, indent: -2
end
