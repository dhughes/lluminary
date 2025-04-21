# frozen_string_literal: true
require_relative "config"

# Groups similar items together based on their semantic relationships.
# Uses LLM to understand relationships and create meaningful groupings.
class GroupSimilarItems < Lluminary::Task
  use_provider :openai

  input_schema do
    array :items do
      string
    end
    validates :items, presence: true, length: { minimum: 2 }
  end

  output_schema do
    array :groups, description: "Groups of semantically related items" do
      array { string }
    end
    validates :groups, presence: true
  end

  private

  def task_prompt
    <<~PROMPT
      Group these items into categories based on their semantic relationships:
      #{items.inspect}

      Create meaningful groups where items in each group are related or similar to each other.
      Each item should appear in exactly one group.
    PROMPT
  end
end

# Example usage
if __FILE__ == $PROGRAM_NAME
  puts "#> Running GroupSimilarItems example"

  # Example with mixed items
  mixed_items = %w[
    apple
    banana
    carrot
    hammer
    wrench
    pliers
    JavaScript
    Python
    Ruby
    orange
    celery
    screwdriver
  ]

  result = GroupSimilarItems.call(items: mixed_items)

  puts "##> Input"
  puts "items: #{result.input.items.inspect}"

  puts "\n##> Generated prompt"
  puts result.prompt

  puts "\n##> Output"
  puts "Groups:"
  ap result.output.groups, indent: -2

  # Example with book titles
  books = [
    "1984",
    "The Hobbit",
    "Neuromancer",
    "Lord of the Rings",
    "Snow Crash",
    "Dune",
    "The Silmarillion",
    "Fahrenheit 451",
    "Foundation",
    "The Children of Húrin"
  ]

  result = GroupSimilarItems.call(items: books)

  puts "\n##> Second Example"

  puts "##> Input"
  puts "items: #{result.input.items.inspect}"

  puts "\n##> Generated prompt"
  puts result.prompt

  puts "\n##> Output"
  puts "Groups:"
  ap result.output.groups, indent: -2
end
