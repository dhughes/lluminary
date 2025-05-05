# Plans for supporting models

1. We need a system to define available providers, model families, models, and capabilities. I'm thinking something like:


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
