# Plans for supporting models

1. We need a system to define available providers, model families, models, and capabilities. I'm thinking a yaml file that looks something like this: (currently being called the manifest.yml)

```yaml
formatters:
  default: Lluminary::Formatters::Default # this would replace the prompt formatting in the Lluminary::Models::Base class
  claude: Lluminary::Formatters::Claude # (or XML or something)

providers:
  default: # maybe not specified in the manifest, but could be specified in an app's global configuration?
  open_ai:
    class: Lluminary::Providers::OpenAi
    models:
      gpt-4o: # I'm thinking that this would implicitly load the config for the specified model
      gpt-4o-2024-05-13:
      dall-e:
      ...
    default_model: gpt-4o
  bedrock:
    class: Lluminary::Providers::Bedrock
    models:
      claude-instant-v1:
        id: anthropic.claude-instant-v1
      ... # each model in amazon would have its own custom ID, since it differs at amazon compared to the ultimate provider.
  anthropic:
    class: Lluminary::Providers::Anthropic
    models:
      claude-instant-v1:

model_families:
  gpt_4o:
    tools: true
    input:
      text: true
      image: true
      audio: true
      attachments: true
    output:
      text: true
      image: true
      audio: true
    config_options:
      # maybe we could use the same schema system to define and validate config options? I think some models/providers may have nested configs....
      max_tokens: ...
      temperature: ...
  dall-e:
    # ...
  claude:
    formatter: claude
    # ...

models:
  default: # maybe not specified in the manifest, but could be specified in an app's global configuration?
  gpt-4o:
    family: gpt_4o
  gpt-4o-2024-05-13:
    family: gpt_4o
  claude-instant-v1:
    family: claude
    ... # models could override family config / capabilities, etc
```

I'm thinking that we'd have nested overrides down the chain. 

* model family (most generic description of a general type of model)
  * model (a more specific description of a specific model within a family - might be provided by multiple providers) - could we use a family instead of a specific model??
    * provider (a provider that uses a specific model from a specific family to execute LLM calls)

* formatter (a class that formats a prompt a given way. useful to format prompts for a particular family of models)

Maybe each of these levels overrides settings from the previous level?  

2. Create one model class that knows how to reference the manifest yaml and behave accordingly.

3. In `Task` classes we'd use `use_provider` to pick the provider. I think this would map to a Provider class, which is important, since that knows how to communicate with the provider. But there'd be other arguments to set the model and configuration options. If not provided, maybe we use a default determined based on the features used by the task itself? It might look like:

```ruby
use_provider: :open_ai, model: "gpt-4o", configuration: { temperature: 0.5 }, formatter: :default
```

So this would ultimately tell the `Provider`, load the `Model` class configured to use the specific model name (`gpt-4o`) and the additional configurations. The Model class would look at the manifest.yml and load the model definition along with its defaults. The defaults would first come from the model family, then be overridden by anything defined in the model itself. Finally, the configuration would be overridden by the explicit configuration from the `use_provider` call. It'd figure out what formatter to use too. So, if the family had a formatter, it'd use that. If the specific model had a formatter, it'd use that. Or, if we specified our own formatter, it'd use that. (There's a future item to register providers, families, models, and formatters). I don't think a provider would ever specify a formatter, but maybe I'm wrong. 

4. Based on the configured model, the Task would self validate. IE: This task requires tools. Does the model support tools? No! That's an error. 

5. Maybe if we don't specify a model we can look at the features used by the task and pick the best model with the correct capabilties. (Eventually this could be tied into a feedback system to tune prompts.) Note: some providers already have a system to pick the model for us. Bedrock calls this "Intelligent prompt routing". 

6. Create a default promot formatter. This would extract what currently exists in Lluminary::Models::Base. Initially everything would use this.

7. Create a custom formatter for Claude. It likes XML tags according to its docs.




**I ran out of time today and need to change what I'm working on. This outlines everything I was thinking and wanted to add here:**

- have one Model class
	- I'm not quite sure what its implementation would look like yet, but it would know how to use the manifest.
- in `Task`s when we use `use_provider`
	- we could specify a model by id or maybe by capabilities.
	- we could indicate capability requirements for the model and let Lluminary pick it for us.
		- Note: some providers have the ability to do this for us. EG: Intelligent prompt routing in Amazon Bedrock
      - maybe we have a model-picking strategy option?
	- Or maybe if we don't specify a model, lluminary might pick a model based on the features the task uses?
- we could have prompt formatters
	- defaulted in the manifest
	- overrideable
	- maybe users could register their own?
- we could have a system to register providers and models and formatters that users could leverage
	- we could use the same system internally
	- could be used by gems that add capabilities to lluminary
		- we might want to do this ourselves fairly early on to separate required dependencies. EG: there's no point in installing the bedrock gems if you're only using openai
	- could be used directly in applications
	- I wonder if this could tie into the configuration system? Or vice versa... the configuration system just updates the loaded manifest.
- we could create utility tasks that could be run to build out and maintain the manifest. 
	- Tasks could maybe be specialized per provider and accept a model name or other information and would then provide data that could be merged into the manifest.yml
- we could generate documentation on providers, models, configuration, defaults, etc, based on the manifest

# Tasks

1. [Spike] Figure out how to attach files for LLMs
  - OpenAI
    - https://platform.openai.com/docs/api-reference
  - Bedrock

2. [Spike] Figure out how to use tools with LLMs
  - OpenAI
  - Bedrock

3. Create an Anthropic provider
  - Should let us run tasks directly against Anthropic's API
  - STATUS: I created the provider in `anthropic-provider` branch based off of `model-support`. I'm consider rebasing it onto `main` and only committing the required changes and rebasing `model-support` from there.

5. Create a Google Vertex provider
  - Only make it work with Claude for the moment

5. Read about Provider API capabilities and just generally think about them
  - What can be done?
  - What should we aim to support?
  - Code interpretation?
  - I just want to keep in mind what could be done in the future to help guide the structure of the manifest.yml

6. Define a basic a manifest.yml format. (Could / should this be a Ruby DSL? If it is, then it might be easier to use the schema system for configurations.)
  - Should define prompt formatters
    - id
    - class
    - configuration_options: (ideally this would use the schema system behind the scenes so it can be validated)
      - api key, etc
  - Should define model families
    - id
    - features (will require some experimentation - I need to know how the different providers allow you to do things like attach files and specify tools)
      - inputs 
        - text
        - tools
        - files
      - outputs
        - text
        - image
        - ???
    - configuration options (ideally, this would use the schema system behind the scenes)
      - I think Bedrock calls these Inference Parameters
      - temperature
      - ???
  - Should define specific models
    - id
    - family
    - features (if different or additional to family)
  - Should specify providers
    - set their classes
    - specify the models they provide
    - specify the formatter to use (if not the default)
  
7. Declare providers in yaml and register them for use when the library loads
  - Define openai and bedrock providers in manifest.yml
  - Introduce `Lluminary.register_provider(id, class)` to register providers for use.
  - Update `Task` to load use providers based on registered id.
  - Allow `register_provider` to be used outside of the core library to register custom providers.
  - Existing Tasks, etc, should continue to work unmodified.
  - At this point we're not worried about models or formatters.

8. Update configuration system so that we can set and override global configuration options for providers.
  - Introduce `Lluminary.configure_provider(id, ....)`
  - This would accept whatever configuration options the provider requires or accepts
  - We'd define the configuration options and defaults and what is/isn't required in the manifest.yml
  - Ideally, this would use the same schema system so we can define complicated configuration schemas and validate them.
  - `configure_provider` would override the defaults from the manifest.
  - When the provider is used, it'd use this combined configuration by default.
    - In the case of API keys, obviously those wouldn't exist in the manifest. If not set via `configure_provider`, then when we used the provider it would raise a configuration validation error, since the key would obviously be required.
  - Evaluate whether it's useful to allow us to specify additional config overrides via `use_provider`. EG: `use_provider :openai, configuration: {api_key: "xyz123"}`
    - If so, implement it. If not, move on.

9. Declare formatters in yaml and register them for use when the library loads
  - Define default formatter in manifest.yml
  - Introduce `Lluminary.register_formatter(id, class)` to register formatters for use.
  - Extract formatting from `Model` class into default formatter.
  - Update `Model` to always use the default formatter to format prompts.
  - Existing Tasks, etc, should continue to work unmodified.
  - Formatter is not yet configurable anywhere. We're just using the default.

9. Declare models in yaml and register them for use by associated providers when the library loads.
  - Define a few models for openai and bedrock
  - Associate providers with models in yaml
  - OpenAI models should span a couple families (gpt-3.5, gpt-4o, dall-e)
  - Bedrock should span a few families too (Claude, Llama, Amazon)
  - Vertex and Anthropic should use the Claude models too.
  - Introduce `Lluminary.register_model(id, capabilities, configurations, etc)` to register models for use. The exact arguments depend on the structure of the manifest when we get to this point.
  - Update `register_provider` to set the models that can be used by the provider.
    - This will need a way to specify the id of the model for the provider. For example Claude-xyz might need to have a different ID for bedrock vs anthropic
    - How will we handle Bedrock models that need to be prefixed with a region? Maybe when we associate providers with models we can add additional configuration options that the provider knows how to work with?
      ```yaml
      providers:
        bedrock:
          class: Lluminary::Providers::Bedrock
          models:
            claude-xyz:
              id: anthropic.claude-instant-v1
              configuration:
                requires_region: true # I don't know what this would actually be, but it would mean that we'd need to configure the region to use for the model for bedrock globally or maybe this would be a setting on the provider itself that could be set globally, or overridden via use_provider?
          configuration:
            inferred_region:
              type: string
              required: false
      ```
  - Providers should pick a default model for a Task unless it's specified
  - Update `Model` so that it uses the model's configuration as specified in the manifest by default
  - Existing tasks that don't define the model should continue to work unmodified.
  - Tasks that specify a model will need to be updated to use the correct model ID (as specified for the specific provider)
    - EG: This means that I should be able to take one of the bedrock tasks and switch it to anthropic and just need to change the model id for anthropic.

10. Spike - Figure out how to to define model configurations
  - Now that we can specify models in the yaml we need to figure out how exactly model configuration will work.
  - We need to know how we'll support other capabilities so we know how to define those.
  - We need to know how to specify the configuration options for a model such as temperature, max tokens, etc. 
  - We need a way to be able to override those via `use_provider`.
  - We need to consider if we want to be able to override the defaults for a model globally, ala the current configuration system.
    - For example, maybe we have a `Lluminary.model_configuration(...)` that we can use globally similar to `provider_configuration(...)`?

# From Cursor

**This was cursors version from our conversation:**

**Core Ideas Recap**

- **Manifest YAML as Source of Truth:**
  - Use a manifest YAML file to define providers, model families, models, and capabilities.
  - Structure should support inheritance/overrides (family → model → provider).
  - Use YAML anchors/aliases to avoid duplication, especially for models available from multiple providers.
  - Add a `version` field for future compatibility.

- **Provider/Model Mapping:**
  - Explicitly map provider-specific model IDs to canonical model names.
  - Allow for aliases and deprecation/experimental flags.

- **Capabilities & Config Options:**
  - Capabilities should be granular and extensible (e.g., `tools: [function_calling, code_interpreter]`).
  - Config options should reference or embed the schema/validation system for runtime validation and doc generation.
  - Allow provider/model-specific overrides.

- **Prompt Formatters:**
  - Allow models, families, and providers to specify/override prompt formatters.
  - Users and plugins should be able to register custom formatters.

- **Extensibility & Plugins:**
  - Manifest should support user/plugin-registered providers/models/formatters.
  - System should be extensible at runtime or via plugin gems.

- **Model Selection & Capability Negotiation:**
  - Support specifying models by ID or by required capabilities.
  - Allow Lluminary to auto-select models based on task requirements or provider features (e.g., Bedrock's intelligent routing).

- **Documentation & Utility Tasks:**
  - Generate documentation from the manifest.
  - Provide utility tasks to help build/maintain the manifest (e.g., fetch model lists, update capabilities).

- **Open Questions:**
  - How to handle region/account-specific model availability?
  - Should manifest link to provider docs for each model/capability?
  - How should defaults and overrides be resolved (explicit rules)?
