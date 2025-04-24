# frozen_string_literal: true
Gem::Specification.new do |s|
  s.name = "lluminary"
  s.version = "0.2.0"
  s.summary = "A library for building LLM-powered applications"
  s.description = <<~DESC
    Lluminary is a framework for building applications that leverage Large Language Models. It provides a structured way to define tasks, manage prompts, and handle LLM interactions.
  DESC
  s.authors = ["Doug Hughes"]
  s.email = ["doug@doughughes.net"]
  s.homepage = "https://github.com/dhughes/lluminary"
  s.metadata = {
    "documentation_uri" => "https://github.com/dhughes/lluminary",
    "bug_tracker_uri" => "https://github.com/dhughes/lluminary/issues"
  }
  s.files = Dir["lib/**/*", "spec/**/*"]
  s.license = "MIT"
  s.required_ruby_version = ">= 3.0.0"

  # Runtime dependencies
  s.add_runtime_dependency "activemodel", ">= 5.2", "< 9"
  s.add_runtime_dependency "aws-sdk-bedrock", "~> 1.0" # Required for AWS Bedrock model listing
  s.add_runtime_dependency "aws-sdk-bedrockruntime", "~> 1.0" # Required for AWS Bedrock provider
  s.add_runtime_dependency "ruby-openai", "~> 6.3" # Required for OpenAI provider

  # Development dependencies
  s.add_development_dependency "awesome_print", "~> 1.9"
  s.add_development_dependency "dotenv", "~> 2.8"
  s.add_development_dependency "pry-byebug", "~> 3.10"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rspec", "~> 3.12"
  s.add_development_dependency "rubocop", "~> 1.50"
  s.add_development_dependency "syntax_tree", "~> 6.2"
end
