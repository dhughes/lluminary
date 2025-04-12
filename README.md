# Luminary

A Ruby framework for building LLM-powered applications with structured outputs.

## Features

- Task-based architecture for LLM interactions
- Automatic JSON response formatting based on output schemas
- Input and output schema validation
- Provider abstraction for different LLM services
- Built-in support for OpenAI
- Easy to extend with custom providers
- Field descriptions for better LLM understanding
- Rich result objects with access to prompts and responses

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'luminary'
```

And then execute:

```bash
bundle install
```

## Usage

### Basic Task

```ruby
class SummarizeText < Luminary::Task
  use_provider :openai, api_key: ENV['OPENAI_API_KEY']

  input_schema do
    string :text, description: "The text to be summarized"
  end

  output_schema do
    string :summary, description: "A concise one-sentence summary of the input text"
  end

  private

  def task_prompt
    "Summarize the following text in one short sentence:\n\n#{text}"
  end
end

# Use the task
result = SummarizeText.call(text: "Your text here")
puts result.output.summary
```

### Schema Descriptions

The schema system supports optional descriptions for each field. These descriptions help the LLM understand exactly what each field should contain:

```ruby
class AnalyzeText < Luminary::Task
  output_schema do
    string :sentiment, description: "The overall emotional tone (positive, negative, or neutral)"
    string :key_points, description: "The main ideas or arguments presented in the text"
    integer :word_count, description: "Total number of words in the text"
  end
end

# LLM will receive a prompt that includes:
#
# sentiment (string): The overall emotional tone (positive, negative, or neutral)
# Example: "your sentiment here"
#
# key_points (string): The main ideas or arguments presented in the text
# Example: "your key_points here"
#
# word_count (integer): Total number of words in the text
# Example: 0
```

### Input Validation

Tasks support input validation through the schema system. You can add validations to your input schema:

```ruby
class WordCounter < Luminary::Task
  input_schema do
    string :text
    integer :min_length

    validates :text, presence: true
    validates :min_length, presence: true, numericality: { greater_than: 0 }
  end
end

# Using call to handle validation errors gracefully
result = WordCounter.call(text: nil, min_length: nil)
result.input.valid?  # => false
result.input.errors.full_messages  # => ["Text can't be blank", "Min length can't be blank", ...]
result.output  # => nil (task not executed due to validation failure)

# Using call! to raise validation errors
WordCounter.call!(text: nil, min_length: nil)  # raises ValidationError
```

The `call` method returns a result object that allows you to check validation status and errors, while `call!` raises a `ValidationError` if validation fails. This gives you flexibility in how you want to handle validation failures.

### Result Objects

Tasks return rich result objects that provide access to:

```ruby
result = AnalyzeText.call(text: "Your text here")

result.input          # Access the validated input model
result.input.valid?   # Check if input is valid
result.input.errors   # Access validation errors
result.output        # Access the parsed output fields
result.raw_response  # The raw JSON response from the LLM
result.prompt        # The full prompt sent to the LLM
```

### Examples

See the `examples/` directory for complete working examples:

- `summarize_text.rb`: A task that summarizes text using OpenAI
- `analyze_text.rb`: A task that performs text analysis with multiple output fields
- `word_counter.rb`: A task that counts words and finds the longest word

## Development

After checking out the repo, run `bundle install` to install dependencies.

### Running Tests

```bash
bundle exec rspec
```

### Environment Setup

Create a `.env` file with your API keys:

```
OPENAI_API_KEY=your_api_key_here
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/luminary.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). 