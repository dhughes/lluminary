# Luminary TODO List

## Completed Tasks
- [x] Set up basic project structure
- [x] Implement Task base class
- [x] Add input and output schema validation
- [x] Create OpenAI provider implementation
- [x] Add example tasks
- [x] Update README with usage instructions and examples
- [x] Add environment configuration support
- [x] Implement automatic JSON response formatting
- [x] Clean up provider interface
- [x] Improve test structure and mocking patterns

## In Progress
- [ ] Add input validation using schemas
- [ ] Add support for all JSON data types in schemas
- [ ] Add error handling for invalid responses
- [ ] Refactor provider response format to use hash/object instead of array

## Future Tasks
- [ ] Add support for additional LLM providers (Anthropic, Google, etc.)
- [ ] Implement task chaining and composition
- [ ] Add caching layer for API responses
- [ ] Add rate limiting and retry mechanisms
- [ ] Implement streaming responses
- [ ] Add comprehensive test coverage
- [ ] Create documentation website
- [ ] Add CI/CD pipeline
- [ ] Add schema validation for provider responses
- [ ] Support nested objects in schemas
- [ ] Add array type support in schemas
- [ ] Add development tools and generators
- [ ] Add logging and monitoring
- [ ] Support async/background processing
- [ ] Add provider-specific configuration options
- [ ] Add response templating system

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
  - [x] Access to validated inputs via `result.input`
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
- [ ] Prompt optimization system
  - [ ] Default prompt optimizer
    - [ ] Generic prompt formatting
    - [ ] Schema information integration
    - [ ] Basic instructions
  - [ ] Model-specific prompt optimizers
    - [ ] Support for different models across providers
    - [ ] Custom formatting for specific models
    - [ ] Provider-agnostic optimization
  - [ ] Custom prompt optimizer support
    - [ ] Interface for user-defined optimizers
    - [ ] Documentation and examples
  - [ ] Optimization features
    - [ ] Schema-aware formatting
    - [ ] Model-specific instructions
    - [ ] Context and examples integration
- [ ] Response validation
- [ ] Error handling
- [ ] Retry logic
- [x] Provider interface
  - [x] Base provider class
  - [x] Test provider
  - [x] Provider configuration
  - [x] use_provider DSL
  - [ ] OpenAI provider
    - [ ] Add ruby-openai gem as optional dependency
    - [ ] Basic provider implementation
      - [ ] Initialize OpenAI client
      - [ ] Handle basic chat completion
      - [ ] Extract response content
    - [ ] Configuration
      - [ ] API key handling
      - [ ] Model selection
      - [ ] Default model setting
    - [ ] Error handling
      - [ ] Rate limit handling
      - [ ] Authentication errors
      - [ ] Network errors
    - [ ] Testing
      - [ ] Unit tests with mocked client
      - [ ] Integration tests (marked)
    - [ ] Optional features
      - [ ] Support for completion API
      - [ ] Advanced parameters (temperature, max_tokens)
      - [ ] Streaming support
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
- [x] Basic test infrastructure
  - [x] Test provider
  - [x] Provider mocking support
  - [x] Basic assertions
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
  - [x] Unit tests
  - [ ] Integration tests
  - [ ] Provider tests
- [ ] Test Helpers
  - [x] Provider mocking
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

## Next Steps
1. Implement OpenAI provider
2. Add global configuration system
3. Add input/output validation
4. Add error handling and retries
5. Add more data types
6. Implement response validation 