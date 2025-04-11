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
  # Define the inputs your task expects
  input_schema do
    string :text
  end

  # Define the outputs your task will return
  output_schema do
    string :summary
  end

  def prompt
    "Summarize the following text: #{text}"
  end
end

# Using the task
result = SummarizeText.call(text: "A long piece of text to summarize...")

# Access the raw LLM response
puts result.raw_response

# Access the structured output
puts result.output.summary
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

### Output Schema

You can define the structured outputs your task will return:

```ruby
class MyTask < Luminary::Task
  output_schema do
    string :summary  # Defines a string output named 'summary'
  end
end

result = MyTask.call(text: "some text")
puts result.output.summary  # Access the output field
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the MIT License. 