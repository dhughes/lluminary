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

### Basic Task

```ruby
class MyTask < Luminary::Task
  def prompt
    "Say hello world"
  end
end

result = MyTask.call
puts result.raw_response  # => "hello world"
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the MIT License. 