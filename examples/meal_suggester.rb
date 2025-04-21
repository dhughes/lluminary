# frozen_string_literal: true
require_relative "config"

# Suggests possible meals that can be made from a list of ingredients.
# Uses LLM to creatively combine ingredients into meal suggestions.
class MealSuggester < Lluminary::Task
  use_provider :openai

  input_schema do
    array :ingredients do
      string
    end
    integer :suggestions_count

    validates :ingredients, presence: true, length: { minimum: 1 }
    validates :suggestions_count,
              presence: true,
              numericality: {
                greater_than: 0
              }
  end

  output_schema do
    array :meal_suggestions,
          description:
            "A list of meal suggestions, each describing how to use the available ingredients" do
      string
    end

    validates :meal_suggestions, presence: true
  end

  private

  def task_prompt
    <<~PROMPT
      Given these ingredients, suggest exactly #{suggestions_count} meal ideas that use them:
      #{ingredients.inspect}
      
      Each suggestion should be a clear, descriptive sentence that explains how to use the ingredients.
      Focus on meals that make good use of multiple ingredients from the list.
    PROMPT
  end
end

# Example usage
if __FILE__ == $PROGRAM_NAME
  puts "#> Running MealSuggester example"

  # Example with pizza ingredients
  pizza_ingredients = [
    "pepperoni",
    "mozzarella cheese",
    "tomato sauce",
    "flour",
    "yeast",
    "olive oil"
  ]
  result =
    MealSuggester.call(ingredients: pizza_ingredients, suggestions_count: 5)

  puts "##> Input"
  puts "Ingredients: #{result.input.ingredients.inspect}"

  puts "\n##> Generated prompt"
  puts result.prompt

  puts "\n##> Output"
  puts "Meal Suggestions:"
  ap result.output.meal_suggestions, indent: -2

  # Example with breakfast ingredients
  breakfast_ingredients = %w[eggs bread butter cheese ham spinach]
  result =
    MealSuggester.call(ingredients: breakfast_ingredients, suggestions_count: 5)

  puts "\n\n##> Second Example"
  puts "Ingredients: #{result.input.ingredients.inspect}"
  puts "\nMeal Suggestions:"
  ap result.output.meal_suggestions, indent: -2
end
