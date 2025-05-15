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
- [x] Add support for all JSON data types in schemas
  - [ ] Consider using input schema descriptions to enhance LLM prompts
    - [ ] Explore how input field descriptions could provide context to the LLM
    - [x] Consider adding validation rules to the prompt context
    - [ ] Evaluate if this would help the LLM better understand input constraints
    - [x] Consider adding examples from the schema to the prompt

## Future Tasks
- [ ] Test this for support of older versions of Rails. (I think it might not work below Rails 8)
- [x] Add support for additional LLM providers (Anthropic, Google, etc.)
  - [x] Add support for Amazon Bedrock
- [ ] Add support for local LLM providers
  - [ ] Integrate with Ollama for local model support
  - [ ] Add support for LM Studio
  - [ ] Add support for LocalAI
  - [ ] Document local provider setup and configuration
  - [ ] Add examples of using local models
  - [ ] Consider performance recommendations for local models
- [x] Revisit custom validation support
  - [x] Add support for custom validation methods
  - [ ] Add support for custom validation classes
  - [x] Document custom validation patterns
  - [x] Add examples of custom validations
- [ ] Implement task chaining and composition
- [ ] Add rate limiting and retry mechanisms
- [ ] Implement streaming responses
- [x] Add schema validation for provider responses
- [x] Support nested objects in schemas
- [x] Add array type support in schemas
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
- [x] Decimal
  - [x] Consider using BigDecimal for input validation
  - [x] Consider precision requirements for output validation
  - [x] Evaluate LLM output handling for numeric types
  - [x] Consider adding float type for less strict numeric validation
  - [x] Consider configuration options for numeric validation strictness
  - [x] Document numeric type best practices for LLM interactions
- [x]xArray
  - [x] Basic array input/output
  - [x] Length validation
  - [x] Typed arrays (array of strings, etc.)
  - [x] Required/optional
- [x]xHash
  - [x] Basic hash input/output
  - [x] Schema validation
  - [x] Required/optional
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
    - [x] Generic prompt formatting
    - [x] Schema information integration
    - [x] Basic instructions
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
    - If I create  a system to record inputs and outputs in a database and 👍 or 👎 them, then this could be used for automatically including "few shot" examples in prompts. The automatic tuning system I'm thinking about might be able to test accuracy against token usage by iterating on the number of examples it provides.
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

## Ideas

### Optimization

It might be interesting to have an `#optimize` method on `Task` that would take the prompt and use another Task to optimize the prompt for the specified provider and model. Maybe it could optionally update the Task's source on disk? That wouldn't be great in non-dev environments. It could also maybe store the optimized prompt in memory, in a file on disk, or in a database. The database idea is more along the lines of my thumbs up/down ideal for few-shot prompting, but could tie into this idea as well.

### Thinking / Reasoning

It might be interesting to provide access to the thinking / reasoning output if using one of these models. Maybe this could be tacked onto the response from `call`?

### Justification

Maybe there should be a DSL-level option to add a field to the output called something like `lluminary.justification` that prompts the LLM to provide a justification for its response? Maybe this gets put on the response from calling the LLM? 

## Provider capabilities to consider implementing

Some of these might just be provider-specific in the prompt generation or provider implementation. Like, maybe we automatically use predictions with OpenAI, since it might always be helpful (given the known JSON structure), but maybe not useful on other providers. 

### Image generation



### Batching

This is used to send multiple prompts at the same time in the same request.

[Open AI supports sending up to 20 requests at the same time](https://platform.openai.com/docs/guides/production-best-practices#batching)

### Open AI Prompt caching 

OpenAI says to [put static or repeated content at the beginning of prompts and the variable bits at the end](https://platform.openai.com/docs/guides/prompt-caching#best-practices). This is the opposite of what we're doing right now, so we should make this change.

### Predictions

OpenAI [allows us to send predictions](https://platform.openai.com/docs/guides/predicted-outputs) for output and that this can speed processing. Since we know we're going to be getting back structured JSON, could we pregenerate the JSON structure and include that in the request to speed up responses?


### Streaming

OpenAI (at least) supports streaming. It looks like this happens in chunks, where we get individual tokens as they're available. Is there a streaming JSON parser for ruby? I know there's a streaming XML parser... maybe we could leverage that somehow? I'm guessing it would mostly be applicable to arrays or lists of data. 

Maybe there's an alternative output format that is tabular, like CSV? Something we can iterate over line by line that could be streamed?

Bedrock also supports streaming.

### File inputs

It seems like OpenAI might only [support PDFs](https://platform.openai.com/docs/guides/pdf-files?api-mode=responses) as file inputs. It looks like images can be [referenced by URL or uploaded in base64](https://platform.openai.com/docs/guides/images-vision?api-mode=responses).

There are options for audio. It seems like right now they require using the Chat API or Realtime API. This means I might actually need to automatically use different OpenAI endpoints based on the features being used within Lluminary.

### Customized Models

OpenAI allows you to [fine-tune models](https://platform.openai.com/docs/guides/fine-tuning). How are those accessible? 

One OpenAI fine-tuning approach uses [preferred outputs](https://platform.openai.com/docs/guides/direct-preference-optimization), similar to what I have in mind for the system to tune prompts. Maybe they can be tied together?

Bedrock somehow lets you privately customize foundation models. How are those exposed?

### Knowledge Bases

Bedrock allows you to "augment responses" with info from data (presumably at AWS). Called [Retrieval Augmented Generation](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html). Is that something that needs to be addressed / triggered via a prompt or a particular API call? A quick glance makes me think this is not API-driven.

### Agents

OpenAI has a [python SDK for creating agents](https://openai.github.io/openai-agents-python/). I need to do more research in this area.

### Guardrails

OpenAI has a [moderation](https://platform.openai.com/docs/guides/moderation) system that I think is related to agents.

### Get information about model and capabilities.

Bedrock has `ListFoundationModels` and `GetFoundationModel` to get this information. 
Bedrock will tell you if a model is legacy or active. Could be useful when generating the manifest.

### Managed prompts

Bedrock has a UI tool (and corresponding API) to create managed prompts and tune them for various models.

### Text to video

Bedrock has a text-to-video capability for via [Amazon Nova Reel](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-runtime_example_bedrock-runtime_Scenario_AmazonNova_TextToVideo_section.html). This is an async call. Could anything else in the library be async? Could we somehow have LLM calls with high latency be async with a callback, or something of the sort. (Not super rubyish.) Could we leverage background jobs like Sidekiq, Resque, etc?

### Reasoning 

How can I (and should I?) provide access to reasoning? What utility does it have in this library?
