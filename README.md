# Luminary

A Ruby framework for building LLM-powered applications with structured outputs.

## Features

- Task-based architecture for LLM interactions
- Automatic JSON response formatting based on output schemas
- Input and output schema validation
- Provider abstraction for different LLM services
- Built-in support for OpenAI
- Easy to extend with custom providers

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

# Use the task
result = SummarizeText.call(text: "Your text here")
puts result.output.summary
```

### Output Schema

The output schema defines the structure of the LLM's response. Luminary automatically formats the prompt to ensure the LLM returns JSON matching your schema:

```ruby
class AnalyzeText < Luminary::Task
  output_schema do
    string :sentiment
    string :key_points
    integer :word_count
  end
end

# LLM will respond with:
# {
#   "sentiment": "positive",
#   "key_points": "...",
#   "word_count": 42
# }
```

### Examples

See the `examples/` directory for complete working examples:

- `summarize_text.rb`: A task that summarizes text using OpenAI
- `analyze_text.rb`: A task that performs text analysis with multiple output fields

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