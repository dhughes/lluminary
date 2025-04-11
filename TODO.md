# Luminary TODO

## Task Interface
- [x] Input/Output Schema DSL
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
- [x] Result Object
  - [x] Access to raw LLM response via `result.raw_response`
  - [ ] Access to validated inputs via `result.input`
  - [x] Access to validated outputs via `result.output`
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
- [x] String
  - [x] Basic string input/output
  - [ ] Length validation
  - [ ] Required/optional
- [ ] Integer
  - [ ] Basic integer input/output
  - [ ] Range validation
  - [ ] Required/optional
- [ ] Boolean
  - [ ] Basic boolean input/output
  - [ ] Required/optional
- [ ] Float
  - [ ] Basic float input/output
  - [ ] Range validation
  - [ ] Precision validation
  - [ ] Required/optional
- [ ] Array
  - [ ] Basic array input/output
  - [ ] Length validation
  - [ ] Typed arrays (array of strings, etc.)
  - [ ] Required/optional
- [ ] Hash
  - [ ] Basic hash input/output
  - [ ] Schema validation
  - [ ] Required/optional
- [ ] Date
  - [ ] Basic date input/output
  - [ ] Format validation
  - [ ] Required/optional

## Core Features
- [x] Input schema definition
- [x] Output schema definition
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

## Database Integration
- [ ] Core Tables
  - [ ] LLM Calls
    - [ ] Task reference
    - [ ] Provider reference
    - [ ] Model reference
    - [ ] Input/output data
    - [ ] Performance metrics
    - [ ] Feedback system
  - [ ] Tasks
    - [ ] Schema definitions
    - [ ] Configuration
    - [ ] Performance history
  - [ ] Providers
    - [ ] Configuration
    - [ ] Performance metrics
  - [ ] Models
    - [ ] Configuration
    - [ ] Performance metrics
- [ ] Feedback System
  - [ ] Upvote/downvote mechanism
  - [ ] Feedback justification
  - [ ] Performance tracking
- [ ] Optional Integration
  - [ ] Database configuration
  - [ ] Migration system
  - [ ] Query interface

## Testing Framework
- [ ] Integration Tests
  - [ ] Success criteria definition
  - [ ] Performance metrics
  - [ ] Output validation
  - [ ] Test case management
- [ ] Metrics Collection
  - [ ] Response time tracking
  - [ ] Token usage
  - [ ] Accuracy measurement
  - [ ] Feedback aggregation
- [ ] Test Organization
  - [ ] Unit tests
  - [ ] Integration tests
  - [ ] Provider tests
- [ ] Test Helpers
  - [ ] Provider mocking
  - [ ] Response caching
  - [ ] Metrics collection

## Prompt Tuning System
- [ ] Tuning Engine
  - [ ] Performance analysis
  - [ ] Prompt variation generation
  - [ ] Validation system
  - [ ] Selection criteria
- [ ] Configuration
  - [ ] Tuning preferences
  - [ ] Performance targets
  - [ ] Resource constraints
- [ ] Monitoring
  - [ ] Performance tracking
  - [ ] Tuning history
  - [ ] Success metrics

## Future Service Architecture
- [ ] API Layer
  - [ ] Task Management
  - [ ] Test Execution
  - [ ] Performance Metrics
  - [ ] Prompt Tuning
- [ ] Analysis Engine
  - [ ] Performance Analysis
  - [ ] Prompt Optimization
  - [ ] Cross-Language Support
- [ ] Deployment Options
  - [ ] Self-hosted
  - [ ] Managed service
  - [ ] Hybrid approach 