# Luminary

A framework for building LLM-powered applications in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'luminary'
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install luminary
```

## Usage

### Defining Tasks

Tasks are the core building blocks of Luminary. Each task represents a single interaction with an LLM.

```ruby
class SummarizeText < Luminary::Task
  input_schema do
    string :text
  end

  def prompt
    "Summarize the following text: #{text}"
  end
end

# Using the task
result = SummarizeText.call(text: "A long piece of text to summarize...")
puts result.raw_response
```

### Input Schema

You can define the inputs your task expects using the input schema DSL:

```ruby
class MyTask < Luminary::Task
  input_schema do
    string :text  # Defines a string input named 'text'
  end

  def prompt
    # Access inputs directly as methods
    "Process this text: #{text}"
  end
end
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the MIT License. 