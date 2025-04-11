# Luminary TODO

## Task Interface
- [ ] Input/Output Schema DSL
  ```ruby
  class MyTask < Luminary::Task
    input_schema do
      string :text
      validates :text, presence: true
    end

    output_schema do
      string :summary
      validates :summary, presence: true
    end
  end
  ```
- [ ] Result Object
  - [ ] Access to validated inputs via `result.input`
  - [ ] Access to validated outputs via `result.output`
  - [ ] Access to raw LLM response via `result.raw_response`
  - [ ] Success/failure status via `result.success?`
  - [ ] Error messages via `result.errors`
- [ ] Validation
  - [ ] Input validation before execution
  - [ ] Output validation after LLM response
  - [ ] Automatic retry with improved prompts on validation failure
- [ ] Configuration
  - [ ] Task-specific configuration (max retries, etc.)
  - [ ] LLM provider configuration
  - [ ] Global configuration

## Data Types
- [ ] String
  - Basic string input/output
  - Length validation
  - Required/optional
- [ ] Integer
  - Basic integer input/output
  - Range validation
  - Required/optional
- [ ] Boolean
  - Basic boolean input/output
  - Required/optional
- [ ] Float
  - Basic float input/output
  - Range validation
  - Precision validation
  - Required/optional
- [ ] Array
  - Basic array input/output
  - Length validation
  - Typed arrays (array of strings, etc.)
  - Required/optional
- [ ] Hash
  - Basic hash input/output
  - Schema validation
  - Required/optional
- [ ] Date
  - Basic date input/output
  - Format validation
  - Required/optional

## Core Features
- [ ] Input schema definition
- [ ] Output schema definition
- [ ] Prompt generation
- [ ] Response validation
- [ ] Error handling
- [ ] Retry logic
- [ ] LLM provider integration
  - [ ] OpenAI
  - [ ] Amazon Bedrock
  - [ ] Anthropic
  - [ ] Google Vertex AI

## Advanced Features
- [ ] Tool/function calling support
- [ ] Task composition
- [ ] Prompt optimization
- [ ] Performance metrics
  - [ ] Token usage
  - [ ] Response time
  - [ ] Attempt count
- [ ] Debug information
  - [ ] Response justification
  - [ ] Intermediate steps 