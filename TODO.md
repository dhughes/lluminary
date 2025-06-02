# Lluminary TODO List

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
- [x] Add input validation using schemas
- [x] Add validation error handling
- [x] Add support for validation error checking via result objects
- [x] Add schema validation for provider responses
- [x] Add datetime type support

## In Progress
- [ ] Add support for all JSON data types in schemas
  - [ ] Consider using input schema descriptions to enhance LLM prompts
    - [ ] Explore how input field descriptions could provide context to the LLM
    - [x] Consider adding validation rules to the prompt context
    - [ ] Evaluate if this would help the LLM better understand input constraints
    - [ ] Consider adding examples from the schema to the prompt

## Future Tasks
- [ ] Test this for support of older versions of Rails. (I think it might not work below Rails 8)
- [x] Add support for additional LLM providers (Anthropic, Google, etc.)
  - [x] Add support for Amazon Bedrock
- [ ] Add support for OpenRouter.ai as a unified LLM gateway
  - [ ] Research OpenRouter.ai API integration (OpenAI-compatible)
  - [ ] Implement OpenRouter provider
    - [ ] Single provider that provides access to 300+ models from 50+ providers
    - [ ] Intelligent model routing and cost optimization
    - [ ] Built-in fallback mechanisms for high availability
    - [ ] Support for latest models including experimental ones
  - [ ] Consider OpenRouter as primary multi-provider solution
    - [ ] Could simplify maintenance vs individual provider implementations
    - [ ] Provides unified billing and management
    - [ ] ~5% markup cost vs direct provider access
    - [ ] OpenAI-compatible API makes integration straightforward
  - [ ] Evaluate OpenRouter vs direct provider strategy
    - [ ] Document pros/cons of unified gateway vs individual providers
    - [ ] Consider hybrid approach (OpenRouter + critical direct providers)
    - [ ] Test model selection and routing capabilities
    - [ ] Evaluate pricing and performance impact
- [ ] Add support for local LLM providers
  - [ ] Integrate with Ollama for local model support
  - [ ] Add support for LM Studio
  - [ ] Add support for LocalAI
  - [ ] Document local provider setup and configuration
  - [ ] Add examples of using local models
  - [ ] Consider performance recommendations for local models
- [ ] Revisit custom validation support
  - [ ] Add support for custom validation methods
  - [ ] Add support for custom validation classes
  - [ ] Document custom validation patterns
  - [ ] Add examples of custom validations
- [ ] Implement task chaining and composition
- [ ] Add rate limiting and retry mechanisms
- [ ] Implement streaming responses
- [x] Add schema validation for provider responses
- [ ] Support nested objects in schemas
- [ ] Add array type support in schemas
- [ ] Add logging and monitoring
- [x] Add provider-specific configuration options
- [ ] Add response templating system
- [ ] Consider adding support for custom providers
  - [x] Define clear interface requirements
  - [ ] Add validation for custom provider implementations
  - [ ] Document provider creation process
  - [ ] Add examples of custom providers
- [ ] Improve task result output format
  - [x] Include input parameters in output
  - [x] Include output values in output
  - [ ] Consider adding execution time and other metadata

## Task Interface
- [x] Input/Output Schema DSL
  ```ruby
  class MyTask < Lluminary::Task
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
  - [x] Success/failure status via `result.input.valid?`
  - [x] Error messages via `result.input.errors`
- [x] Validation
  - [x] Input validation before execution
  - [x] Output validation after LLM response
  - [ ] Automatic retry with improved prompts on validation failure
- [ ] Configuration
  - [x] Task-specific configuration (max retries, etc.)
  - [x] LLM provider configuration
  - [x] Global configuration

## Data Types
- [x] String
  - [x] Basic string input/output
  - [x] Length validation
  - [x] Required/optional
  - [x] Example values
- [x] Integer
  - [x] Basic integer input/output
  - [x] Range validation
  - [x] Required/optional
  - [x] Example values
- [x] Boolean
  - [x] Basic boolean input/output
  - [x] Required/optional
- [x] Float
  - [x] Basic float input/output
  - [x] Required/optional
- [ ] Decimal
  - [ ] Consider using BigDecimal for input validation
  - [ ] Consider precision requirements for output validation
  - [ ] Evaluate LLM output handling for numeric types
  - [ ] Consider adding float type for less strict numeric validation
  - [ ] Consider configuration options for numeric validation strictness
  - [ ] Document numeric type best practices for LLM interactions
- [ ] Array
  - [ ] Basic array input/output
  - [ ] Length validation
  - [ ] Typed arrays (array of strings, etc.)
  - [ ] Required/optional
- [ ] Hash
  - [ ] Basic hash input/output
  - [ ] Schema validation
  - [ ] Required/optional
- [ ] Date / Time
  - [ ] Basic date input/output
  - [ ] Format validation
  - [ ] Required/optional
- [x] DateTime
  - [x] Basic datetime input/output
  - [x] Required/optional
  - [ ] Consider timezone handling
    - [ ] Evaluate UTC normalization
    - [ ] Consider timezone preservation
    - [ ] Document timezone behavior

## Core Features
- [x] Input schema definition
- [x] Output schema definition
- [ ] Performance metrics and timing
  - [ ] Add execution time tracking
  - [ ] Include token usage statistics
  - [ ] Add provider-specific metrics
  - [ ] Make metrics accessible via result object
  - [ ] Add optional detailed logging
- [ ] Prompt optimization system
  - [ ] Default prompt optimizer
    - [ ] Generic prompt formatting
    - [x] Schema information integration
    - [ ] Basic instructions
  - [ ] Model-specific prompt optimizers
    - [ ] Support for different models across providers
    - [ ] Custom formatting for specific models
    - [ ] Provider-agnostic optimization
  - [ ] Custom prompt optimizer support
    - [ ] Interface for user-defined optimizers
    - [ ] Documentation and examples
  - [ ] Optimization features
    - [x] Schema-aware formatting
    - [ ] Model-specific instructions
    - [ ] Context and examples integration
- [x] Response validation
- [x] Error handling
- [ ] Retry logic
- [x] Provider interface
  - [x] Base provider class
  - [x] Test provider
  - [x] Provider configuration
  - [x] use_provider DSL
  - [x] OpenAI provider
    - [x] Add ruby-openai gem as optional dependency
    - [x] Basic provider implementation
      - [x] Initialize OpenAI client
      - [x] Handle basic chat completion
      - [x] Extract response content
    - [x] Configuration
      - [x] API key handling
      - [x] Model selection
      - [x] Default model setting
    - [x] Error handling
      - [ ] Rate limit handling
      - [ ] Authentication errors
      - [ ] Network errors
    - [x] Testing
      - [x] Unit tests with mocked client
      - [ ] Integration tests (marked)
    - [ ] Optional features
      - [ ] Support for completion API
      - [x] Advanced parameters (temperature, max_tokens)
      - [ ] Streaming support
  - [x] Amazon Bedrock
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

## Configuration and Provider Management
- [ ] Rails Integration
  - [ ] Create Rails initializer pattern similar to Sidekiq
  - [ ] Support for global provider configurations
  - [ ] Support for environment-specific configurations
  - [ ] Support for provider-specific defaults
- [ ] Provider Configuration
  - [ ] Define required configuration for each provider
  - [ ] Add configuration validation
  - [ ] Support for multiple active providers
  - [ ] Support for provider-specific configuration defaults
- [ ] Provider Optimization
  - [ ] Add provider selection based on task requirements
  - [ ] Add model selection based on task requirements
  - [ ] Support for cost/performance optimization
  - [ ] Support for fallback providers
  - [ ] Support for provider-specific model selection
- [ ] Provider Dependencies
  - [ ] Make LLM provider dependencies optional (not bundled with gem)
  - [ ] Document required gem dependencies for each provider
  - [ ] Add dependency checks when providers are initialized
  - [ ] Add helpful error messages when provider gems aren't installed
  - [ ] Consider creating separate provider gems (e.g. lluminary-openai, lluminary-bedrock)
- [ ] Add provider-specific configuration options
  - [ ] Add default provider setting
    - [ ] Allow setting default provider in global config
    - [ ] Make tasks use default provider when none specified
    - [ ] Add tests for default provider behavior
    - [ ] Update documentation for default provider 


# Notes on supporting Gemini (and maybe Vertex)

- Google has Google AI Studio
  - You can get an API token from there.
- There are a few ruby gems that claim to support gemini
  - they seem to indicate support for both ai studio and vertex, but I'm not 100% clear.
  - ~~I'm leaning towards gemini-ai: https://github.com/gbaptista/gemini-ai~~ Appears abandoned.

The docs for credentials mentions that you can create a key in google cloud console OR via AI studio, but that AI studio actually creates a cloud project for you. https://github.com/gbaptista/gemini-ai?tab=readme-ov-file#option-1-api-key-generative-language-api

I think the config (in the current form) could look something like these, though it'll be different in the future. Right now there's no support for GCP credentials files.

```ruby
# for keys created via https://aistudio.google.com/apikey 
# TODO: maybe this is always `:vertex`?
config.provider(
  :google_ai_studio,
  api_key: ENV["GOOGLE_API_KEY"],
  model: '????'
)

# when using a gcp service account with a credentials file
config.provider(
  :vertex,
  credentials_file: ENV["GOOGLE_APPLICATION_CREDENTIALS"],
  region: ENV["GOOGLE_CLOUD_LOCATION"],
  model: '????'
)

# when using a gcp service account with the contents of a credentials file
# TODO: or maybe `credentials` takes either a string or hash and figures it out from there?
config.provider(
  :vertex,
  credentials: { ... },
  region: ENV["GOOGLE_CLOUD_LOCATION"],
  model: '????'
)

# default credentials for local dev 
config.provider(
  :vertex,
  region: ENV["GOOGLE_CLOUD_LOCATION"],
  model: '????'
)

# The above might have an optional `project_id` field as well, but I'm not sure why yet.

```

~~The `gemini-ai` gem provides a way to configure safety settings.~~

~~Different gemini models allow you to provide a json schema (or not):~~

> While Gemini 1.5 Flash models only accept a text description of the JSON schema you want returned, the Gemini 1.5 Pro models let you pass a schema object (or a Python type equivalent), and the model output will strictly follow that schema. This is also known as controlled generation or constrained decoding.

✅ I have gemini working via the google ai studio

The gemini-ai gem seems to be abandoned. (10 months with no activity). 
I may want to crib from their work. 
Or, Google has an openai compatible endpoint. See: https://ai.google.dev/gemini-api/docs/openai

