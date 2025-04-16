# frozen_string_literal: true
require_relative "config"

class PriceAnalyzer < Lluminary::Task
  use_provider :openai

  input_schema do
    string :product_name, description: "The name of the product to analyze"
    float :price, description: "The price of the product in dollars"

    validates :product_name, presence: true
    validates :price, presence: true
  end

  output_schema do
    float :competitiveness_score,
          description:
            "A score between 0.0 and 1.0 indicating how competitive the price is (higher is better)"

    validates :competitiveness_score, presence: true
  end

  private

  def task_prompt
    <<~PROMPT
      Analyze the price competitiveness of the following product. Consider factors like:
      - The product name and typical price range for similar products
      - Market standards and expectations
      - Value proposition
      
      Product: #{product_name}
      Price: $#{price}
      
      Return a competitiveness score between 0.0 and 1.0, where:
      - 1.0 means the price is highly competitive
      - 0.0 means the price is not competitive at all
      - Values in between represent varying degrees of competitiveness
    PROMPT
  end
end

# Example usage
if __FILE__ == $PROGRAM_NAME
  puts "#> Running PriceAnalyzer example"

  result = PriceAnalyzer.call(product_name: "Luxury Watch", price: 999.99)

  puts "##> Input"
  puts result.input
  puts result.input.valid?

  puts "##> Output"
  puts result.output
  puts result.output.valid?

  result = PriceAnalyzer.call(product_name: "Basic Watch", price: 10_009.99)

  puts "##> Input"
  puts result.input
  puts result.input.valid?

  puts "##> Output"
  puts result.output
  puts result.output.valid?
end
