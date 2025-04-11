# Luminary

A Ruby framework for building LLM-powered applications.

## Features

- Task-based architecture for LLM interactions
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
class MyTask < Luminary::Task
  use_provider :openai, api_key: ENV['OPENAI_API_KEY']

  input_schema do
    string :text
  end

  output_schema do
    string :summary
  end

  def prompt
    "Summarize the following text: #{text}"
  end
end

result = MyTask.call(text: "Your text here")
puts result.output.summary
```

### Examples

See the `examples/` directory for complete working examples:

- `summarize_text.rb`: A task that summarizes text using OpenAI
- `run_summarize.rb`: A script demonstrating how to use the summarization task

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