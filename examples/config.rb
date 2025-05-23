# frozen_string_literal: true
require "dotenv"
Dotenv.load

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lluminary"
require "awesome_print"
require "pry-byebug"

Lluminary.configure do |config|
  config.provider(
    :openai,
    api_key: ENV["OPENAI_API_KEY"],
    model: Lluminary::Models::OpenAi::Gpt35Turbo
  )

  config.provider(
    :bedrock,
    access_key_id: ENV["AWS_ACCESS_KEY_ID"],
    secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    region: ENV["AWS_REGION"],
    model: Lluminary::Models::Bedrock::AnthropicClaudeInstantV1
  )

  config.provider(:anthropic, api_key: ENV["ANTHROPIC_API_KEY"])

  config.provider(
    :vertex,
    credentials_file: ENV["GOOGLE_APPLICATION_CREDENTIALS"],
    project_id: ENV["GOOGLE_CLOUD_PROJECT"],
    location: ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1",
    model: Lluminary::Models::Vertex::GeminiPro
  )
end
