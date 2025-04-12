# Lluminary

<img src="lluminary_logo.png" height="150" />

A Ruby framework for building LLM-powered applications with structured outputs.

## Features

- Task-based architecture for LLM interactions
- Automatic JSON response formatting based on output schemas
- Input and output schema validation
- Provider abstraction for different LLM services
- Built-in support for OpenAI and AWS Bedrock
- Easy to extend with custom providers
- Field descriptions for better LLM understanding
- Rich result objects with access to prompts and responses
- Global and task-specific provider configuration

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lluminary'
```

And then execute:

```bash
bundle install
```

## Configuration

Lluminary supports both global and task-specific provider configurations. Global configurations are set once and can be overridden per task.

### Global Configuration

Create a configuration file (e.g., `config/lluminary.rb`) in your application:

```ruby
require 'lluminary'

Lluminary.configure do |config|
  # OpenAI Configuration
  config.provider(:openai, 
    api_key: ENV['OPENAI_API_KEY']
  )

  # AWS Bedrock Configuration
  config.provider(:bedrock,
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    region: ENV['AWS_REGION']
  )
end
```

### Task-Specific Configuration

Tasks can use the global configuration or override it with their own settings:

```ruby
# Using global configuration
class DefaultConfigTask < Lluminary::Task
  use_provider :openai  # Uses the global OpenAI configuration
end

# Overriding global configuration
class CustomConfigTask < Lluminary::Task
  use_provider :openai, api_key: 'custom-key'  # Overrides the global OpenAI configuration
end
```

## Usage

### Basic Task

Here's a complete example of a task that uses the global configuration:

```ruby
class SummarizeText < Lluminary::Task
  use_provider :openai  # Uses the global OpenAI configuration

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
class AnalyzeText < Lluminary::Task
  use_provider :openai  # Uses the global OpenAI configuration

  output_schema do
    string :sentiment, description: "The overall emotional tone (positive, negative, or neutral)"
    string :key_points, description: "The main ideas or arguments presented in the text"
    integer :word_count, description: "Total number of words in the text"
  end
end
```

### Input and Output Validation

Tasks support validation through the schema system using ActiveModel validations. This means you have access to all standard ActiveModel validations for both input and output schemas.

#### Input Validation

```ruby
class WordCounter < Lluminary::Task
  use_provider :openai

  input_schema do
    string :text
    integer :min_length
    string :language, description: "The language of the text"

    # Standard validations
    validates :text, presence: true
    validates :min_length, presence: true, numericality: { greater_than: 0 }
    
    # Format validation
    validates :language, format: { with: /\A[a-z]{2}\z/, message: "must be a two-letter language code" }
  end
end
```

Common validations include:
- `presence`: Ensures a value is provided
- `numericality`: Validates numeric values
- `format`: Validates against a regular expression
- `inclusion`: Ensures a value is in a given set
- `length`: Validates string length
- `uniqueness`: Ensures a value is unique

For a complete list of validations, see the [ActiveModel Validations documentation](https://guides.rubyonrails.org/active_record_validations.html).

#### Output Validation

Output validation ensures that the LLM's response meets your requirements. The same validation rules available for input schemas can be used in output schemas:

```ruby
class AnalyzeText < Lluminary::Task
  use_provider :openai

  output_schema do
    string :sentiment, description: "The overall emotional tone"
    validates :sentiment, inclusion: { in: %w[positive negative neutral] }
    
    string :key_points, description: "The main ideas or arguments"
    validates :key_points, presence: true
    
    integer :word_count, description: "Total number of words"
    validates :word_count, numericality: { greater_than: 0 }
  end
end
```

Note: Custom validation methods and classes are not yet supported. This feature is planned for a future release. Additionally, future updates will include:
- Automatic validation rule sharing with the LLM to guide responses
- Retry mechanisms for failed output validation

#### Accessing Validation Results

You can check validation results and access input/output values through the result object:

```ruby
result = SomeTask.call(input_params)

# Check input validation
result.input.valid?  # => true/false
result.input.errors # => ActiveModel::Errors object

# Access input values defined in input_schema
result.input.text   # => "input text value"

# Check output validation
result.output.valid?  # => true/false
result.output.errors # => ActiveModel::Errors object

# Access output values defined in output_schema
result.output.summary # => "output summary value"

# Access raw LLM response (available even when validation fails)
result.raw_response # => Raw response from the LLM
```

## Running Examples

The examples in the `examples/` directory demonstrate various Lluminary features. To run them:

1. Create a `.env` file in the project root with the required environment variables:
   ```bash
   # OpenAI Configuration (required for OpenAI examples)
   OPENAI_API_KEY=your_openai_api_key

   # AWS Bedrock Configuration (required for Bedrock examples)
   AWS_ACCESS_KEY_ID=your_aws_access_key
   AWS_SECRET_ACCESS_KEY=your_aws_secret_key
   AWS_REGION=your_aws_region
   ```

2. Run an example:
   ```bash
   ruby examples/summarize_text.rb
   ```

Note: You only need to configure the providers you plan to use. For example, if you only want to run OpenAI examples, you only need to set the `OPENAI_API_KEY`.

## Provider Configuration Options

### OpenAI Provider

| Option | Required | Default | Description |
|--------|----------|---------|-------------|
| `api_key` | Yes | - | Your OpenAI API key |

### AWS Bedrock Provider

| Option | Required | Default | Description |
|--------|----------|---------|-------------|
| `access_key_id` | Yes | - | Your AWS access key ID |
| `secret_access_key` | Yes | - | Your AWS secret access key |
| `region` | Yes | - | The AWS region to use |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/lluminary. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/yourusername/lluminary/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Lluminary project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yourusername/lluminary/blob/master/CODE_OF_CONDUCT.md).